"""
Testes da checagem de dominio e da contabilidade de perda do relatorio.

O que se esta testando e uma REGUA, e regua se prova contra o pior caso que ela
existe para pegar, antes de servir para calibrar qualquer coisa. Por isso as
fixtures em `fixtures/` nao sao modelos EDGV: sao insumo degenerado que
exercita, um por um, cada eixo que `checar_dominios` afirma medir. O eixo que
nao aparece aqui sai aprovado por omissao, e e nele que a proxima medida mente.

Origem do caso real, medido em 2026-09-03 numa conversao Topo 1.3 para 1.4:
`llp_limite_legal_l` gravou 0 de 10 feicoes, porque o dado trazia `tipo = 3` e
nenhum dos dois modelos declara esse codigo. A conversao rodou por quatro
minutos, o retry linha a linha virou aviso no log, e o resumo terminou sem dizer
que uma classe inteira saiu vazia.

Nenhum teste aqui toca banco.

Rodar:
    cd conversao_modelagens
    pytest conversor/tests/test_checagem_dominio.py
"""
import json
import os

import pytest

from conversor.checar_dominios import (
    analisar,
    checar_traducoes,
    ler_ddl,
    valores_possiveis,
)
from conversor.converter import FeatureConverter
from conversor.errors import ConversionReport

FIXTURES = os.path.join(os.path.dirname(__file__), "fixtures")
ORIGEM = os.path.join(FIXTURES, "origem_dominio.sql")
DESTINO = os.path.join(FIXTURES, "destino_dominio.sql")
MAPA = os.path.join(FIXTURES, "mapa_dominio.json")


def _recusas(direcao="A=>B", origem=ORIGEM, destino=DESTINO, mapa=MAPA):
    achados = analisar(origem, destino, mapa, direcao)
    return {
        (a["tabela_destino"], a["coluna_destino"]): a
        for a in achados if a["default_no_destino"] is None
    }


# --- leitura do DDL ---------------------------------------------------------

def test_ler_ddl_enxerga_dominio_com_coluna_extra_no_insert():
    """Oito dominios da Topo 1.4 declaram `(code, code_name, filter)`, e o
    maior deles tem 183 codigos. Exigir duas colunas cegava a checagem neles."""
    _, dominios, _, _, rotulos = ler_ddl(ORIGEM)
    assert dominios["dom_com_filtro"] == {1, 5, 9999}
    assert rotulos["dom_com_filtro"][5] == "cinco (5)"


def test_ler_ddl_le_o_check_por_coluna():
    _, _, _, checks, _ = ler_ddl(DESTINO)
    assert checks[("classe_nova_l", "tipo_com_filtro")] == {1, 9999}


# --- o pior caso, eixo por eixo ---------------------------------------------

def test_acusa_atributo_de_mesmo_nome_com_dominio_menor():
    r = _recusas()
    assert r[("classe_nova_l", "tipo")]["codigos_sem_destino"] == [3, 4]


def test_acusa_atributo_renomeado_pelo_mapeamento():
    """O destino se alimenta de `tipo_renomeado`, com outro nome. Seguir o
    `mapeamento_atributos` e o que separa a regua de um diff de nomes."""
    r = _recusas()
    assert r[("classe_nova_l", "tipo_novo_nome")]["codigos_sem_destino"] == [3, 4]


def test_acusa_o_que_so_o_CHECK_da_classe_recusa():
    """A FK admite 5, o CHECK da classe nao. Sem ler o CHECK, a regua aprova
    por omissao o que o destino recusa."""
    a = _recusas()[("classe_nova_l", "tipo_com_filtro")]
    assert a["codigos_sem_destino"] == [5]
    assert a["barreira"] == "CHECK da classe"


def test_nao_acusa_o_que_o_filtro_da_classe_ja_descarta():
    assert ("classe_nova_l", "tipo_filtrado") not in _recusas()


def test_nao_acusa_o_que_a_traducao_resolve():
    assert ("classe_nova_l", "tipo_traduzido") not in _recusas()


def test_nao_acusa_dominio_identico():
    assert ("classe_nova_l", "tipo_igual") not in _recusas()


def test_default_do_mapeamento_e_perda_silenciosa_e_nao_recusa():
    """Com default no destino a carga passa, e o valor da origem se perde sem
    erro nenhum. E achado, de outra gravidade, e nao pode virar zero."""
    achados = analisar(ORIGEM, DESTINO, MAPA)
    cobertos = [a for a in achados if a["default_no_destino"] is not None]
    assert [a["coluna_destino"] for a in cobertos] == ["tipo_default"]
    assert cobertos[0]["default_no_destino"] == 9999


def test_mapeamento_que_cobre_tudo_nao_acusa_nada(tmp_path):
    """A regua vista so acusar nao foi vista funcionar: ela tem de aprovar o
    mapeamento correto, senao vira alarme constante que ninguem le."""
    mapa = json.load(open(MAPA, encoding="utf-8"))
    cm = mapa["mapeamento_classes"][0]
    cm["filtro_A"] = {"$not": {"$or": [
        {"nome_atributo": attr, "valor": v}
        for attr in ("tipo", "tipo_renomeado", "tipo_filtrado",
                     "tipo_traduzido", "tipo_default", "tipo_com_filtro")
        for v in (3, 4, 5)
    ]}}
    caminho = tmp_path / "mapa_ok.json"
    caminho.write_text(json.dumps(mapa, ensure_ascii=False), encoding="utf-8")
    assert _recusas(mapa=str(caminho)) == {}


# --- o avaliador de filtro --------------------------------------------------

@pytest.mark.parametrize("nome,filtro,esperado", [
    ("sem filtro", None, {1, 2, 3, 4, 9999}),
    ("positivo simples", {"nome_atributo": "tipo", "valor": 3}, {3}),
    ("positivo em $or", {"$or": [{"nome_atributo": "tipo", "valor": 3},
                                 {"nome_atributo": "tipo", "valor": 4}]}, {3, 4}),
    ("negado simples", {"$not": {"nome_atributo": "tipo", "valor": 3}},
     {1, 2, 4, 9999}),
    ("negado em $or", {"$not": {"$or": [{"nome_atributo": "tipo", "valor": 3},
                                        {"nome_atributo": "tipo", "valor": 4}]}},
     {1, 2, 9999}),
    ("clausula de outro atributo nao restringe",
     {"nome_atributo": "nome", "valor": "x"}, {1, 2, 3, 4, 9999}),
    ("$or com outro atributo nao restringe",
     {"$or": [{"nome_atributo": "tipo", "valor": 3},
              {"nome_atributo": "nome", "valor": "x"}]}, {1, 2, 3, 4, 9999}),
    ("geometria que casa, mais negacao",
     {"$and": [{"nome_atributo": "$GEOM_TYPE", "valor": "LINESTRING"},
               {"$not": {"nome_atributo": "tipo", "valor": 3}}]}, {1, 2, 4, 9999}),
    ("geometria que nao casa zera tudo",
     {"nome_atributo": "$GEOM_TYPE", "valor": "POINT"}, set()),
])
def test_valores_possiveis(nome, filtro, esperado):
    """Avaliacao de tres valores: clausula sobre atributo alheio devolve
    {True, False}, entao filtro de outra coluna nunca silencia risco real."""
    assert valores_possiveis(
        filtro, "tipo", {1, 2, 3, 4, 9999}, {"$GEOM_TYPE": "LINESTRING"}
    ) == esperado


# --- traducoes --------------------------------------------------------------

def test_traducao_para_rotulo_diferente_vira_suspeita(tmp_path):
    """3 chama-se 'tres' na origem, e o destino tem 7 = 'tres'. Mandar para
    2 = 'dois' passa na FK e mente no atributo."""
    mapa = json.load(open(MAPA, encoding="utf-8"))
    mapa["mapeamento_classes"][0]["mapeamento_atributos"] = [
        {"attr_A": "tipo", "attr_B": "tipo",
         "traducao": [{"valor_A": 3, "valor_B": 2}]},
    ]
    caminho = tmp_path / "m.json"
    caminho.write_text(json.dumps(mapa, ensure_ascii=False), encoding="utf-8")
    suspeitas, _ = checar_traducoes(ORIGEM, DESTINO, str(caminho))
    assert [s["deveria_ser"] for s in suspeitas] == [["7 (tres (7))"]]


def test_traducao_da_classe_vence_a_global_e_nao_vira_falso_alarme(tmp_path):
    """O conversor aplica o global e depois o da classe sobre o mesmo atributo,
    entao a classe vence. Sem modelar a precedencia, um conserto declarado na
    classe some atras do global e a regua acusa o que ja esta certo."""
    mapa = json.load(open(MAPA, encoding="utf-8"))
    mapa["mapeamento_atributos"] = [
        {"attr_A": "tipo", "attr_B": "tipo",
         "traducao": [{"valor_A": 3, "valor_B": 2}]},
    ]
    mapa["mapeamento_classes"][0]["mapeamento_atributos"] = [
        {"attr_A": "tipo", "attr_B": "tipo",
         "traducao": [{"valor_A": 3, "valor_B": 7}]},
    ]
    caminho = tmp_path / "m.json"
    caminho.write_text(json.dumps(mapa, ensure_ascii=False), encoding="utf-8")
    suspeitas, _ = checar_traducoes(ORIGEM, DESTINO, str(caminho))
    assert suspeitas == []


def test_traducao_com_dois_destinos_no_mesmo_sentido_e_ambigua(tmp_path):
    """O conversor percorre a lista inteira reatribuindo, entao vence o ULTIMO,
    em silencio. E como a leitura reversa de uma tabela escrita so para a ida
    transformava 'Outros' em 'Terra' em 72 classes."""
    mapa = json.load(open(MAPA, encoding="utf-8"))
    mapa["mapeamento_classes"][0]["mapeamento_atributos"] = [
        {"attr_A": "tipo", "attr_B": "tipo", "traducao": [
            {"valor_A": 4, "valor_B": 1},
            {"valor_A": 4, "valor_B": 2},
        ]},
    ]
    caminho = tmp_path / "m.json"
    caminho.write_text(json.dumps(mapa, ensure_ascii=False), encoding="utf-8")
    _, ambiguas = checar_traducoes(ORIGEM, DESTINO, str(caminho))
    assert len(ambiguas) == 1
    assert ambiguas[0]["vence"] == 2


def test_traducao_repetida_com_o_mesmo_destino_nao_e_ambigua(tmp_path):
    mapa = json.load(open(MAPA, encoding="utf-8"))
    mapa["mapeamento_classes"][0]["mapeamento_atributos"] = [
        {"attr_A": "tipo", "attr_B": "tipo", "traducao": [
            {"valor_A": 4, "valor_B": 1},
            {"valor_A": 4, "valor_B": 1},
        ]},
    ]
    caminho = tmp_path / "m.json"
    caminho.write_text(json.dumps(mapa, ensure_ascii=False), encoding="utf-8")
    _, ambiguas = checar_traducoes(ORIGEM, DESTINO, str(caminho))
    assert ambiguas == []


# --- a contabilidade da perda -----------------------------------------------

def test_classe_que_grava_zero_de_dez_reprova_o_relatorio():
    """O caso real. Antes disso, `written_features` subia menos e nada no
    resumo dizia que a classe tinha saido vazia."""
    report = ConversionReport()
    report.registrar_escrita("edgv.llp_limite_legal_l", 10, 0)
    assert report.escrita_incompleta == {"edgv.llp_limite_legal_l": (10, 0)}
    assert report.houve_perda()
    resumo = report.summary()
    assert "ESCRITA INCOMPLETA" in resumo
    assert "CLASSE VAZIA" in resumo


def test_escrita_completa_nao_reprova():
    report = ConversionReport()
    report.registrar_escrita("edgv.constr_edificacao_p", 6543, 6543)
    assert report.escrita_incompleta == {}
    assert not report.houve_perda()


def test_descarte_por_filtro_nao_se_confunde_com_classe_ausente():
    """Feicao tirada por um filtro declarado e decisao; feicao cuja classe o
    mapeamento nem conhece e defeito. As duas caiam no mesmo numero."""
    report = ConversionReport()
    report.registrar_descarte("edgv.edicao_limite_legal_l", por_filtro=True)
    report.registrar_descarte("edgv.llp_limite_legal_a", por_filtro=False)
    assert report.descartadas_por_filtro == {"edgv.edicao_limite_legal_l": 1}
    assert report.classes_sem_mapeamento == {"edgv.llp_limite_legal_a": 1}
    assert report.houve_perda()  # a classe ausente e perda nao declarada
    resumo = report.summary()
    assert "Descartadas por FILTRO declarado" in resumo
    assert "SEM entrada no mapeamento" in resumo


def test_converter_diz_se_o_nome_da_classe_bateu():
    """`CLASS_FILTERED` e o que permite ao relatorio separar os dois casos."""
    mapa = json.load(open(MAPA, encoding="utf-8"))
    conv = FeatureConverter(mapa, "A=>B")

    filtrada = conv.convert_feature(conv.build_feature_dict(
        {"feature_type": "edgv.classe_velha_l", "tipo_filtrado": 3}, "LINESTRING",
    ))
    assert filtrada["CLASS_NOT_FOUND"] and filtrada["CLASS_FILTERED"]

    ausente = conv.convert_feature(conv.build_feature_dict(
        {"feature_type": "edgv.classe_que_ninguem_mapeou_l"}, "LINESTRING",
    ))
    assert ausente["CLASS_NOT_FOUND"] and not ausente["CLASS_FILTERED"]
