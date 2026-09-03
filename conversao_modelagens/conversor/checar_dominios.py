"""
Confere, ANTES de converter, se algum valor de dominio da ORIGEM nao existe no
dominio correspondente do DESTINO.

O conversor copia todo atributo da origem por nome (converter.py:186,
`mapped = copy.deepcopy(feat_dict)`) e o escritor descarta so as colunas que o
destino nao tem (writers/postgis.py:182). Atributo de mesmo nome, portanto,
atravessa sem traducao, e o dominio do destino recusa a linha na hora do INSERT:
uma feicao perdida por linha, reportada como WRITE_ERROR no fim de uma conversao
que ja rodou inteira.

Duas checagens, com alcances diferentes:

  estatico   compara os dois DDL ao longo do mapeamento. Pega o dominio que
             ENCOLHEU entre os modelos, sem tocar em banco. Nao pega valor que
             so existe no dado.

  vivo       le os valores DISTINTOS que a origem tem de fato e confronta com o
             dominio do destino. Pega tambem o valor fora do dominio da propria
             origem (FK derrubada, dominio estendido a mao). Exige conexao.

  traducoes  confere cada `traducao` do mapeamento contra o ROTULO dos dois
             dominios, para pegar a que manda 'Fibra' para 'Outros' quando o
             destino tem 'Fibra', e a que declara dois destinos para o mesmo
             valor de origem (o conversor escolhe o ultimo, em silencio).

Rodar de `conversao_modelagens/`:

    py -m conversor.checar_dominios estatico ORIGEM.sql DESTINO.sql MAPA.json [A=>B]
    py -m conversor.checar_dominios traducoes ORIGEM.sql DESTINO.sql MAPA.json [A=>B]
    py -m conversor.checar_dominios vivo CONFIG.json ORIGEM.sql DESTINO.sql MAPA.json

Sai com 1 quando acha algo, para servir de portao em script e em CI. O proprio
conversor ja chama a checagem viva antes de ler feicao: veja `--ignorar-dominio`
em `python -m conversor --help`.
"""
import json
import re
import sys
from collections import defaultdict

GEOMS = ("POINT", "LINESTRING", "POLYGON")

# ---------------------------------------------------------------- DDL


def _statements(texto):
    """Quebra o DDL em comandos. Alguns arquivos do repo vem em UMA linha
    (edgv_300_orto_25.sql), outros multi-linha, e o ';' e o unico separador
    comum aos dois."""
    return [s.strip() for s in texto.split(";") if s.strip()]


RE_CREATE = re.compile(
    r"CREATE\s+TABLE\s+(?:(\w+)\.)?(\w+)\s*\((.*)\)\s*$", re.S | re.I
)
RE_FK = re.compile(
    r"ALTER\s+TABLE\s+(?:(\w+)\.)?(\w+)\s+ADD\s+CONSTRAINT\s+\w+\s+"
    r"FOREIGN\s+KEY\s*\(\s*(\w+)\s*\)\s+REFERENCES\s+(?:(\w+)\.)?(\w+)\s*\(",
    re.S | re.I,
)
# A lista de colunas nao e sempre `(code, code_name)`: oito dominios da Topo 1.4
# (tipo_edificacao, tipo_veg, tipo_ocupacao_solo e outros) trazem uma terceira
# coluna `filter`. Exigir duas colunas cegava a checagem nesses dominios, e o
# maior deles tem 183 codigos. Medido em 2026-09-03, contra a introspeccao de um
# banco 1.4 vivo, que via 64 dominios onde o parser via 56.
RE_INSERT = re.compile(
    r"INSERT\s+INTO\s+(?:(\w+)\.)?(\w+)\s*\(\s*code\s*,\s*code_name\s*"
    r"(?:,[^)]*)?\)\s*VALUES\s*\(\s*(-?\d+)\s*,\s*'((?:[^']|'')*)'",
    re.S | re.I,
)
RE_CHECK = re.compile(
    r"ALTER\s+TABLE\s+(?:(\w+)\.)?(\w+)\s+ADD\s+CONSTRAINT\s+\w+\s+"
    r"CHECK\s*\(\s*(\w+)\s*=\s*ANY\s*\(\s*ARRAY\s*\[(.*?)\]",
    re.S | re.I,
)


def ler_ddl(caminho):
    """Devolve (tabelas, dominios, fks, checks, rotulos).

    tabelas  {tabela: [coluna, ...]}
    dominios {dominio: {codigos}}
    fks      {(tabela, coluna): dominio}
    checks   {(tabela, coluna): {codigos admitidos naquela classe}}
    rotulos  {dominio: {codigo: code_name}}
    """
    with open(caminho, encoding="utf-8") as f:
        texto = f.read()

    tabelas, dominios, fks = {}, defaultdict(set), {}
    # (tabela, coluna) -> conjunto de codigos que o CHECK admite. O orto 2.5
    # estreita o dominio POR CLASSE assim, alem da FK, e ignorar isso deixa a
    # checagem aprovar por omissao o que o destino recusa.
    checks = {}
    rotulos = defaultdict(dict)  # dominio -> {code: rotulo}

    for st in _statements(texto):
        m = RE_CREATE.search(st)
        if m:
            schema, tabela, corpo = m.group(1), m.group(2), m.group(3)
            if schema and schema.lower() == "dominios":
                continue
            colunas = []
            for linha in corpo.split(","):
                linha = linha.strip()
                if not linha or re.match(r"CONSTRAINT|PRIMARY|FOREIGN|UNIQUE|CHECK|WITH",
                                         linha, re.I):
                    continue
                mc = re.match(r"(\w+)\s+\S", linha)
                if mc:
                    colunas.append(mc.group(1))
            tabelas[tabela] = colunas
            continue

        m = RE_FK.search(st)
        if m:
            fks[(m.group(2), m.group(3))] = m.group(5)
            continue

        m = RE_INSERT.search(st)
        if m:
            dominios[m.group(2)].add(int(m.group(3)))
            rotulos[m.group(2)][int(m.group(3))] = m.group(4).replace("''", "'")
            continue

        m = RE_CHECK.search(st)
        if m:
            codigos = {int(x) for x in re.findall(r"-?\d+", m.group(4))}
            chave = (m.group(2), m.group(3))
            checks[chave] = checks.get(chave, codigos) & codigos

    return tabelas, dict(dominios), fks, checks, dict(rotulos)


# ------------------------------------------------- introspeccao do banco


def ler_banco(cfg, schema=None, schema_dominios="dominios"):
    """Le de um PostGIS vivo a mesma coisa que `ler_ddl` le de um arquivo.

    Serve ao portao da conversao, e e melhor que o DDL para isso: o DDL diz
    como o banco DEVERIA ter nascido, e o portao precisa saber o que o banco
    ACEITA agora. Banco com FK derrubada para carga, dominio estendido a mao
    ou CHECK acrescentado depois so aparece aqui.
    """
    from sqlalchemy import create_engine, text

    engine = create_engine(_url_postgis(cfg))
    schema = schema or cfg.get("schema", "edgv")
    tabelas, dominios, fks, checks, rotulos = {}, {}, {}, {}, {}
    try:
        with engine.connect() as con:
            for tabela, coluna in con.execute(text(
                "SELECT table_name, column_name FROM information_schema.columns "
                "WHERE table_schema = :s ORDER BY table_name, ordinal_position"
            ), {"s": schema}):
                tabelas.setdefault(tabela, []).append(coluna)

            # FK de coluna para tabela de dominio
            for tabela, coluna, dominio in con.execute(text("""
                SELECT src.relname, att.attname, alvo.relname
                  FROM pg_constraint c
                  JOIN pg_class src ON src.oid = c.conrelid
                  JOIN pg_namespace ns ON ns.oid = src.relnamespace
                  JOIN pg_class alvo ON alvo.oid = c.confrelid
                  JOIN pg_namespace nsd ON nsd.oid = alvo.relnamespace
                  JOIN unnest(c.conkey) AS k(attnum) ON true
                  JOIN pg_attribute att
                    ON att.attrelid = src.oid AND att.attnum = k.attnum
                 WHERE c.contype = 'f' AND ns.nspname = :s AND nsd.nspname = :d
            """), {"s": schema, "d": schema_dominios}):
                fks[(tabela, coluna)] = dominio

            for dominio in sorted(set(fks.values())):
                try:
                    linhas = con.execute(text(
                        f'SELECT code, code_name FROM "{schema_dominios}"."{dominio}"'
                    )).fetchall()
                except Exception:
                    con.rollback()
                    continue
                codigos, nomes = set(), {}
                for cod, nome in linhas:
                    try:
                        cod = int(cod)
                    except (TypeError, ValueError):
                        continue
                    codigos.add(cod)
                    nomes[cod] = nome
                dominios[dominio] = codigos
                rotulos[dominio] = nomes

            for tabela, definicao in con.execute(text("""
                SELECT rel.relname, pg_get_constraintdef(c.oid)
                  FROM pg_constraint c
                  JOIN pg_class rel ON rel.oid = c.conrelid
                  JOIN pg_namespace ns ON ns.oid = rel.relnamespace
                 WHERE c.contype = 'c' AND ns.nspname = :s
            """), {"s": schema}):
                m = re.search(r"\(?\s*(\w+)\s*=\s*ANY\s*\(\s*ARRAY\s*\[(.*?)\]",
                              definicao, re.S | re.I)
                if not m:
                    continue
                codigos = {int(x) for x in re.findall(r"-?\d+", m.group(2))}
                chave = (tabela, m.group(1))
                checks[chave] = checks.get(chave, codigos) & codigos
    finally:
        engine.dispose()

    return tabelas, dominios, fks, checks, rotulos


def _url_postgis(c):
    from urllib.parse import quote_plus
    return (f"postgresql://{c['user']}:{quote_plus(c['password'])}@"
            f"{c['host']}:{c.get('port', 5432)}/{c['database']}")


# ------------------------------------------------------- mapeamento


def chaves(direcao):
    if direcao == "A=>B":
        return dict(co="classe_A", cd="classe_B", ao="attr_A", ad="attr_B",
                    vo="valor_A", vd="valor_B", filtro="filtro_A",
                    default="atributos_default_B", afixo_o="afixo_geom_A",
                    afixo_d="afixo_geom_B", tupla_d="tupla_B")
    return dict(co="classe_B", cd="classe_A", ao="attr_B", ad="attr_A",
                vo="valor_B", vd="valor_A", filtro="filtro_B",
                default="atributos_default_A", afixo_o="afixo_geom_B",
                afixo_d="afixo_geom_A", tupla_d="tupla_A")


def _com_afixo(classe, afixo, geom):
    if not afixo:
        return classe
    s = afixo.get(geom, "")
    if not s:
        return None
    return classe + s if afixo.get("tipo") == "sufixo" else s + classe


def valores_possiveis(filtro, atributo, candidatos, contexto=None):
    """Dos `candidatos`, quais ainda PODEM passar o filtro de classe.

    Avaliacao de tres valores: uma clausula sobre OUTRO atributo devolve
    {True, False}, porque nada aqui sabe o valor dele, e a feicao pode existir
    das duas formas. Assim o filtro positivo (`tipo = 14`) restringe de fato, o
    negado (`$not tipo = 3`) tambem, e clausula de atributo alheio nunca
    silencia um risco real. `contexto` amarra o que se conhece, hoje o
    `$GEOM_TYPE` da vez.
    """
    if not filtro:
        return set(candidatos)
    contexto = contexto or {}

    def avaliar(no, valor):
        if not isinstance(no, dict):
            return {True, False}
        if "$and" in no:
            r = {True}
            for c in no["$and"]:
                r = {a and b for a in r for b in avaliar(c, valor)}
            return r
        if "$or" in no:
            r = {False}
            for c in no["$or"]:
                r = {a or b for a in r for b in avaliar(c, valor)}
            return r
        if "$not" in no:
            return {not a for a in avaliar(no["$not"], valor)}
        nome = no.get("nome_atributo")
        if nome == atributo:
            return {str(valor) == str(no.get("valor"))}
        if nome in contexto:
            return {str(contexto[nome]) == str(no.get("valor"))}
        return {True, False}

    return {v for v in candidatos if True in avaliar(filtro, v)}


def _modelo(origem):
    """Aceita caminho de DDL ou a tupla que `ler_ddl`/`ler_banco` devolvem."""
    return ler_ddl(origem) if isinstance(origem, str) else origem


def analisar(ddl_o, ddl_d, caminho_mapa, direcao="A=>B", valores_origem=None):
    """`valores_origem(tabela, coluna)` diz que valores a origem oferece.

    Sem ela, valem os codigos do DOMINIO da origem, e a checagem responde
    "o modelo de origem admite valor que o de destino recusa?". Com ela lendo
    o banco, valem os valores que a origem TEM, e a resposta passa a ser
    "esta carga vai falhar?" - que e a pergunta util, e a unica que pega valor
    fora do dominio da propria origem. Nos dois casos o mapeamento e respeitado
    igual: filtro de classe, traducao e default valem antes de acusar."""
    tab_o, dom_o, fk_o, chk_o, rot_o = _modelo(ddl_o)
    tab_d, dom_d, fk_d, chk_d, rot_d = _modelo(ddl_d)
    with open(caminho_mapa, encoding="utf-8") as f:
        mapa = json.load(f)

    k = chaves(direcao)
    afixo_o, afixo_d = mapa.get(k["afixo_o"]), mapa.get(k["afixo_d"])

    defaults_globais = {d["nome_atributo"]: d["valor"]
                        for d in mapa.get(k["default"], [])}
    attrmap_global = mapa.get("mapeamento_atributos", [])

    achados = []
    pares_vistos = set()

    for cm in mapa.get("mapeamento_classes", []):
        if cm.get("sentido") and cm["sentido"] != direcao:
            continue
        if k["co"] not in cm or k["cd"] not in cm:
            continue

        defaults = dict(defaults_globais)
        defaults.update({d["nome_atributo"]: d["valor"]
                         for d in cm.get(k["default"], [])})
        # mapeamento_multiplo tambem grava valor constante no destino
        for mm in mapa.get("mapeamento_multiplo", []) + cm.get("mapeamento_multiplo", []):
            if mm.get("sentido") and mm["sentido"] != direcao:
                continue
            for v in mm.get(k["tupla_d"], []):
                defaults.setdefault(v["nome_atributo"], v["valor"])

        attrmaps = attrmap_global + cm.get("mapeamento_atributos", [])
        # attr de destino -> {valor de origem traduzido}
        traduzidos = defaultdict(set)
        renomeados = {}  # attr destino -> attr origem
        for am in attrmaps:
            if k["ao"] not in am or k["ad"] not in am:
                continue
            renomeados[am[k["ad"]]] = am[k["ao"]]
            for t in am.get("traducao", []):
                if t.get("sentido") and t["sentido"] != direcao:
                    continue
                if k["vo"] not in t:
                    continue
                bruto = t[k["vo"]]
                # O valor CRU importa alem do inteiro: a coluna `sigla` da 1.3
                # e varchar, e a traducao que resolve o caso e 'PR' -> 18.
                # Guardar so o inteiro deixava o texto por acusar, e o alarme
                # continuava depois do conserto ja aplicado.
                traduzidos[am[k["ad"]]].add(bruto)
                try:
                    traduzidos[am[k["ad"]]].add(int(bruto))
                except (TypeError, ValueError):
                    pass

        for geom in GEOMS:
            t_o = _com_afixo(cm[k["co"]], afixo_o, geom)
            t_d = _com_afixo(cm[k["cd"]], afixo_d, geom)
            if not t_o or not t_d or t_o not in tab_o or t_d not in tab_d:
                continue
            if (t_o, t_d) in pares_vistos:
                continue
            pares_vistos.add((t_o, t_d))

            for col_d in tab_d[t_d]:
                dominio_d = fk_d.get((t_d, col_d))
                if not dominio_d or dominio_d not in dom_d:
                    continue
                # de qual coluna da origem esse destino se alimenta
                col_o = col_d if col_d in tab_o[t_o] else renomeados.get(col_d)
                if not col_o or col_o not in tab_o[t_o]:
                    continue
                dominio_o = fk_o.get((t_o, col_o))
                if valores_origem is None:
                    # sem banco, so da para comparar dominio com dominio
                    if not dominio_o or dominio_o not in dom_o:
                        continue
                    # o CHECK da classe estreita o dominio para ELA, dos dois lados
                    aceitos_o = (dom_o[dominio_o]
                                 & chk_o.get((t_o, col_o), dom_o[dominio_o]))
                else:
                    # com banco vale o que a coluna TEM, mesmo onde a origem nao
                    # declara dominio nenhum: a coluna que GANHA dominio no
                    # destino (o `sigla`, varchar na 1.3 e codigo na 1.4) e
                    # justamente a que ninguem confere.
                    reais = valores_origem(t_o, col_o)
                    if reais is None:
                        continue
                    aceitos_o = set(reais)
                    dominio_o = dominio_o or "(origem sem dominio)"
                aceitos_d = dom_d[dominio_d] & chk_d.get((t_d, col_d), dom_d[dominio_d])
                possiveis = valores_possiveis(
                    cm.get(k["filtro"]), col_o, aceitos_o, {"$GEOM_TYPE": geom},
                )
                sobra = possiveis - aceitos_d
                sobra -= traduzidos.get(col_d, set())
                if not sobra:
                    continue

                coberto = col_d in defaults
                barreira = ("CHECK da classe"
                            if (t_d, col_d) in chk_d and sobra - dom_d[dominio_d] != sobra
                            else "FK do dominio")
                if (t_d, col_d) in chk_d and not (sobra & (dom_d[dominio_d] - aceitos_d)):
                    barreira = "FK do dominio"
                elif (t_d, col_d) in chk_d:
                    barreira = "CHECK da classe"
                achados.append({
                    "barreira": barreira,
                    "tabela_origem": t_o,
                    "tabela_destino": t_d,
                    "coluna_origem": col_o,
                    "coluna_destino": col_d,
                    "dominio_origem": dominio_o,
                    "dominio_destino": dominio_d,
                    "codigos_sem_destino": sorted(sobra, key=str),
                    "default_no_destino": defaults.get(col_d) if coberto else None,
                })

    return achados


# --------------------------------------------------- traducao suspeita


def _nome_limpo(rotulo):
    """Tira o sufixo '(n)' que o DDL cola no rotulo, e normaliza."""
    import unicodedata
    if rotulo is None:
        return None
    t = re.sub(r"\s*\(-?\d+\)\s*$", "", rotulo).strip().lower()
    t = unicodedata.normalize("NFKD", t)
    return "".join(c for c in t if not unicodedata.combining(c))


def checar_traducoes(ddl_o, ddl_d, caminho_mapa, direcao="A=>B"):
    """Confere cada `traducao` do mapeamento contra o ROTULO dos dois dominios.

    Duas coisas que a contagem de codigo sozinha nao pega, porque o codigo
    escrito e valido e o destino aceita:

      SUSPEITA   a origem diz 'Fibra' e a traducao manda para 'Outros', quando
                 a classe de destino ADMITE um codigo chamado 'Fibra'. A carga
                 passa e o atributo pode estar mentindo. Nem toda suspeita e
                 defeito: no mapeamento EDGV 3.0 para Topo 1.4, as 43 traducoes
                 que partem do codigo 0 ('Desconhecido') NUNCA vao para 0, e
                 isso e convencao deliberada, nao engano. Julgue cada uma.
      AMBIGUA    dois `traducao` com o mesmo valor de origem e destinos
                 diferentes no mesmo sentido. O conversor percorre a lista
                 inteira e reatribui, entao vence o ULTIMO
                 (converter.py:116-120), em silencio. Quase sempre e a leitura
                 REVERSA de uma tabela escrita so para o outro sentido, sem
                 `sentido` declarado.

    A avaliacao e por TABELA de destino concreta, e nao pelo dominio solto,
    porque o CHECK da classe estreita o que aquela classe admite: sem isso,
    `Rocha -> Outros` num deposito que nao aceita Rocha viraria falso alarme.
    """
    tab_o, dom_o, fk_o, chk_o, rot_o = _modelo(ddl_o)
    tab_d, dom_d, fk_d, chk_d, rot_d = _modelo(ddl_d)
    with open(caminho_mapa, encoding="utf-8") as f:
        mapa = json.load(f)
    k = chaves(direcao)
    afixo_o, afixo_d = mapa.get(k["afixo_o"]), mapa.get(k["afixo_d"])
    attrmap_global = mapa.get("mapeamento_atributos", [])

    trocadas, ambiguas, vistos_t, vistos_a = [], [], set(), set()

    def admissiveis(tab, col, dominio, checks, dominios):
        base = dominios.get(dominio, set())
        return base & checks.get((tab, col), base)

    for cm in mapa.get("mapeamento_classes", []):
        if cm.get("sentido") and cm["sentido"] != direcao:
            continue
        if k["co"] not in cm or k["cd"] not in cm:
            continue
        locais = cm.get("mapeamento_atributos", [])
        # o conversor aplica o global e DEPOIS o da classe, sobre o mesmo
        # atributo (converter.py:195 e 227), entao a traducao da classe vence a
        # global. Sem modelar isso, um `23 -> 23` declarado na classe some atras
        # do `23 -> 98` global e vira falso alarme.
        vencidas = {
            (am.get(k["ao"]), str(t.get(k["vo"])))
            for am in locais for t in am.get("traducao", [])
        }
        attrmaps = ([(am, True) for am in attrmap_global]
                    + [(am, False) for am in locais])

        for geom in GEOMS:
            t_o = _com_afixo(cm[k["co"]], afixo_o, geom)
            t_d = _com_afixo(cm[k["cd"]], afixo_d, geom)
            if not t_o or not t_d or t_o not in tab_o or t_d not in tab_d:
                continue
            escopo = f"{t_o}->{t_d}"

            for am, e_global in attrmaps:
                if k["ao"] not in am or k["ad"] not in am or "traducao" not in am:
                    continue
                col_o, col_d = am[k["ao"]], am[k["ad"]]
                if col_o not in tab_o[t_o] or col_d not in tab_d[t_d]:
                    continue
                ativos = [t for t in am["traducao"]
                          if not t.get("sentido") or t["sentido"] == direcao]
                if e_global:
                    ativos = [t for t in ativos
                              if (col_o, str(t.get(k["vo"]))) not in vencidas]
                    if not ativos:
                        continue

                por_origem = defaultdict(list)
                for t in ativos:
                    por_origem[str(t.get(k["vo"]))].append(t.get(k["vd"]))
                for vo, destinos in por_origem.items():
                    if len(set(destinos)) > 1:
                        ch = (escopo, col_o, vo)
                        if ch not in vistos_a:
                            vistos_a.add(ch)
                            ambiguas.append({
                                "escopo": escopo, "attr": col_o,
                                "valor_origem": vo, "destinos": destinos,
                                "vence": destinos[-1],
                            })

                d_o, d_d = fk_o.get((t_o, col_o)), fk_d.get((t_d, col_d))
                if not d_o or not d_d:
                    continue
                aceitos_d = admissiveis(t_d, col_d, d_d, chk_d, dom_d)
                for t in ativos:
                    try:
                        vo_i, vd_i = int(t[k["vo"]]), int(t[k["vd"]])
                    except (TypeError, ValueError, KeyError):
                        continue
                    n_o = _nome_limpo(rot_o.get(d_o, {}).get(vo_i))
                    n_d = _nome_limpo(rot_d.get(d_d, {}).get(vd_i))
                    if not n_o or not n_d or n_o == n_d:
                        continue
                    iguais = [c for c in aceitos_d
                              if _nome_limpo(rot_d.get(d_d, {}).get(c)) == n_o]
                    if not iguais:
                        continue
                    ch = (escopo, col_o, col_d, vo_i, vd_i)
                    if ch in vistos_t:
                        continue
                    vistos_t.add(ch)
                    trocadas.append({
                        "escopo": escopo, "attr_origem": col_o,
                        "attr_destino": col_d,
                        "de": f"{vo_i} ({rot_o[d_o][vo_i]})",
                        "para": f"{vd_i} ({rot_d[d_d][vd_i]})",
                        "deveria_ser": [f"{c} ({rot_d[d_d][c]})" for c in iguais],
                    })

    return trocadas, ambiguas


def imprimir(achados, titulo):
    graves = [a for a in achados if a["default_no_destino"] is None]
    cobertos = [a for a in achados if a["default_no_destino"] is not None]
    print(titulo)
    print(f"  {len(graves)} atributo(s) que a conversao levaria a estourar a FK do destino")
    for a in graves:
        print(f"    {a['tabela_origem']}.{a['coluna_origem']} -> "
              f"{a['tabela_destino']}.{a['coluna_destino']}: codigos "
              f"{a['codigos_sem_destino']} que o destino recusa "
              f"({a['barreira']}, dominio {a['dominio_destino']})")
    if cobertos:
        print(f"  {len(cobertos)} coberto(s) por default do mapeamento (o valor se PERDE, "
              "sem erro):")
        for a in cobertos:
            print(f"    {a['tabela_destino']}.{a['coluna_destino']}: "
                  f"{a['codigos_sem_destino']} -> default {a['default_no_destino']}")
    return 1 if graves else 0


# ------------------------------------------------------------ vivo


def checar_vivo(config, ddl_origem, ddl_destino, caminho_mapa, direcao="A=>B"):
    """Le da ORIGEM os valores distintos de cada coluna e roda a mesma analise.

    So SELECT. Vale a pena porque o DDL descreve o modelo, nao o banco: o dado
    de producao guarda valor fora do dominio da propria origem (FK derrubada,
    carga legada, dominio estendido a mao), e nenhuma comparacao de DDL com DDL
    enxerga isso. Coluna que a origem nao tem devolve None e sai da conta.
    """
    from sqlalchemy import create_engine, text

    def _url(c):
        from urllib.parse import quote_plus
        return (f"postgresql://{c['user']}:{quote_plus(c['password'])}@"
                f"{c['host']}:{c.get('port', 5432)}/{c['database']}")

    if not isinstance(config, dict):
        with open(config, encoding="utf-8") as f:
            config = json.load(f)
    origem = config["source"]
    schema = origem.get("schema", "edgv")
    engine = create_engine(_url(origem))
    cache = {}

    with engine.connect() as con:
        existentes = {r[0] for r in con.execute(text(
            "SELECT table_name FROM information_schema.tables "
            "WHERE table_schema = :s"), {"s": schema})}

        def valores(tabela, coluna):
            chave = (tabela, coluna)
            if chave in cache:
                return cache[chave]
            if tabela not in existentes:
                cache[chave] = None
                return None
            try:
                linhas = con.execute(text(
                    f'SELECT DISTINCT "{coluna}" FROM "{schema}"."{tabela}" '
                    f'WHERE "{coluna}" IS NOT NULL')).fetchall()
            except Exception:
                con.rollback()
                cache[chave] = None
                return None
            valores_lidos = set()
            for (v,) in linhas:
                try:
                    valores_lidos.add(int(v))
                except (TypeError, ValueError):
                    # Texto onde o destino quer codigo (o `sigla` da 1.3 e
                    # varchar e virou smallint na 1.4) segue pelo MESMO caminho
                    # dos numeros. Ter um caminho separado fazia a traducao
                    # declarada no mapeamento ('PR' -> 18) nao contar, e o
                    # alarme continuava depois do conserto.
                    valores_lidos.add(str(v))
            cache[chave] = valores_lidos
            return valores_lidos

        achados = analisar(ddl_origem, ddl_destino, caminho_mapa, direcao,
                           valores_origem=valores)

        for a in achados:
            if a["default_no_destino"] is not None:
                continue
            t_o, c_o = a["tabela_origem"], a["coluna_origem"]
            try:
                a["feicoes"] = int(con.execute(text(
                    f'SELECT count(*) FROM "{schema}"."{t_o}" '
                    f'WHERE "{c_o}"::text = ANY(:v)'),
                    {"v": [str(x) for x in a["codigos_sem_destino"]]}).scalar())
            except Exception:
                con.rollback()
                a["feicoes"] = None
    engine.dispose()
    # a segunda posicao existia para o texto, que agora anda pelo mesmo caminho
    # dos numeros; fica vazia para nao quebrar quem ja chama a funcao
    return achados, []


# ----------------------------------------------- portao da conversao


def checar_config(config):
    """Roda a checagem viva a partir de um config do conversor, sem DDL.

    O modelo do destino sai do BANCO de destino, nao do arquivo `.sql`: o DDL
    diz como o banco deveria ter nascido, e aqui interessa o que ele aceita
    agora. Devolve `(achados, textos, motivo)`. Quando nao da para checar,
    `achados` e `textos` vem vazios e `motivo` diz por que, para o chamador
    nunca confundir "esta limpo" com "nao foi olhado".
    """
    origem, destino = config["source"], config["destination"]
    if origem["type"] != "postgis" or destino["type"] != "postgis":
        return [], [], "so vale de PostGIS para PostGIS"
    estagios = config.get("stages") or []
    if len(estagios) != 1:
        return [], [], (
            f"pipeline com {len(estagios)} estagios: os valores intermediarios "
            "nao existem em banco nenhum para conferir"
        )
    estagio = estagios[0]
    if not estagio.get("mapping_file"):
        return [], [], "estagio sem mapeamento (passthrough)"

    modelo_o = ler_banco(origem)
    modelo_d = ler_banco(destino)
    achados, textos = checar_vivo(
        {"source": origem}, modelo_o, modelo_d,
        estagio["mapping_file"], estagio.get("direction", "A=>B"),
    )
    return achados, textos, None


def resumo_checagem(achados, textos, motivo=None):
    """As linhas que o dry-run e o portao imprimem, iguais nos dois."""
    if motivo:
        return [f"Dominio: NAO CHECADO ({motivo})"]
    graves = [a for a in achados if a["default_no_destino"] is None]
    if not graves and not textos:
        return ["Dominio: nenhum valor da origem que o destino recuse"]
    linhas = [
        f"Dominio: {len(graves)} coluna(s) com valor que o destino RECUSA, "
        f"{len(textos)} com texto onde o destino quer codigo"
    ]
    for a in graves:
        n = a.get("feicoes")
        linhas.append(
            f"  {a['tabela_origem']}.{a['coluna_origem']} -> "
            f"{a['tabela_destino']}.{a['coluna_destino']}: "
            f"{a['codigos_sem_destino']} em {n if n is not None else '?'} "
            f"feicao(oes) ({a['barreira']})"
        )
    for t, c, v in textos:
        linhas.append(f"  {t}.{c}: guarda TEXTO {v}, e o destino quer codigo")
    return linhas


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(2)
    modo = sys.argv[1]
    esperado = {"estatico": 5, "traducoes": 5, "vivo": 6}
    if modo in esperado and len(sys.argv) < esperado[modo]:
        print(f"faltam argumentos para '{modo}'.")
        print(__doc__)
        sys.exit(2)
    if modo == "estatico":
        ddl_o, ddl_d, mapa = sys.argv[2:5]
        direcao = sys.argv[5] if len(sys.argv) > 5 else "A=>B"
        r = analisar(ddl_o, ddl_d, mapa, direcao)
        sys.exit(imprimir(r, f"CHECAGEM ESTATICA {direcao}: {mapa}"))
    elif modo == "traducoes":
        ddl_o, ddl_d, mapa = sys.argv[2:5]
        direcao = sys.argv[5] if len(sys.argv) > 5 else "A=>B"
        tro, amb = checar_traducoes(ddl_o, ddl_d, mapa, direcao)
        print(f"TRADUCOES {direcao}: {len(tro)} suspeita(s), {len(amb)} ambigua(s)")
        for t in tro:
            print(f"  SUSPEITA [{t['escopo']}] {t['attr_origem']} -> {t['attr_destino']}: "
                  f"{t['de']} -> {t['para']}, quando o destino tem {t['deveria_ser']}")
        for a in amb:
            print(f"  AMBIGUA [{a['escopo']}] {a['attr']}: valor {a['valor_origem']} "
                  f"tem {len(a['destinos'])} destinos {a['destinos']}, vence {a['vence']}")
        sys.exit(1 if (tro or amb) else 0)
    elif modo == "vivo":
        cfg, ddl_o, ddl_d, mapa = sys.argv[2:6]
        direcao = sys.argv[6] if len(sys.argv) > 6 else "A=>B"
        achados, textos = checar_vivo(cfg, ddl_o, ddl_d, mapa, direcao)
        graves = [a for a in achados if a["default_no_destino"] is None]
        print(f"CHECAGEM VIVA {direcao}: {len(graves)} coluna(s) com valor que o "
              f"destino recusa, {len(textos)} com texto onde o destino quer codigo")
        for a in graves:
            n = a.get("feicoes")
            print(f"  {a['tabela_origem']}.{a['coluna_origem']} -> "
                  f"{a['tabela_destino']}.{a['coluna_destino']}: "
                  f"{a['codigos_sem_destino']} em "
                  f"{n if n is not None else '?'} feicao(oes) "
                  f"({a['barreira']})")
        for t, c, v in textos:
            print(f"  {t}.{c}: guarda TEXTO {v}, e o destino quer codigo numerico")
        sys.exit(1 if (graves or textos) else 0)
    print(__doc__)
    sys.exit(2)
