# -*- coding: utf-8 -*-
"""
FME Python Caller - Conversor OSM para EDGV 3.0 Topo

Uso no FME:
  - PythonCaller com Class or Function: FeatureProcessor
  - Gera features com fme_feature_type definido conforme classe EDGV

Data: 2026-02-18
"""

import fmeobjects
import csv
import os
import json
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass, field
from itertools import product


# ============================================================================
# CONFIGURACAO - EDITE ESTES CAMINHOS
# ============================================================================

# Caminhos dos CSVs de mapeamento (edite conforme necessario)
CSV_SHORTBREAD = r"C:\Users\diniz\Downloads\OSM\Mapeamento OSM - Shortbread.csv"
CSV_EXTENSION = r"C:\Users\diniz\Downloads\OSM\Mapeamento OSM - Extensão Shortbread.csv"



# ============================================================================
# ESTRUTURAS DE DADOS
# ============================================================================

@dataclass
class MappingRule:
    """Regra de mapeamento OSM -> EDGV."""
    tag_expression: str
    classe_edgv: str
    codigo_tipo: Optional[int]
    nome_tipo: str
    tipo_geometria: str


@dataclass
class ParsedTagCondition:
    """Condicao de tag parseada."""
    key: str
    value: str
    negated: bool = False
    is_wildcard: bool = False


@dataclass
class ParsedTagGroup:
    """Grupo de condicoes de tags (AND)."""
    conditions: List[ParsedTagCondition] = field(default_factory=list)


@dataclass
class ParsedTagExpression:
    """Expressao de tags completa (OR de ANDs)."""
    groups: List[ParsedTagGroup] = field(default_factory=list)


# ============================================================================
# PARSER DE TAGS OSM
# ============================================================================

class TagParser:
    """Parser para expressoes de tags OSM complexas."""

    @staticmethod
    def parse_expression(expr: str) -> ParsedTagExpression:
        result = ParsedTagExpression()
        if not expr or expr.strip() == "":
            return result

        and_parts = [p.strip() for p in expr.split('+')]

        if len(and_parts) == 1:
            result.groups = TagParser._parse_or_expression(and_parts[0])
        else:
            or_parts = []
            fixed_conditions = []

            for part in and_parts:
                or_groups = TagParser._parse_or_expression(part)
                if len(or_groups) > 1:
                    alternatives = [g.conditions[0] for g in or_groups if g.conditions]
                    or_parts.append(alternatives)
                else:
                    for g in or_groups:
                        fixed_conditions.extend(g.conditions)

            if not or_parts:
                result.groups = [ParsedTagGroup(conditions=fixed_conditions)]
            elif len(or_parts) == 1:
                for alt in or_parts[0]:
                    result.groups.append(ParsedTagGroup(conditions=[alt] + fixed_conditions))
            else:
                for combo in product(*or_parts):
                    result.groups.append(ParsedTagGroup(conditions=list(combo) + fixed_conditions))

        return result

    @staticmethod
    def _parse_or_expression(expr: str) -> List[ParsedTagGroup]:
        groups = []
        parts = [p.strip() for p in expr.split(',')]

        if len(parts) == 1:
            for cond in TagParser._parse_single_condition(parts[0]):
                groups.append(ParsedTagGroup(conditions=[cond]))
            return groups

        keys_in_parts = []
        for part in parts:
            if '=' in part:
                keys_in_parts.append(part.split('=')[0].split('!')[0].strip())
            else:
                keys_in_parts.append(None)

        if keys_in_parts[0] and all(k is None for k in keys_in_parts[1:]):
            base_key = keys_in_parts[0]
            first_part = parts[0]
            negated = '!=' in first_part
            base_value = first_part.split('!=' if negated else '=')[1].strip()

            groups.append(ParsedTagGroup(conditions=[
                ParsedTagCondition(key=base_key, value=base_value, negated=negated)
            ]))
            for value in parts[1:]:
                groups.append(ParsedTagGroup(conditions=[
                    ParsedTagCondition(key=base_key, value=value.strip(), negated=negated)
                ]))
        else:
            for part in parts:
                for cond in TagParser._parse_single_condition(part):
                    groups.append(ParsedTagGroup(conditions=[cond]))

        return groups

    @staticmethod
    def _parse_single_condition(expr: str) -> List[ParsedTagCondition]:
        conditions = []
        expr = expr.strip()
        if not expr:
            return conditions

        if '!=' in expr:
            parts = expr.split('!=')
            if len(parts) == 2:
                conditions.append(ParsedTagCondition(
                    key=parts[0].strip(), value=parts[1].strip(), negated=True
                ))
        elif '=' in expr:
            parts = expr.split('=')
            if len(parts) == 2:
                key = parts[0].strip()
                values = parts[1].strip()
                if values == '*':
                    conditions.append(ParsedTagCondition(key=key, value='*', is_wildcard=True))
                else:
                    conditions.append(ParsedTagCondition(key=key, value=values))

        return conditions

    @staticmethod
    def matches(tags: Dict[str, str], expression: ParsedTagExpression) -> bool:
        if not expression.groups:
            return False
        for group in expression.groups:
            if TagParser._matches_group(tags, group):
                return True
        return False

    @staticmethod
    def _matches_group(tags: Dict[str, str], group: ParsedTagGroup) -> bool:
        if not group.conditions:
            return False
        for condition in group.conditions:
            if not TagParser._matches_condition(tags, condition):
                return False
        return True

    @staticmethod
    def _matches_condition(tags: Dict[str, str], condition: ParsedTagCondition) -> bool:
        tag_value = tags.get(condition.key)
        if condition.is_wildcard:
            return tag_value is not None
        if condition.negated:
            return tag_value is None or tag_value != condition.value
        return tag_value is not None and tag_value == condition.value


# ============================================================================
# GERENCIADOR DE MAPEAMENTOS
# ============================================================================

class MappingManager:
    """Gerencia os mapeamentos OSM -> EDGV."""

    def __init__(self):
        self.rules: List[Tuple[ParsedTagExpression, MappingRule]] = []

    def load_csv(self, filepath: str, csv_type: str = "shortbread") -> int:
        if not os.path.exists(filepath):
            return 0

        count = 0
        with open(filepath, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                if csv_type == "shortbread":
                    status = row.get('status_mapeamento', '')
                    if 'Não Mapeável' in status:
                        continue

                classe = row.get('classe_edgv', '')
                tag_osm = row.get('tag_osm', '')

                if classe in ['N/A', '', None] or not tag_osm or tag_osm.strip() == '':
                    continue

                codigo_tipo_str = row.get('codigo_tipo_edgv', '')
                try:
                    codigo_tipo = int(codigo_tipo_str) if codigo_tipo_str and codigo_tipo_str != 'N/A' else None
                except ValueError:
                    codigo_tipo = None

                rule = MappingRule(
                    tag_expression=tag_osm,
                    classe_edgv=classe,
                    codigo_tipo=codigo_tipo,
                    nome_tipo=row.get('nome_tipo_edgv', ''),
                    tipo_geometria=row.get('tipo_geometria', ''),
                )

                expression = TagParser.parse_expression(tag_osm)
                if expression.groups:
                    self.rules.append((expression, rule))
                    count += 1

        return count

    def find_matching_rule(self, tags: Dict[str, str]) -> Optional[MappingRule]:
        for expression, rule in self.rules:
            if TagParser.matches(tags, expression):
                return rule
        return None


# ============================================================================
# UTILITARIOS DE GEOMETRIA
# ============================================================================

def get_geometry_suffix(geom_type: int) -> str:
    """Retorna o sufixo EDGV para o tipo de geometria FME."""
    if geom_type in [fmeobjects.FME_GEOM_POINT]:
        return 'p'
    if geom_type in [fmeobjects.FME_GEOM_LINE]:
        return 'l'
    if geom_type in [fmeobjects.FME_GEOM_POLYGON]:
        return 'a'
    return 'p'


# ============================================================================
# PROCESSADOR PRINCIPAL - FME PYTHON CALLER
# ============================================================================

class FeatureProcessor:
    """
    Processador para uso no FME PythonCaller.

    Configuracao no FME:
      Class or Function to Process Features: FeatureProcessor
    """

    def __init__(self):
        self.mapping = MappingManager()
        self.initialized = False
        self._initialize()

    def _initialize(self):
        """Carrega os CSVs de mapeamento."""
        if self.initialized:
            return

        self.mapping.load_csv(CSV_SHORTBREAD, 'shortbread')
        self.mapping.load_csv(CSV_EXTENSION, 'extension')
        self.initialized = True

    def _extract_tags(self, feature: fmeobjects.FMEFeature) -> Dict[str, str]:
        """Extrai as tags OSM da feature."""
        tags = {}
        for attr_name in feature.getAllAttributeNames():
            if attr_name.startswith('fme_') or attr_name.startswith('_'):
                continue
            if attr_name in ['osm_id', 'osm_type', 'osm_version', 'osm_timestamp',
                            'osm_changeset', 'osm_uid', 'osm_user']:
                continue

            value = feature.getAttribute(attr_name)
            if value is not None and str(value).strip() != '':
                tags[attr_name] = str(value)

        return tags

    def input(self, feature: fmeobjects.FMEFeature):
        """Recebe uma feature de entrada e processa."""

        # Extrair tags OSM
        tags = self._extract_tags(feature)
        if not tags:
            return

        # Encontrar regra de mapeamento
        rule = self.mapping.find_matching_rule(tags)
        if not rule:
            return

        # Detectar tipo de geometria
        geom = feature.getGeometry()
        if geom is None:
            return

        geom_suffix = get_geometry_suffix(feature.getGeometryType())

        # Verificar compatibilidade de geometria
        expected_suffix = rule.classe_edgv.strip()[-1:].lower()
        if geom_suffix != expected_suffix:
            return

        # Nome da tabela destino (classe EDGV diretamente, ex: cobter_vegetacao_a)
        table_name = rule.classe_edgv.strip()

        # Obter osm_id e osm_type
        osm_id = feature.getAttribute('osm_id')
        osm_type = feature.getAttribute('osm_type')

        # Obter nome
        nome = tags.get('name', tags.get('nome'))

        # Preparar observacao (tags em JSON)
        obs = json.dumps(tags, ensure_ascii=False)

        # Clonar a feature
        new_feature = feature.clone()

        # Limpar atributos antigos (tags OSM)
        for attr_name in list(new_feature.getAllAttributeNames()):
            if not attr_name.startswith('fme_'):
                new_feature.removeAttribute(attr_name)

        # Definir fme_feature_type (nome da tabela destino)
        new_feature.setFeatureType(table_name)
        new_feature.setAttribute("fme_feature_type", table_name)

        # Definir atributos EDGV
        if nome:
            new_feature.setAttribute('nome', nome)

        new_feature.setAttribute('tipo_code', rule.codigo_tipo if rule.codigo_tipo else 9999)

        if osm_id:
            new_feature.setAttribute('osm_id', int(osm_id))

        if osm_type:
            new_feature.setAttribute('osm_type', str(osm_type))

        new_feature.setAttribute('observacao', obs)

        self.pyoutput(new_feature)

    def close(self):
        pass
