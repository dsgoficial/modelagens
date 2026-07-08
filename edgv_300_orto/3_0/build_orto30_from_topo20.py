# -*- coding: utf-8 -*-
"""
Gera os artefatos do EDGV Orto 3.0.

Principio: o Orto 3.0 ESPELHA o conjunto de classes do Orto 2.5 (mesma
estrutura, classes separadas), porem com as definicoes REBASEADAS no
EDGV Topo 2.0 (tipos, dominios, primitivas, CHECKs, extensao de qualidade).

Para cada classe do Orto 2.5:
  - se existe no Topo 2.0  -> usa a definicao do Topo 2.0
       . tematica  : poda atributos para a intersecao com o Orto 2.5
       . auxiliar  : copiada integral do Topo 2.0
  - se NAO existe no Topo 2.0 (classe propria do produto orto:
    aglomerado_rural, area_pub_militar, nome_local, terra_indigena,
    unidade_conservacao, edicao_articulacao_imagem, edicao_* das areas
    especiais) -> usa a definicao do Orto 2.5 verbatim.

Saidas (reproduziveis — NAO editar a mao):
  - master_file_orto_30.json
  - conversao/conversao_pg-edgv-orto25_pg-edgv-orto30.json   (2.5 -> 3.0, 1:1)
  - conversao/conversao_pg-edgv-topo20_pg-edgv-orto30.json   (Topo 2.0 <-> 3.0, com split por tipo)
  - orto30_topo20_sem_correspondencia.md

Depois:
  python ../../rotinas/mastergen.py master_file_orto_30.json edgv_orto_30.sql --owner postgres
"""
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
TOPO_MASTER = os.path.join(ROOT, "edgv_300_topo", "2_0", "master_file_topo_20.json")
ORTO25_MASTER = os.path.join(ROOT, "edgv_300_orto", "2_5", "master_file_300_orto_25.json")

VERSAO_ORTO = "3.0.0"
VERSAO_TOPO = "0.11.0"
VERSAO_ORTO25 = "2.5.4"

# Split Topo 2.0 -> Orto 3.0: classes do Topo unificadas (limite_especial,
# localidade) que no Orto sao classes SEPARADAS, distinguidas por 'tipo'.
#   orto_class : (topo_class_source, [codigos_tipo])
SPLIT = {
    "llp_localidade": ("llp_localidade", [1, 2, 3, 4, 9, 10]),
    "llp_aglomerado_rural": ("llp_localidade", [5, 6, 7]),
    "llp_nome_local": ("llp_localidade", [8]),
    "llp_area_pub_militar": ("llp_limite_especial", [36]),
    "llp_terra_indigena": ("llp_limite_especial", [2]),
    "llp_unidade_conservacao": ("llp_limite_especial", [5, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35]),
}
# tipo_limite_especial code 3 (Territorio quilombola) nao tem classe no Orto -> descartado.

# Topo 2.0 (0.10.0) consolidou pais/UF em llp_limite_legal (tipo 1/2). O Orto 3.0
# segue: dropa as classes separadas do Orto 2.5 e migra as feicoes para
# llp_limite_legal via tipo default.  orto25_class(key) : tipo_limite_legal
CONSOLIDA_LL = {
    "llp_pais": 1,               # Pais -> llp_limite_legal tipo 1 (Internacional)
    "llp_unidade_federacao": 2,  # UF   -> llp_limite_legal tipo 2 (Estadual)
}

# Classes auxiliares proprias do produto orto, sem fonte no Topo 2.0.
ORTO_ONLY_EXT = {
    "edicao_area_pub_militar", "edicao_terra_indigena",
    "edicao_unidade_conservacao", "edicao_articulacao_imagem",
}

EXCLUSAO_MOTIVOS = {
    "cobter_area_edificada": "Fora do escopo conservador do Orto 3.0 (precedencia Orto 2.5).",
    "cobter_vegetacao": "Fora do escopo conservador do Orto 3.0 (precedencia Orto 2.5).",
    "constr_area_uso_especifico": "Fora do escopo conservador do Orto 3.0 (precedencia Orto 2.5).",
    "constr_deposito": "Fora do escopo conservador do Orto 3.0 (precedencia Orto 2.5).",
    "constr_edificacao": "Fora do escopo conservador do Orto 3.0 (precedencia Orto 2.5).",
    "constr_ocupacao_solo": "Fora do escopo conservador do Orto 3.0 (precedencia Orto 2.5).",
    "elemnat_curva_batimetrica": "Nao interpretavel por ortoimagem (batimetria).",
    "elemnat_elemento_fisiografico": "Classe nova no Topo 2.0; fora do escopo conservador do Orto 3.0 (precedencia Orto 2.5).",
    "elemnat_ponto_cotado_batimetrico": "Nao interpretavel por ortoimagem (batimetria).",
    "infra_alteracao_fisiografica_antropica": "Classe nova no Topo 2.0; fora do escopo conservador do Orto 3.0 (precedencia Orto 2.5).",
    "infra_elemento_viario": "Classe nova no Topo 2.0 (detalhamento viario urbano); fora do escopo conservador do Orto 3.0 (precedencia Orto 2.5).",
    "infra_mobilidade_urbana": "Classe nova no Topo 2.0; fora do escopo conservador do Orto 3.0 (precedencia Orto 2.5).",
    "infra_travessia_hidroviaria": "Rota/travessia hidroviaria conceitual; fora do escopo conservador do Orto 3.0 (precedencia Orto 2.5).",
    "infra_trecho_duto": "Subsuperficie / nao interpretavel por ortoimagem.",
    "infra_trecho_hidroviario": "Rota hidroviaria conceitual; fora do escopo conservador do Orto 3.0 (precedencia Orto 2.5).",
    "infra_vala": "Classe nova no Topo 2.0; fora do escopo conservador do Orto 3.0 (precedencia Orto 2.5).",
    "llp_delimitacao_fisica": "Classe nova no Topo 2.0; fora do escopo conservador do Orto 3.0 (precedencia Orto 2.5).",
    "llp_ponto_controle": "Dado geodesico de campo; nao restituido de ortoimagem.",
}

AFIXO = {"tipo": "sufixo", "POINT": "_p", "LINESTRING": "_l", "POLYGON": "_a"}


def load(p):
    with open(p, encoding="utf-8") as f:
        return json.load(f)


def dump(obj, p):
    with open(p, "w", encoding="utf-8") as f:
        json.dump(obj, f, ensure_ascii=False, indent=2)
    print(f"  escrito: {os.path.relpath(p, HERE)}")


def clone(o):
    return json.loads(json.dumps(o))


def key(c):
    return f"{c['categoria']}_{c['nome']}"


def tipo_filter(codes):
    """Monta filtro_A sobre o atributo 'tipo' (1 codigo -> objeto; varios -> $or)."""
    terms = [{"nome_atributo": "tipo", "valor": c} for c in codes]
    return terms[0] if len(terms) == 1 else {"$or": terms}


def main():
    topo = load(TOPO_MASTER)
    orto25 = load(ORTO25_MASTER)

    topo_classes = {key(c): c for c in topo["classes"]}
    topo_ext = {key(c): c for c in topo.get("extension_classes", [])}
    topo_dom = {d["nome"]: d for d in topo.get("dominios", [])}
    orto25_dom = {d["nome"]: d for d in orto25.get("dominios", [])}
    orto25_attrs = {(c["categoria"], c["nome"]): {a["nome"] for a in c.get("atributos", [])}
                    for grp in ("classes", "extension_classes") for c in orto25.get(grp, [])}

    rep = {"lost25": {}, "from25_them": [], "from25_ext": [], "dom_from25": []}

    # ---- classes tematicas: espelha as 27 do Orto 2.5 ----
    # PRINCIPIO: classe existente no Topo 2.0 -> atributos INTEGRAIS do Topo 2.0
    # (Orto 3.0 e' baseado no Topo 2.0; nao ha reducao de atributos). Classe
    # propria do produto orto (sem contraparte no Topo) -> verbatim do Orto 2.5.
    out_classes = []
    for c in orto25["classes"]:
        k = key(c)
        if k in CONSOLIDA_LL:                      # consolidado em llp_limite_legal (segue Topo 2.0 0.10.0)
            continue
        if k in topo_classes:                      # baseado no Topo 2.0 (atributos integrais)
            tc = clone(topo_classes[k])
        else:                                      # classe propria do orto -> verbatim do 2.5
            tc = clone(c)
            rep["from25_them"].append(k)
        out_classes.append(tc)

    # ---- auxiliares: espelha as 24 do Orto 2.5 ----
    out_ext = []
    for c in orto25.get("extension_classes", []):
        k = key(c)
        if k in topo_ext:
            out_ext.append(clone(topo_ext[k]))     # integral do Topo
        else:
            out_ext.append(clone(c))               # propria do orto -> verbatim
            rep["from25_ext"].append(k)

    # ---- atributos do Orto 2.5 sem destino no Orto 3.0 ----
    # Nas classes comuns rebaseadas no Topo 2.0, atributos que o 2.5 tinha e o
    # Topo 2.0 nao tem (flags cartograficos; atributos de buffer trocados pelo
    # Topo). Usado para anotar a conversao 2.5 -> 3.0.
    for c in out_classes + out_ext:
        k = (c["categoria"], c["nome"])
        a30 = {a["nome"] for a in c.get("atributos", [])}
        lost = sorted(orto25_attrs.get(k, set()) - a30)
        if lost:
            rep["lost25"][key(c)] = lost

    # ---- dominios referenciados (rebaseados no Topo; fallback Orto 2.5) ----
    refs = set()
    for c in out_classes + out_ext:
        for a in c.get("atributos", []):
            if "mapa_valor" in a:
                refs.add(a["mapa_valor"])
    for a in topo.get("atributos_padrao", []):
        if "mapa_valor" in a:
            refs.add(a["mapa_valor"])
    out_dom = []
    for n in sorted(refs):
        if n in topo_dom:
            out_dom.append(topo_dom[n])
        elif n in orto25_dom:
            out_dom.append(orto25_dom[n]); rep["dom_from25"].append(n)
    # ordena conforme aparece no Topo para estabilidade
    order = {d["nome"]: i for i, d in enumerate(topo.get("dominios", []))}
    out_dom.sort(key=lambda d: order.get(d["nome"], 999))

    master = {
        "modelo": "EDGV Orto 3.0",
        "comentario": (
            "Perfil ortoimagem. Espelha o conjunto de classes do Orto 2.5 "
            "(classes separadas) rebaseado nas definicoes do Topo 2.0. "
            "Gerado por build_orto30_from_topo20.py — nao editar a mao."
        ),
        "versao": VERSAO_ORTO,
        "schema_dados": topo.get("schema_dados", "edgv"),
        "schema_dominios": topo.get("schema_dominios", "dominios"),
        "a_ser_preenchido": topo.get("a_ser_preenchido"),
        "atributos_padrao": topo.get("atributos_padrao"),
        "coord_sys": topo.get("coord_sys", 4674),
        "fill_factor": topo.get("fill_factor", 80),
        "nome_geom": topo.get("nome_geom", "geom"),
        "nome_id": topo.get("nome_id", "id"),
        "geom_suffix": topo.get("geom_suffix"),
        "dominios": out_dom,
        "classes": out_classes,
        "extension_classes": out_ext,
    }
    master = {k: v for k, v in master.items() if v is not None}
    dump(master, os.path.join(HERE, "master_file_orto_30.json"))

    orto_them = [key(c) for c in out_classes]
    orto_ext = [key(c) for c in out_ext]

    # traducao sigla_uf (smallint 1..27 no Orto 2.5) -> string ("AC".."TO"), para a
    # UF migrar de sigla-dominio para llp_limite_legal.sigla (varchar).
    sigla_uf_trad = [{"valor_A": v["code"], "valor_B": v["value"]}
                     for v in topo_dom.get("sigla_uf", {}).get("valores", [])]

    write_conv_orto25(orto_them, orto_ext, rep, sigla_uf_trad)
    write_conv_topo20(orto_them, orto_ext, topo_classes, rep)
    write_gapdoc(topo, orto_them, rep)

    # ---- relatorio ----
    print("\n=== RESUMO ===")
    print(f"tematicas: {len(out_classes)}  auxiliares: {len(out_ext)}  dominios: {len(out_dom)}")
    print(f"classes proprias do orto (verbatim 2.5): tematicas={rep['from25_them']} ext={rep['from25_ext']}")
    print("atributos: classes comuns herdam os atributos INTEGRAIS do Topo 2.0 (sem poda).")
    if rep["lost25"]:
        print("atributos do Orto 2.5 sem destino no Orto 3.0 (sem equivalente no Topo 2.0):", rep["lost25"])
    if rep["dom_from25"]:
        print("ATENCAO dominios vindos do Orto 2.5 (nao achados no Topo):", rep["dom_from25"])


def write_conv_orto25(orto_them, orto_ext, rep, sigla_uf_trad=None):
    """Orto 2.5 -> Orto 3.0: 1:1 por nome (estruturas espelhadas)."""
    def entry(k, header):
        e = {"classe_A": k, "classe_B": k}
        notes = [header] if header else []
        # atributos do 2.5 que o 3.0 (rebaseado no Topo 2.0) nao possui
        lost = rep["lost25"].get(k, [])
        if lost:
            notes.append("Sem destino no Orto 3.0 (atributo do 2.5 ausente no Topo 2.0): "
                         + ", ".join(lost) + ".")
        if notes:
            e["__comment"] = " ".join(notes)
        return e

    mape = []
    for i, k in enumerate(orto_them):
        mape.append(entry(k, "classes tematicas (1:1). Orto 3.0 herda os atributos integrais do Topo 2.0." if i == 0 else ""))
    for i, k in enumerate(orto_ext):
        mape.append(entry(k, "classes auxiliares (1:1)." if i == 0 else ""))
    # pais/UF do Orto 2.5 -> llp_limite_legal (consolidacao, segue Topo 2.0 0.10.0)
    for k, tipo in CONSOLIDA_LL.items():
        e = {
            "classe_A": k,
            "classe_B": "llp_limite_legal",
            "atributos_default_B": [{"nome_atributo": "tipo", "valor": tipo}],
            "__comment": (f"{k} consolidado em llp_limite_legal (tipo={tipo}), seguindo a "
                          "Topo 2.0 (0.10.0). nome/geometria_aproximada alinham por nome."),
        }
        # UF: sigla e' dominio smallint (sigla_uf) no 2.5 -> string em llp_limite_legal.sigla
        if k == "llp_unidade_federacao" and sigla_uf_trad:
            e["mapeamento_atributos"] = [
                {"attr_A": "sigla", "attr_B": "sigla", "traducao": sigla_uf_trad}
            ]
            e["__comment"] += " sigla traduzida do dominio smallint sigla_uf para a string de 2 letras."
        mape.append(e)
    total_lost = sum(len(v) for v in rep["lost25"].values())
    conv = {
        "metadados": {
            "versao_arquivo": "1.0",
            "modelo_A": "EDGV 3.0 Orto", "versao_modelo_A": VERSAO_ORTO25,
            "modelo_B": "EDGV Orto 3.0", "versao_modelo_B": VERSAO_ORTO,
        },
        "__comment": (
            "UTF-8. Orto 2.5 -> Orto 3.0. Conjuntos de classes espelhados (1:1 por nome). "
            "Atributos alinham por nome; o 3.0 herda os dominios/definicoes do Topo 2.0 "
            "(codigos de dominio sao identicos, sem traducao de valores). "
            f"{total_lost} atributos do 2.5 sem destino no 3.0 (sem equivalente no Topo 2.0) "
            "estao anotados por classe nos respectivos __comment. O 3.0 ganha atributos do "
            "Topo 2.0 ausentes no 2.5 (preenchidos como NULL/9999 na conversao A=>B)."
        ),
        "schema_A": "edgv", "schema_B": "edgv",
        "afixo_geom_A": AFIXO, "afixo_geom_B": AFIXO,
        "agregar_geom_A": True, "agregar_geom_B": True,
        "mapeamento_classes": mape,
    }
    dump(conv, os.path.join(HERE, "conversao", "conversao_pg-edgv-orto25_pg-edgv-orto30.json"))


def write_conv_topo20(orto_them, orto_ext, topo_classes, rep):
    """Topo 2.0 <-> Orto 3.0: 1:1 nas comuns; split por 'tipo' nas separadas."""
    mape = []
    first = True
    for k in orto_them:
        if k in SPLIT:
            src, codes = SPLIT[k]
            e = {"classe_A": src, "classe_B": k, "filtro_A": tipo_filter(codes)}
            cmt = f"split por tipo de {src} (codigos {codes})."
            if k == src:
                cmt = f"{src} restrito aos tipos {codes} (demais tipos viram classes separadas)."
            e["__comment"] = (("classes tematicas. " if first else "") + cmt)
            first = False
            mape.append(e)
        elif k in topo_classes:
            e = {"classe_A": k, "classe_B": k}  # 1:1, atributos integrais do Topo 2.0
            if first:
                e["__comment"] = "classes tematicas (1:1, atributos integrais do Topo 2.0)."
                first = False
            mape.append(e)
        # (nao ha outro caso: toda tematica do orto e comum ou split)
    first_ext = True
    for k in orto_ext:
        if k in ORTO_ONLY_EXT:
            continue  # sem fonte no Topo 2.0 (ver gap doc)
        e = {"classe_A": k, "classe_B": k}
        if first_ext:
            e["__comment"] = "classes auxiliares (1:1, integras do Topo 2.0)."
            first_ext = False
        mape.append(e)
    conv = {
        "metadados": {
            "versao_arquivo": "1.1",
            "modelo_A": "EDGV Topo 2.0", "versao_modelo_A": VERSAO_TOPO,
            "modelo_B": "EDGV Orto 3.0", "versao_modelo_B": VERSAO_ORTO,
        },
        "__comment": (
            "UTF-8. Topo 2.0 <-> Orto 3.0. Comuns: 1:1 por nome. As areas especiais e "
            "localidades, unificadas no Topo 2.0 (limite_especial/localidade), sao classes "
            "SEPARADAS no Orto e mapeadas por filtro sobre 'tipo'. Atributos auxiliares "
            "proprios do orto (edicao_articulacao_imagem, edicao das areas especiais) nao "
            "tem fonte no Topo 2.0 — ver orto30_topo20_sem_correspondencia.md."
        ),
        "schema_A": "edgv", "schema_B": "edgv",
        "afixo_geom_A": AFIXO, "afixo_geom_B": AFIXO,
        "agregar_geom_A": True, "agregar_geom_B": True,
        "mapeamento_classes": mape,
    }
    dump(conv, os.path.join(HERE, "conversao", "conversao_pg-edgv-topo20_pg-edgv-orto30.json"))


def write_gapdoc(topo, orto_them, rep):
    topo_them = [key(c) for c in topo["classes"]]
    # classes do Topo usadas como classe_A (comuns + fontes de split)
    used = set()
    for k in orto_them:
        if k in SPLIT:
            used.add(SPLIT[k][0])
        else:
            used.add(k)
    excl = [k for k in topo_them if k not in used]

    L = []
    L.append("# Topo 2.0 -> Orto 3.0 — Sem Correspondencia\n")
    L.append("Complemento da conversao `conversao_pg-edgv-topo20_pg-edgv-orto30.json`.\n")
    L.append("## 1. Classes tematicas do Topo 2.0 sem classe no Orto 3.0\n")
    L.append(f"{len(excl)} de {len(topo_them)} classes tematicas. O Orto 3.0 adota escopo "
             "conservador (precedencia Orto 2.5): exclui o que e intrinsecamente nao "
             "interpretavel por ortoimagem (batimetria, geodesia de campo, subsuperficie, "
             "rotas conceituais) e o que ja estava fora do produto Orto 2.5.\n")
    L.append("| Classe Topo 2.0 | Motivo |")
    L.append("|---|---|")
    for k in sorted(excl):
        L.append(f"| `{k}` | {EXCLUSAO_MOTIVOS.get(k, '-')} |")

    L.append("\n## 2. Atributos das classes mapeadas 1:1\n")
    L.append("**Nenhum** atributo e' descartado: as classes do Orto 3.0 que existem no "
             "Topo 2.0 herdam o conjunto de atributos **integral** do Topo 2.0 (Orto 3.0 e' "
             "baseado no Topo 2.0). Conversao Topo 2.0 -> Orto 3.0 sem perda de atributos "
             "nas classes comuns.")

    L.append("\n## 3. Classes do Orto 3.0 sem fonte 1:1 no Topo 2.0\n")
    L.append("**Derivadas por `tipo`** (a partir de classes unificadas do Topo 2.0):\n")
    L.append("| Classe Orto 3.0 | Origem Topo 2.0 | tipo |")
    L.append("|---|---|---|")
    for k, (src, codes) in SPLIT.items():
        if k == src:
            continue
        L.append(f"| `{k}` | `{src}` | {codes} |")
    L.append("\n**Proprias do produto ortoimagem** (sem equivalente no Topo 2.0):\n")
    for k in sorted(ORTO_ONLY_EXT):
        L.append(f"- `{k}`")

    L.append("\n## 4. Observacoes\n")
    L.append("- `tipo_limite_especial` codigo 3 (Territorio quilombola) nao tem classe no Orto "
             "3.0; tais feicoes nao sao convertidas de Topo 2.0 para Orto 3.0.")
    L.append("- `localidade` no Topo 2.0 com `tipo` em {1,2,3,4,9,10} -> `llp_localidade`; "
             "{5,6,7} -> `llp_aglomerado_rural`; {8} -> `llp_nome_local`.")
    L.append("- `pais`/`unidade_federacao` do Orto 2.5 foram CONSOLIDADOS em `llp_limite_legal` "
             "(tipo 1=Internacional/Pais, 2=Estadual/UF), seguindo a Topo 2.0 (0.10.0); o Orto "
             "3.0 nao tem classes separadas de pais/UF.")
    p = os.path.join(HERE, "orto30_topo20_sem_correspondencia.md")
    with open(p, "w", encoding="utf-8") as f:
        f.write("\n".join(L) + "\n")
    print(f"  escrito: {os.path.relpath(p, HERE)}")


if __name__ == "__main__":
    main()
