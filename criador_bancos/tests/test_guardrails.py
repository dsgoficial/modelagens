"""
Testes dos guardrails do criador de bancos: contrato perguntável
(config_schema.json), autorização do DROP e dry-run.

Nenhum teste aqui toca PostgreSQL: as funções de conexão são substituídas por
dublês que registram o SQL que SERIA executado. É de propósito, porque o que se
está testando é justamente que o DROP NÃO acontece sem confirmação.

Rodar (da raiz do repositório):
    pytest criador_bancos/tests/
"""
import glob
import json
import os

import pytest

from criador_bancos import main as m
from criador_bancos.models import MODELS
from criador_bancos.schema import load_schema, validate_against_schema

EXAMPLES_DIR = os.path.normpath(
    os.path.join(os.path.dirname(__file__), "..", "config_examples")
)


def _config(nomes, overwrite=None):
    cfg = {
        "connection": {"host": "localhost", "port": 5432, "user": "postgres", "password": "x"},
        "databases": [{"name": n, "model": "edgv_300", "srid": 4674} for n in nomes],
    }
    if overwrite is not None:
        cfg["options"] = {"overwrite": overwrite}
    return cfg


# --- Contrato perguntável ----------------------------------------------------

def test_todos_os_exemplos_validam_contra_o_schema():
    exemplos = sorted(glob.glob(os.path.join(EXAMPLES_DIR, "*.json")))
    assert exemplos, "nenhum config de exemplo encontrado"
    for path in exemplos:
        with open(path, encoding="utf-8") as f:
            raw = json.load(f)
        erros = validate_against_schema(raw)
        assert not erros, f"{os.path.basename(path)}: {erros}"


def test_schema_lista_exatamente_os_modelos_de_models_py():
    """O enum do schema é uma cópia da chave de MODELS. Modelo novo em
    models.py sem entrada no schema quebra aqui, antes de virar um 'modelo não
    reconhecido' na cara de quem usa."""
    schema = load_schema()
    enum = schema["definitions"]["banco"]["properties"]["model"]["enum"]
    assert set(enum) == set(MODELS.keys())


def test_load_config_mantem_a_mensagem_boa_de_modelo_desconhecido(tmp_path):
    cfg = tmp_path / "c.json"
    cfg.write_text(json.dumps({
        "connection": {"host": "h", "user": "u", "password": "p"},
        "databases": [{"name": "b", "model": "edgv_999"}],
    }), encoding="utf-8")

    with pytest.raises(ValueError) as exc:
        m.load_config(str(cfg))
    assert "não reconhecido" in str(exc.value)
    assert "edgv_300" in str(exc.value), "a mensagem lista os modelos válidos"


def test_schema_pega_campo_desconhecido(tmp_path):
    """'databses' seria um 'databases ausente' confuso; com o schema o erro
    aponta o campo intruso."""
    cfg = tmp_path / "c.json"
    cfg.write_text(json.dumps({
        "connection": {"host": "h", "user": "u", "password": "p"},
        "databases": [{"name": "b", "model": "edgv_300"}],
        "optionss": {"overwrite": True},
    }), encoding="utf-8")

    with pytest.raises(ValueError) as exc:
        m.load_config(str(cfg))
    assert "config_schema.json" in str(exc.value)
    assert "optionss" in str(exc.value)


# --- Autorização do DROP -----------------------------------------------------

def test_sem_overwrite_no_config_nada_muda():
    """Compatibilidade: quem roda como sempre rodou continua rodando igual."""
    assert m.resolver_overwrites(_config(["a", "b"]), [], "c.json") == set()
    assert m.resolver_overwrites(_config(["a"], overwrite=False), [], "c.json") == set()


def test_overwrite_no_config_sem_confirmacao_recusa():
    """O modo de falha real: config copiado de outra rodada com
    "overwrite": true apagando um banco que ninguém quis apagar."""
    with pytest.raises(ValueError) as exc:
        m.resolver_overwrites(_config(["prod_25k"], overwrite=True), [], "c.json")

    msg = str(exc.value)
    assert "RECUSADO" in msg
    assert "prod_25k" in msg
    # Tem que dizer o tamanho do estrago, não só recusar.
    assert "SESSÕES ATIVAS" in msg
    # E tem que ensinar o comando exato que confirmaria.
    assert "--overwrite prod_25k" in msg


def test_overwrite_confirmado_na_linha_de_comando_autoriza():
    autorizados = m.resolver_overwrites(
        _config(["prod_25k"], overwrite=True), ["prod_25k"], "c.json",
    )
    assert autorizados == {"prod_25k"}


def test_confirmacao_parcial_recusa_a_execucao_inteira():
    """Confirmar um dos dois não libera o outro: a autorização é por banco."""
    with pytest.raises(ValueError) as exc:
        m.resolver_overwrites(_config(["a", "b"], overwrite=True), ["a"], "c.json")
    msg = str(exc.value)
    assert "b" in msg
    assert "Sem confirmação (1)" in msg


def test_overwrite_de_banco_fora_do_config_recusa():
    """Erro de digitação no nome não pode virar 'nada foi confirmado' em
    silêncio."""
    with pytest.raises(ValueError) as exc:
        m.resolver_overwrites(_config(["prod_25k"], overwrite=True), ["prod_50k"], "c.json")
    assert "prod_50k" in str(exc.value)


def test_comando_de_confirmacao_e_copiavel():
    cmd = m.comando_de_confirmacao("meu config.json", ["a", "b"])
    assert cmd == (
        'python -m criador_bancos.main "meu config.json" --overwrite a --overwrite b'
    )


# --- Execução: o DROP só sai com autorização ---------------------------------

class _Cursor:
    def __init__(self, registro, existe):
        self.registro = registro
        self.existe = existe

    def __enter__(self):
        return self

    def __exit__(self, *a):
        return False

    def execute(self, sql, params=None):
        self.registro.append(" ".join(sql.split()))

    def fetchone(self):
        return (1,) if self.existe else None


class _Conn:
    def __init__(self, registro, existe):
        self.registro = registro
        self.existe = existe

    def cursor(self):
        return _Cursor(self.registro, self.existe)

    def close(self):
        pass

    def commit(self):
        pass

    def rollback(self):
        pass


@pytest.fixture
def pg_dublado(monkeypatch):
    """Substitui as conexões por dublês e devolve o SQL que SERIA executado."""
    estado = {"existe": True, "sql": []}
    monkeypatch.setattr(m, "_connect_admin", lambda conn: _Conn(estado["sql"], estado["existe"]))
    monkeypatch.setattr(m, "_connect_db", lambda conn, db: _Conn(estado["sql"], estado["existe"]))
    monkeypatch.setattr(m, "_read_sql", lambda path: "-- ddl do modelo")
    return estado


def test_banco_existente_sem_autorizacao_e_ignorado(pg_dublado):
    r = m.create_database({}, {"name": "prod", "model": "edgv_300"}, allow_drop=False)

    assert r["status"] == "ignorado"
    assert not any("DROP DATABASE" in s for s in pg_dublado["sql"]), "derrubou sem autorização"
    assert not any("pg_terminate_backend" in s for s in pg_dublado["sql"])
    # A mensagem tem que dizer as DUAS coisas necessárias para recriar.
    assert "overwrite" in r["message"] and "--overwrite prod" in r["message"]


def test_banco_existente_com_autorizacao_e_derrubado(pg_dublado):
    r = m.create_database({}, {"name": "prod", "model": "edgv_300"}, allow_drop=True)

    assert r["status"] == "criado"
    assert any('DROP DATABASE "prod"' in s for s in pg_dublado["sql"])
    assert any('CREATE DATABASE "prod"' in s for s in pg_dublado["sql"])


def test_banco_inexistente_e_criado_sem_drop(pg_dublado):
    pg_dublado["existe"] = False
    r = m.create_database({}, {"name": "novo", "model": "edgv_300"}, allow_drop=False)

    assert r["status"] == "criado"
    assert not any("DROP DATABASE" in s for s in pg_dublado["sql"])


# --- Dry-run -----------------------------------------------------------------

def test_dry_run_marca_o_que_seria_derrubado(pg_dublado):
    cfg = _config(["prod"], overwrite=True)
    plano = m.montar_plano(cfg, {"prod"}, "c.json")

    assert plano["servidor_consultado"] is True
    assert plano["databases"][0]["acao"] == "derrubar_e_recriar"
    assert plano["resumo"]["derrubar_e_recriar"] == 1
    assert not any("DROP DATABASE" in s for s in pg_dublado["sql"]), "dry-run derrubou banco"


def test_dry_run_separa_criar_de_ignorar(pg_dublado):
    pg_dublado["existe"] = False
    plano = m.montar_plano(_config(["novo"]), set(), "c.json")
    assert plano["databases"][0]["acao"] == "criar"
    assert plano["resumo"] == {"criar": 1, "ignorar": 0, "derrubar_e_recriar": 0, "indeterminado": 0}

    pg_dublado["existe"] = True
    plano = m.montar_plano(_config(["velho"]), set(), "c.json")
    assert plano["databases"][0]["acao"] == "ignorar"


def test_dry_run_sobrevive_a_servidor_fora_do_ar(monkeypatch):
    """A metade offline (modelo, SRID, SQL do modelo) vale mesmo sem servidor."""
    def _explode(_conn):
        raise OSError("conexão recusada")

    monkeypatch.setattr(m, "_connect_admin", _explode)
    plano = m.montar_plano(_config(["x"]), set(), "c.json")

    assert plano["servidor_consultado"] is False
    assert "conexão recusada" in plano["erro_conexao"]
    assert plano["databases"][0]["acao"] == "indeterminado"
    assert plano["databases"][0]["sql_encontrado"] is True


def test_dry_run_nao_vaza_senha(pg_dublado):
    plano = m.montar_plano(_config(["x"]), set(), "c.json")
    assert "password" not in json.dumps(plano, ensure_ascii=False)


# --- CLI ---------------------------------------------------------------------

def test_cli_aceita_varios_overwrite():
    args = m.build_parser().parse_args(["c.json", "--overwrite", "a", "--overwrite", "b"])
    assert args.overwrite == ["a", "b"]
    assert args.dry_run is False


def test_cli_nao_tem_overwrite_por_padrao():
    args = m.build_parser().parse_args(["c.json"])
    assert args.overwrite == []
