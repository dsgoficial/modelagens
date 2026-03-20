"""
Mapeamento de modelos para seus arquivos SQL.
"""
import os

_BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

MODELS = {
    "edgv_300": {
        "sql": os.path.join(_BASE, "edgv_300", "edgv_300.sql"),
        "extension": os.path.join(_BASE, "edgv_300", "edgv_300_extension.sql"),
        "default_srid": 4674,
    },
    "edgv_300_topo_14": {
        "sql": os.path.join(_BASE, "edgv_300_topo", "1_4", "edgv_300_topo_14.sql"),
        "extension": os.path.join(_BASE, "edgv_300_topo", "1_4", "edgv_300_topo_extension_14.sql"),
        "default_srid": 4674,
    },
    "edgv_300_orto_25": {
        "sql": os.path.join(_BASE, "edgv_300_orto", "2_5", "edgv_300_orto_25.sql"),
        "extension": os.path.join(_BASE, "edgv_300_orto", "2_5", "edgv_300_orto_extension_25.sql"),
        "default_srid": 4674,
    },
}
