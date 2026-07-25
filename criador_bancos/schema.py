"""
Contrato declarativo do config do criador de bancos (`config_schema.json`).

Existe para o config ser PERGUNTÁVEL: `python -m criador_bancos.main --schema`
imprime a forma aceita, em vez de obrigar quem chama a ler a validação
imperativa de `main.py` ou a copiar um exemplo e torcer.

O schema roda DEPOIS da validação imperativa, como camada adicional: a
imperativa dá as mensagens boas do caminho comum, o schema pega o que ela não
vê (campo desconhecido por erro de digitação, tipo errado, enum inválido).

Gêmeo de `conversao_modelagens/conversor/schema.py`. Os dois são independentes
de propósito: `conversao_modelagens` não é um pacote Python, então não há um
lugar comum para importar sem inventar um.
"""
import json
import os
import sys

SCHEMA_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "config_schema.json")

_warned_missing_jsonschema = False


def schema_text() -> str:
    """Devolve o JSON Schema como texto, do jeito que está versionado."""
    with open(SCHEMA_PATH, "r", encoding="utf-8") as f:
        return f.read()


def load_schema() -> dict:
    return json.loads(schema_text())


def _format_error(error) -> str:
    """Transforma o caminho do erro em algo apontável no arquivo,
    ex.: 'databases[2].model' ou 'connection.port'."""
    parts = []
    for p in error.absolute_path:
        if isinstance(p, int):
            parts.append(f"[{p}]")
        else:
            parts.append(f".{p}" if parts else str(p))
    return f"{''.join(parts) or '(raiz)'}: {error.message}"


def validate_against_schema(config: dict) -> list[str]:
    """Valida `config` contra o JSON Schema e devolve a lista de erros
    (vazia se válido).

    `jsonschema` é opcional de propósito: criar banco não depende dela, e
    quebrar o CLI porque falta uma biblioteca de validação seria trocar um
    problema pequeno por um grande. Sem ela, avisa uma vez e segue.
    """
    global _warned_missing_jsonschema
    try:
        import jsonschema
    except ImportError:
        if not _warned_missing_jsonschema:
            _warned_missing_jsonschema = True
            print(
                "AVISO: pacote 'jsonschema' ausente, a validação contra "
                f"{os.path.basename(SCHEMA_PATH)} foi PULADA. "
                "Instale com: pip install jsonschema",
                file=sys.stderr,
            )
        return []

    schema = load_schema()
    validator_cls = jsonschema.validators.validator_for(schema)
    validator = validator_cls(schema)
    errors = sorted(validator.iter_errors(config), key=lambda e: list(e.absolute_path))
    return [_format_error(e) for e in errors]
