from qgis.core import QgsFeature, QgsGeometry, QgsPoint, QgsPointXY
import json
import itertools
from typing import Dict, List, Any

def load_masterfile(path: str) -> Dict:
    """Carrega e retorna o masterfile JSON."""
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)

def get_domain_values(masterfile: Dict, domain_name: str) -> List[int]:
    """Retorna os códigos possíveis para um domínio específico."""
    for domain in masterfile['dominios']:
        if domain['nome'] == domain_name:
            return [v['code'] for v in domain['valores']]
    return []

def get_allowed_domain_values(attr: Dict, domain_values: List[int], primitive_type: str) -> List[int]:
    """
    Filtra os valores de domínio baseado nas restrições definidas no atributo.
    
    Args:
        attr: Definição do atributo do masterfile
        domain_values: Lista de todos os valores possíveis do domínio
        primitive_type: Tipo de primitiva geométrica atual ('MultiPoint', 'MultiLinestring', 'MultiPolygon')
    
    Returns:
        Lista de valores permitidos do domínio
    """
    if 'valores' not in attr:
        return domain_values

    valores = attr['valores']
    
    # Caso 1: Lista simples de inteiros
    if isinstance(valores, list) and all(isinstance(x, int) for x in valores):
        return [v for v in domain_values if v in valores]
        
    # Caso 2: Lista de objetos com code e primitivas
    if isinstance(valores, list) and all(isinstance(x, dict) for x in valores):
        allowed_codes = []
        for valor in valores:
            if 'primitivas' in valor:
                if primitive_type in valor['primitivas']:
                    allowed_codes.append(valor['code'])
            else:
                allowed_codes.append(valor['code'])
        return [v for v in domain_values if v in allowed_codes]
        
    # Caso 3: Objeto com primitivas como chaves
    if isinstance(valores, dict):
        if primitive_type in valores:
            return [v for v in domain_values if v in valores[primitive_type]]
        return []
    
    return domain_values

def generate_attribute_combinations(masterfile: Dict, class_def: Dict, primitive_type: str) -> List[Dict[str, Any]]:
    """
    Gera todas as combinações possíveis de atributos para uma classe e tipo de primitiva.
    
    Args:
        masterfile: Dicionário com todo o conteúdo do masterfile
        class_def: Definição da classe específica do masterfile
        primitive_type: Tipo de primitiva geométrica ('MultiPoint', 'MultiLinestring', 'MultiPolygon')
    
    Returns:
        Lista de dicionários com as combinações de atributos
    """
    attr_values = {}
    
    for attr in class_def['atributos']:
        # Verifica se o atributo é válido para a primitiva atual
        if 'primitivas' in attr and primitive_type not in attr['primitivas']:
            continue
            
        if 'mapa_valor' in attr:
            # Obtém todos os valores possíveis do domínio
            domain_values = get_domain_values(masterfile, attr['mapa_valor'])
            
            # Filtra baseado nas restrições do atributo
            allowed_values = get_allowed_domain_values(attr, domain_values, primitive_type)
            
            if allowed_values:  # Só inclui se houver valores permitidos
                attr_values[attr['nome']] = allowed_values
                
        elif attr['tipo'] == 'varchar(255)':
            attr_values[attr['nome']] = ['Teste']
        elif attr['tipo'] in ['integer', 'real']:
            attr_values[attr['nome']] = [42]
            
    # Gera todas as combinações possíveis
    keys = attr_values.keys()
    values = attr_values.values()
    
    combinations = []
    for combination in itertools.product(*values):
        combinations.append(dict(zip(keys, combination)))
    
    return combinations

def create_test_geometry(primitive_type: str) -> QgsGeometry:
    """Cria uma geometria de teste baseada no tipo primitivo."""
    if primitive_type == 'MultiPoint':
        return QgsGeometry.fromMultiPointXY([
            QgsPointXY(0, 0)
        ])
    elif primitive_type == 'MultiLinestring':
        return QgsGeometry.fromMultiPolylineXY([[
            QgsPointXY(0, 0),
            QgsPointXY(1, 1),
            QgsPointXY(2, 0)
        ]])
    elif primitive_type == 'MultiPolygon':
        return QgsGeometry.fromMultiPolygonXY([[
            [QgsPointXY(0, 0),
             QgsPointXY(2, 0),
             QgsPointXY(2, 2),
             QgsPointXY(0, 2),
             QgsPointXY(0, 0)]
        ]])
    return None

def generate_test_features(layer, masterfile: Dict, class_name: str):
    """Gera feições de teste para uma camada específica."""
    # Encontra a definição da classe no masterfile
    class_def = None
    for c in masterfile['classes']:
        if c['nome'] == class_name:
            class_def = c
            break
            
    if not class_def:
        print(f"Classe {class_name} não encontrada no masterfile")
        return
        
    # Gera combinações de atributos
    attr_combinations = generate_attribute_combinations(masterfile, class_def)
    
    # Para cada primitiva geométrica permitida
    for primitive in class_def['primitivas']:
        # Para cada combinação de atributos
        for attrs in attr_combinations:
            # Cria a feição
            feature = QgsFeature()
            
            # Define a geometria
            geom = create_test_geometry(primitive)
            if geom:
                feature.setGeometry(geom)
            
            # Define os atributos
            feature.setAttributes([attrs.get(field.name(), None) 
                                 for field in layer.fields()])
            
            # Adiciona a feição à camada
            layer.addFeature(feature)
    
    # Commit das alterações
    layer.commitChanges()

def main():
    # Carrega o masterfile
    masterfile = load_masterfile('master_file_300_topo_14.json')
    
    # Para cada camada no projeto
    for layer in QgsProject.instance().mapLayers().values():
        if layer.type() != QgsMapLayer.VectorLayer:
            continue
            
        # Extrai o nome da classe do nome da camada
        class_name = layer.name().split('_')[0]  # Ajuste conforme sua nomenclatura
        
        # Inicia a edição da camada
        layer.startEditing()
        
        # Gera as feições de teste
        generate_test_features(layer, masterfile, class_name)
        
        print(f"Feições de teste geradas para {layer.name()}")

# Executa o script
main()