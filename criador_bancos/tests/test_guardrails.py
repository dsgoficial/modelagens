"""
Testes dos guardrails do criador de bancos: contrato perguntável
(config_schema.json), ausência de qualquer caminho para o DROP e dry-run.

Nenhum teste aqui toca PostgreSQL: as funções de conexão são substituídas por
dublês que registram o SQL que SERIA executado. É de propósito, porque o que se
está testando é justamente que o DROP NÃO sai, aconteça o que acontecer.

Rodar (da raiz do repositório):
    pytest criador_bancos/tests/
"""
import glob
import inspect
import json
import os

import pytest

from criador_bancos import main as m
from criador_bancos.models import MODELS
from criador_bancos.schema import load_schema, validate_against_schema

EXAMPLES_DIR = os.path.normpath(
    os.path.join(os.path.dirname(__file__), "..", "config_examples")
)


def _config(nomes):
    return {
        "connection": {"host": "localhost", "port": 5432, "user": "postgres", "password": "x"},
        "databases": [{"name": n, "model": "edgv_300", "srid": 4674} for n in nomes],
    }


def _escrever(tmp_path, cfg, nome="c.json"):
    caminho = tmp_path / nome
    caminho.write_text(json.dumps(cfg), encoding="utf-8")
    return str(caminho)


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
    """Um `srid` solto na raiz (em vez de dentro do banco) passaria despercebido
    e o banco sairia com o SRID errado; com o schema o erro aponta o intruso."""
    caminho = _escrever(tmp_path, {
        "connection": {"host": "h", "user": "u", "password": "p"},
        "databases": [{"name": "b", "model": "edgv_300"}],
        "srid": 31982,
    })

    with pytest.raises(ValueError) as exc:
        m.load_config(caminho)
    assert "config_schema.json" in str(exc.value)
    assert "srid" in str(exc.value)


# --- Config antigo: a chave extinta é ignorada, nunca fatal ------------------

def test_overwrite_antigo_no_config_e_ignorado_com_aviso(tmp_path, capsys):
    """Config de uma rodada anterior traz `"options": {"overwrite": true}`.
    A chave não existe mais, mas o arquivo não pode virar erro fatal: avisa,
    ignora e segue criando o que falta."""
    cfg = _config(["prod_25k"])
    cfg["options"] = {"overwrite": True}
    caminho = _escrever(tmp_path, cfg)

    carregado = m.load_config(caminho)

    assert "options" not in carregado, "a chave extinta não pode chegar na execução"
    assert [db["name"] for db in carregado["databases"]] == ["prod_25k"]

    err = capsys.readouterr().err
    assert "options.overwrite" in err
    assert "ignorada" in err
    # O aviso tem que dizer o que passou a acontecer no lugar.
    assert "dropdb" in err or "DROP DATABASE" in err


def test_options_antigo_sem_overwrite_tambem_nao_e_fatal(tmp_path, capsys):
    cfg = _config(["a"])
    cfg["options"] = {"__comment": "sobrou de outra rodada"}
    carregado = m.load_config(_escrever(tmp_path, cfg))

    assert "options" not in carregado
    assert '"options"' in capsys.readouterr().err


def test_schema_nao_conhece_mais_options():
    """O contrato perguntável não pode anunciar uma opção que não existe."""
    schema = load_schema()
    assert "options" not in schema["properties"]
    assert "overwrite" not in json.dumps(schema)


# --- Execução: não existe caminho para o DROP --------------------------------

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


def test_banco_existente_e_ignorado_sem_tentar_drop(pg_dublado):
    """O comportamento único: existe, fica intacto, a execução segue."""
    r = m.create_database({}, {"name": "prod", "model": "edgv_300"})

    assert r["status"] == "ignorado"
    assert not any("DROP DATABASE" in s for s in pg_dublado["sql"]), "derrubou banco existente"
    assert not any("pg_terminate_backend" in s for s in pg_dublado["sql"])
    assert not any("CREATE DATABASE" in s for s in pg_dublado["sql"])


def test_mensagem_do_ignorado_ensina_o_caminho_manual(pg_dublado):
    """Como a ferramenta não recria mais, a mensagem tem que dizer como se faz
    à mão, senão vira uma recusa sem saída."""
    r = m.create_database({}, {"name": "prod", "model": "edgv_300"})

    msg = r["message"]
    assert "já existe" in msg
    assert "dropdb prod" in msg
    assert 'DROP DATABASE "prod"' in msg
    # E tem que empurrar a conferência de dependência para antes do estrago.
    assert "depende" in msg


def test_create_database_nao_tem_mais_parametro_de_autorizacao():
    """A capacidade saiu da assinatura, não só do caminho feliz: não há
    argumento nenhum que reabra o DROP."""
    params = inspect.signature(m.create_database).parameters
    assert list(params) == ["connection", "db_config"]


def test_banco_inexistente_e_criado_sem_drop(pg_dublado):
    pg_dublado["existe"] = False
    r = m.create_database({}, {"name": "novo", "model": "edgv_300"})

    assert r["status"] == "criado"
    assert not any("DROP DATABASE" in s for s in pg_dublado["sql"])


# --- Dry-run -----------------------------------------------------------------

def test_dry_run_nao_preve_derrubar_nada(pg_dublado):
    """Banco existente aparece como 'ignorar', e o plano não tem mais como
    dizer 'derrubar'."""
    plano = m.montar_plano(_config(["prod"]), "c.json")

    assert plano["servidor_consultado"] is True
    assert plano["databases"][0]["acao"] == "ignorar"
    assert "derrubar_e_recriar" not in plano["resumo"]
    assert "derrubar_e_recriar" not in m._ROTULO_ACAO
    assert not any("DROP DATABASE" in s for s in pg_dublado["sql"]), "dry-run derrubou banco"


def test_dry_run_separa_criar_de_ignorar(pg_dublado):
    pg_dublado["existe"] = False
    plano = m.montar_plano(_config(["novo"]), "c.json")
    assert plano["databases"][0]["acao"] == "criar"
    assert plano["resumo"] == {"criar": 1, "ignorar": 0, "indeterminado": 0}

    pg_dublado["existe"] = True
    plano = m.montar_plano(_config(["velho"]), "c.json")
    assert plano["databases"][0]["acao"] == "ignorar"


def test_dry_run_sobrevive_a_servidor_fora_do_ar(monkeypatch):
    """A metade offline (modelo, SRID, SQL do modelo) vale mesmo sem servidor."""
    def _explode(_conn):
        raise OSError("conexão recusada")

    monkeypatch.setattr(m, "_connect_admin", _explode)
    plano = m.montar_plano(_config(["x"]), "c.json")

    assert plano["servidor_consultado"] is False
    assert "conexão recusada" in plano["erro_conexao"]
    assert plano["databases"][0]["acao"] == "indeterminado"
    assert plano["databases"][0]["sql_encontrado"] is True


def test_dry_run_nao_vaza_senha(pg_dublado):
    plano = m.montar_plano(_config(["x"]), "c.json")
    assert "password" not in json.dumps(plano, ensure_ascii=False)


# --- CLI ---------------------------------------------------------------------

def test_cli_nao_aceita_mais_a_flag_overwrite(capsys):
    """Quem tentar repetir o comando antigo bate num erro de uso, em vez de
    achar que autorizou alguma coisa."""
    with pytest.raises(SystemExit):
        m.build_parser().parse_args(["c.json", "--overwrite", "prod"])
    assert "--overwrite" in capsys.readouterr().err


def test_cli_so_tem_as_flags_que_restaram():
    args = m.build_parser().parse_args(["c.json"])
    assert args.dry_run is False
    assert not hasattr(args, "overwrite")
