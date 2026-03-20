"""
Lógica de conversão de feições — refatoração do python_caller.py sem dependências FME.
"""
import copy
import logging

logger = logging.getLogger(__name__)

_DIRECTION_KEYS = {
    "A=>B": {
        "attr_origin": "attr_A", "attr_destiny": "attr_B",
        "value_origin": "valor_A", "value_destiny": "valor_B",
        "default": "atributos_default_B", "filter": "filtro_A",
        "class_origin": "classe_A", "class_destiny": "classe_B",
        "group_origin": "tupla_A", "group_destiny": "tupla_B",
        "affix_origin": "afixo_geom_A", "affix_destiny": "afixo_geom_B",
        "schema_origin": "schema_A", "schema_destiny": "schema_B",
        "class_affix_origin": "com_afixo_geom_A", "class_affix_destiny": "com_afixo_geom_B",
        "class_schema_origin": "com_schema_A", "class_schema_destiny": "com_schema_B",
        "agregar": "agregar_geom_A",
    },
    "B=>A": {
        "attr_origin": "attr_B", "attr_destiny": "attr_A",
        "value_origin": "valor_B", "value_destiny": "valor_A",
        "default": "atributos_default_A", "filter": "filtro_B",
        "class_origin": "classe_B", "class_destiny": "classe_A",
        "group_origin": "tupla_B", "group_destiny": "tupla_A",
        "affix_origin": "afixo_geom_B", "affix_destiny": "afixo_geom_A",
        "schema_origin": "schema_B", "schema_destiny": "schema_A",
        "class_affix_origin": "com_afixo_geom_B", "class_affix_destiny": "com_afixo_geom_A",
        "class_schema_origin": "com_schema_B", "class_schema_destiny": "com_schema_A",
        "agregar": "agregar_geom_B",
    },
}


class FeatureConverter:
    def __init__(self, mapping_dict: dict, direction: str):
        self.mapping_dict = mapping_dict
        self.direction = direction
        keys = _DIRECTION_KEYS[direction]
        self.k_attr_o = keys["attr_origin"]
        self.k_attr_d = keys["attr_destiny"]
        self.k_val_o = keys["value_origin"]
        self.k_val_d = keys["value_destiny"]
        self.k_default = keys["default"]
        self.k_filter = keys["filter"]
        self.k_class_o = keys["class_origin"]
        self.k_class_d = keys["class_destiny"]
        self.k_group_o = keys["group_origin"]
        self.k_group_d = keys["group_destiny"]
        self.k_affix_o = keys["affix_origin"]
        self.k_affix_d = keys["affix_destiny"]
        self.k_schema_o = keys["schema_origin"]
        self.k_schema_d = keys["schema_destiny"]
        self.k_class_affix_o = keys["class_affix_origin"]
        self.k_class_affix_d = keys["class_affix_destiny"]
        self.k_class_schema_o = keys["class_schema_origin"]
        self.k_class_schema_d = keys["class_schema_destiny"]
        self.k_agregar = keys["agregar"]

    def build_feature_dict(self, attributes: dict, geom_type: str | None) -> dict:
        feat_dict = {}
        for attr, value in attributes.items():
            if value is None:
                feat_dict[attr] = None
            elif value is False:
                feat_dict[attr] = "False"
            elif value is True:
                feat_dict[attr] = "True"
            else:
                feat_dict[attr] = value

        if geom_type in ("POINT", "LINESTRING", "POLYGON"):
            feat_dict["$GEOM_TYPE"] = geom_type
        else:
            feat_dict["INVALID_GEOM"] = True

        return feat_dict

    def evaluate_expression(self, feat_dict: dict, expression: dict) -> bool:
        if expression["nome_atributo"] not in feat_dict:
            return False
        if expression["valor"] is None or expression["valor"] == "":
            return (
                feat_dict[expression["nome_atributo"]] is None
                or feat_dict[expression["nome_atributo"]] == ""
            )
        return str(feat_dict[expression["nome_atributo"]]) == str(expression["valor"])

    def evaluate_filter(self, feat_dict: dict, filter_condition: dict) -> bool:
        if "$and" in filter_condition:
            return all(
                self.evaluate_filter(feat_dict, c) for c in filter_condition["$and"]
            )
        elif "$or" in filter_condition:
            return any(
                self.evaluate_filter(feat_dict, c) for c in filter_condition["$or"]
            )
        elif "$not" in filter_condition:
            return not self.evaluate_filter(feat_dict, filter_condition["$not"])
        else:
            return self.evaluate_expression(feat_dict, filter_condition)

    def _apply_attr_mapping(self, attmaps: list, feat_dict: dict, mapped: dict, *, check_existing: bool = False):
        for attmap in attmaps:
            if attmap[self.k_attr_o] not in feat_dict:
                continue
            if check_existing and attmap[self.k_attr_d] in mapped:
                pass  # don't overwrite existing value, but still check traducao
            else:
                mapped[attmap[self.k_attr_d]] = feat_dict[attmap[self.k_attr_o]]
            if "traducao" in attmap:
                orig_val = str(feat_dict[attmap[self.k_attr_o]])
                for valuemap in attmap["traducao"]:
                    if (
                        str(valuemap[self.k_val_o]) == orig_val
                        and ("sentido" not in valuemap or valuemap["sentido"] == self.direction)
                    ):
                        mapped[attmap[self.k_attr_d]] = valuemap[self.k_val_d]

    def _apply_multiple_mapping(self, attmaps: list, feat_dict: dict, mapped: dict):
        for attmap in attmaps:
            if "sentido" in attmap and attmap["sentido"] != self.direction:
                continue
            if all(
                self.evaluate_expression(feat_dict, cond)
                for cond in attmap[self.k_group_o]
            ):
                for valuemap in attmap[self.k_group_d]:
                    if (
                        valuemap.get("concatenar")
                        and valuemap["nome_atributo"] in mapped
                        and mapped[valuemap["nome_atributo"]]
                    ):
                        mapped[valuemap["nome_atributo"]] = (
                            mapped[valuemap["nome_atributo"]] + " | " + valuemap["valor"]
                        )
                    else:
                        mapped[valuemap["nome_atributo"]] = valuemap["valor"]

    def convert_feature(self, feat_dict: dict) -> dict:
        md = self.mapping_dict

        feat_dict["feature_type_original"] = feat_dict["feature_type"]

        # Strip schema from feature_type
        if self.k_schema_o in md and md[self.k_schema_o]:
            schema_prefix = md[self.k_schema_o] + "."
            if feat_dict["feature_type"].startswith(schema_prefix):
                feat_dict["feature_type"] = feat_dict["feature_type"][len(schema_prefix):]

        feat_dict["feature_type_sem_schema"] = feat_dict["feature_type"]

        # Strip affix (suffix or prefix)
        affix_cfg = md.get(self.k_affix_o)
        if affix_cfg and "$GEOM_TYPE" in feat_dict:
            affix_tipo = affix_cfg.get("tipo")
            affix_str = affix_cfg.get(feat_dict["$GEOM_TYPE"], "")
            if affix_str:
                if affix_tipo == "sufixo" and feat_dict["feature_type"].endswith(affix_str):
                    feat_dict["feature_type"] = feat_dict["feature_type"][: -len(affix_str)]
                    feat_dict["feature_type_sem_afixo"] = feat_dict["feature_type_original"][: -len(affix_str)]
                elif affix_tipo == "prefixo" and feat_dict["feature_type"].startswith(affix_str):
                    feat_dict["feature_type"] = feat_dict["feature_type"][len(affix_str):]
                    feat_dict["feature_type_sem_afixo"] = feat_dict["feature_type_original"][len(affix_str):]

        # Find matching class (single pass)
        matched_classmap = None
        for classmap in md["mapeamento_classes"]:
            if "sentido" in classmap and classmap["sentido"] != self.direction:
                continue
            class_name = self._resolve_class_name(classmap, feat_dict)
            if classmap[self.k_class_o] == class_name:
                if self.k_filter in classmap:
                    if not self.evaluate_filter(feat_dict, classmap[self.k_filter]):
                        continue
                matched_classmap = classmap
                break

        if matched_classmap is None:
            feat_dict["CLASS_NOT_FOUND"] = True
            return feat_dict

        # Build mapped feature
        mapped = copy.deepcopy(feat_dict)

        # Global defaults
        if self.k_default in md:
            for default in md[self.k_default]:
                mapped[default["nome_atributo"]] = default["valor"]

        # Global attribute mapping
        if "mapeamento_atributos" in md:
            self._apply_attr_mapping(md["mapeamento_atributos"], feat_dict, mapped)

        # Global multiple mapping
        if "mapeamento_multiplo" in md:
            self._apply_multiple_mapping(md["mapeamento_multiplo"], feat_dict, mapped)

        # Apply matched class
        cm = matched_classmap
        mapped["feature_type"] = cm[self.k_class_d]

        # Apply destination affix
        if not cm.get(self.k_class_affix_d):
            dest_affix = md.get(self.k_affix_d)
            if dest_affix and "tipo" in dest_affix:
                geom_str = dest_affix.get(feat_dict.get("$GEOM_TYPE", ""), "")
                if dest_affix["tipo"] == "sufixo":
                    mapped["feature_type"] += geom_str
                elif dest_affix["tipo"] == "prefixo":
                    mapped["feature_type"] = geom_str + mapped["feature_type"]

        # Apply destination schema
        if not cm.get(self.k_class_schema_d):
            if self.k_schema_d in md and md[self.k_schema_d]:
                mapped["feature_type"] = md[self.k_schema_d] + "." + mapped["feature_type"]

        # Class-level defaults
        if self.k_default in cm:
            for default in cm[self.k_default]:
                mapped[default["nome_atributo"]] = default["valor"]

        # Class-level attribute mapping (check_existing=True per original logic)
        if "mapeamento_atributos" in cm:
            self._apply_attr_mapping(cm["mapeamento_atributos"], feat_dict, mapped, check_existing=True)

        # Class-level multiple mapping
        if "mapeamento_multiplo" in cm:
            self._apply_multiple_mapping(cm["mapeamento_multiplo"], feat_dict, mapped)

        # Aggregate geometry flag
        if self.k_agregar in cm:
            mapped["AGGREGATE_GEOM"] = cm[self.k_agregar]
        elif self.k_agregar in md:
            mapped["AGGREGATE_GEOM"] = md[self.k_agregar]

        return mapped

    def _resolve_class_name(self, classmap: dict, feat_dict: dict) -> str:
        has_affix = classmap.get(self.k_class_affix_o)
        has_schema = classmap.get(self.k_class_schema_o)

        if has_affix and has_schema:
            return feat_dict.get("feature_type_original", feat_dict["feature_type"])
        elif has_affix:
            return feat_dict.get("feature_type_sem_schema", feat_dict["feature_type"])
        elif has_schema:
            return feat_dict.get("feature_type_sem_afixo", feat_dict["feature_type"])
        else:
            return feat_dict["feature_type"]
