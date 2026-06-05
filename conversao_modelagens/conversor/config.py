import json
import os
import logging

logger = logging.getLogger(__name__)

VALID_DIRECTIONS = {"A=>B", "B=>A"}
VALID_SOURCE_TYPES = {"postgis", "shapefile"}

DEFAULT_OPTIONS = {
    "clip_geometry": None,
    "clip_file": None,
    "reproject_to": None,
    "log_file": None,
    "error_action": "skip",
}


def load_config(config_path: str) -> dict:
    config_path = os.path.abspath(config_path)
    if not os.path.isfile(config_path):
        raise FileNotFoundError(f"Arquivo de configuração não encontrado: {config_path}")

    with open(config_path, "r", encoding="utf-8") as f:
        config = json.load(f)

    config_dir = os.path.dirname(config_path)
    _validate_config(config, config_dir)
    _resolve_paths(config, config_dir)
    _apply_defaults(config)

    return config


def _validate_config(config: dict, config_dir: str):
    for key in ("source", "destination"):
        if key not in config:
            raise ValueError(f"Campo obrigatório ausente no config: '{key}'")

    for endpoint_key in ("source", "destination"):
        endpoint = config[endpoint_key]
        if "type" not in endpoint:
            raise ValueError(f"Campo 'type' ausente em '{endpoint_key}'")
        if endpoint["type"] not in VALID_SOURCE_TYPES:
            raise ValueError(
                f"Tipo inválido em '{endpoint_key}': '{endpoint['type']}'. "
                f"Valores válidos: {VALID_SOURCE_TYPES}"
            )

    stages = _normalize_stages(config)
    _validate_stages(stages, config, config_dir)

    for clip_key in ("batch_clip", "segment_clip"):
        if clip_key in config:
            _validate_clip_source(config[clip_key], clip_key)

    if "batch_clip" in config and "folder_attribute" not in config["batch_clip"]:
        raise ValueError("Campo 'folder_attribute' ausente em 'batch_clip'")


def _normalize_stages(config: dict) -> list:
    """Normaliza a config para sempre expor uma lista `stages`.

    Aceita dois formatos:
    - Encadeado: `stages: [{mapping_file, direction, quality_metadata?}, ...]`.
    - Legado (um estágio): `mapping_file` + `direction` no topo, que vira
      `stages` de um item. Mantém retrocompatibilidade total.

    Em qualquer caso, `source` é a entrada do pipeline e `destination`,
    `batch_clip`/`segment_clip` e `options.reproject_to` valem só na escrita
    final (último estágio). Estágios intermediários transformam em memória.
    """
    if "stages" in config:
        if config.get("mapping_file") is not None or config.get("direction") is not None:
            raise ValueError(
                "Use 'stages' OU 'mapping_file'+'direction' no topo, não os dois"
            )
        stages = config["stages"]
        if not isinstance(stages, list) or not stages:
            raise ValueError("'stages' deve ser uma lista não vazia")
    else:
        stages = [{
            "mapping_file": config.get("mapping_file"),
            "direction": config.get("direction"),
            "quality_metadata": config.get("quality_metadata"),
        }]

    config["stages"] = stages
    return stages


def _validate_stages(stages: list, config: dict, config_dir: str):
    for i, stage in enumerate(stages):
        if not isinstance(stage, dict):
            raise ValueError(f"Estágio {i} deve ser um objeto JSON")

        mapping_file = stage.get("mapping_file")
        if mapping_file:
            mapping_path = mapping_file
            if not os.path.isabs(mapping_path):
                mapping_path = os.path.join(config_dir, mapping_path)
            if not os.path.isfile(mapping_path):
                raise FileNotFoundError(
                    f"Arquivo de mapeamento não encontrado (estágio {i}): {mapping_path}"
                )
            if stage.get("direction") not in VALID_DIRECTIONS:
                raise ValueError(
                    f"Direção inválida no estágio {i}: '{stage.get('direction')}'. "
                    f"Valores válidos: {VALID_DIRECTIONS}"
                )
        else:
            # Passthrough (sem mapeamento) só faz sentido como estágio único
            # no modo segment_clip — preserva o comportamento legado.
            if len(stages) > 1:
                raise ValueError(
                    f"Estágio {i} sem 'mapping_file': passthrough só é permitido "
                    "com um único estágio"
                )
            if "segment_clip" not in config:
                raise ValueError(
                    "Campo 'mapping_file' é obrigatório (exceto no modo segment_clip "
                    "sem mapeamento)"
                )


def _validate_clip_source(clip_cfg: dict, section_name: str):
    if "type" not in clip_cfg:
        raise ValueError(f"Campo 'type' ausente em '{section_name}'")
    if clip_cfg["type"] not in VALID_SOURCE_TYPES:
        raise ValueError(
            f"Tipo inválido em '{section_name}': '{clip_cfg['type']}'. "
            f"Valores válidos: {VALID_SOURCE_TYPES}"
        )
    if clip_cfg["type"] == "postgis":
        for key in ("host", "database", "user", "password", "table"):
            if key not in clip_cfg:
                raise ValueError(f"Campo '{key}' ausente em '{section_name}' (tipo postgis)")
    elif clip_cfg["type"] == "shapefile":
        if "path" not in clip_cfg:
            raise ValueError(f"Campo 'path' ausente em '{section_name}' (tipo shapefile)")


def _resolve_relative(path: str, base_dir: str) -> str:
    if not os.path.isabs(path):
        return os.path.abspath(os.path.join(base_dir, path))
    return path


def _resolve_paths(config: dict, config_dir: str):
    for stage in config.get("stages", []):
        if stage.get("mapping_file"):
            stage["mapping_file"] = _resolve_relative(stage["mapping_file"], config_dir)

    for endpoint_key in ("source", "destination"):
        endpoint = config[endpoint_key]
        if endpoint["type"] == "shapefile" and "path" in endpoint:
            endpoint["path"] = _resolve_relative(endpoint["path"], config_dir)

    options = config.get("options", {})
    for opt_key in ("clip_file", "log_file"):
        if options.get(opt_key):
            options[opt_key] = _resolve_relative(options[opt_key], config_dir)

    for clip_key in ("batch_clip", "segment_clip"):
        if clip_key in config:
            cc = config[clip_key]
            if cc["type"] == "shapefile" and "path" in cc:
                cc["path"] = _resolve_relative(cc["path"], config_dir)


def _apply_defaults(config: dict):
    if "options" not in config:
        config["options"] = {}
    for key, default_val in DEFAULT_OPTIONS.items():
        config["options"].setdefault(key, default_val)

    source = config["source"]
    if source["type"] == "postgis":
        source.setdefault("port", 5432)
        source.setdefault("schema", "public")
        source.setdefault("tables", [])
        source.setdefault("srid", 4326)

    dest = config["destination"]
    if dest["type"] == "shapefile":
        dest.setdefault("encoding", "UTF-8")
        dest.setdefault("srid", 4326)
    if dest["type"] == "postgis":
        dest.setdefault("port", 5432)
        dest.setdefault("schema", "public")
        dest.setdefault("srid", 4326)

    for clip_key in ("batch_clip", "segment_clip"):
        if clip_key in config:
            cc = config[clip_key]
            if cc["type"] == "postgis":
                cc.setdefault("port", 5432)
                cc.setdefault("schema", "public")
                cc.setdefault("geom_column", "geom")


def load_mapping(mapping_path: str) -> dict:
    with open(mapping_path, "r", encoding="utf-8") as f:
        return json.load(f)
