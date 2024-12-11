from qgis.core import QgsFeature, QgsGeometry, QgsPoint, QgsPointXY, QgsProject, QgsMapLayer
from PyQt5.QtCore import QObject, pyqtSignal
import multiprocessing
from concurrent.futures import ThreadPoolExecutor
import json
import numpy as np
import itertools
from typing import Dict, List, Any
from functools import partial

class FeatureGenerator(QObject):
    # Sinais para comunicação entre threads
    progressUpdated = pyqtSignal(str, int)
    featureGenerated = pyqtSignal(object, object, str)
    
    def __init__(self):
        super().__init__()
        self.masterfile = None
        
    def get_optimal_workers(self):
        """Determina o número ótimo de workers baseado no hardware."""
        cpu_count = multiprocessing.cpu_count()
        return cpu_count + 1

    def load_masterfile(self, path: str):
        """Carrega o masterfile JSON."""
        with open(path, 'r', encoding='utf-8') as f:
            self.masterfile = json.load(f)

    def get_domain_values(self, domain_name: str) -> List[int]:
        """Retorna os códigos possíveis para um domínio específico."""
        for domain in self.masterfile['dominios']:
            if domain['nome'] == domain_name:
                return [v['code'] for v in domain['valores']]
        return []

    def get_allowed_domain_values(self, attr: Dict, domain_values: List[int], primitive_type: str) -> List[int]:
        """Filtra os valores de domínio baseado nas restrições."""
        if 'valores' not in attr:
            return domain_values

        valores = attr['valores']
        
        if isinstance(valores, list) and all(isinstance(x, int) for x in valores):
            return [v for v in domain_values if v in valores]
            
        if isinstance(valores, list) and all(isinstance(x, dict) for x in valores):
            allowed_codes = []
            for valor in valores:
                if 'primitivas' in valor and primitive_type in valor['primitivas']:
                    allowed_codes.append(valor['code'])
                elif 'primitivas' not in valor:
                    allowed_codes.append(valor['code'])
            return [v for v in domain_values if v in allowed_codes]
            
        if isinstance(valores, dict) and primitive_type in valores:
            return [v for v in domain_values if v in valores[primitive_type]]
            
        return domain_values

    def generate_attribute_combinations(self, class_def: Dict, primitive_type: str) -> List[Dict[str, Any]]:
        """Gera combinações de atributos em thread separada."""
        blacklist = {
            'visivel', 'exibir_lado_simbologia', 'sobreposto_transportes',
            'justificativa_txt', 'exibir_ponta_simbologia', 'dentro_de_massa_dagua',
            'dentro_massa_dagua', 'tipo_elemento_viario', 'material_construcao_elemento_viario',
            'posicao_pista_elemento_viario', 'posicao_rotulo', 'direcao_fixada',
            'em_galeria_bueiro', 'exibir_linha_rotulo', 'suprimir_bandeira'
        }
        
        attr_values = {}
        single_value_attrs = {}
        
        for attr in class_def['atributos']:
            if 'primitivas' in attr and primitive_type not in attr['primitivas']:
                continue
                
            attr_name = attr['nome']
            
            if attr_name in blacklist:
                if 'mapa_valor' in attr:
                    domain_values = self.get_domain_values(attr['mapa_valor'])
                    allowed_values = self.get_allowed_domain_values(attr, domain_values, primitive_type)
                    if allowed_values:
                        single_value_attrs[attr_name] = allowed_values[0]
                elif attr['tipo'] == 'varchar(255)':
                    single_value_attrs[attr_name] = 'Teste'
                elif attr['tipo'] in ['integer', 'real']:
                    single_value_attrs[attr_name] = 42
                continue
                
            if 'mapa_valor' in attr:
                domain_values = self.get_domain_values(attr['mapa_valor'])
                allowed_values = self.get_allowed_domain_values(attr, domain_values, primitive_type)
                if allowed_values:
                    attr_values[attr_name] = allowed_values
            elif attr['tipo'] == 'varchar(255)':
                attr_values[attr_name] = ['Teste']
            elif attr['tipo'] in ['integer', 'real']:
                attr_values[attr_name] = [42]
        
        combinations = []
        if attr_values:
            keys = attr_values.keys()
            values = attr_values.values()
            for combination in itertools.product(*values):
                attr_dict = dict(zip(keys, combination))
                attr_dict.update(single_value_attrs)
                combinations.append(attr_dict)
        else:
            combinations = [single_value_attrs] if single_value_attrs else []
        
        return combinations

    def create_test_geometry(self, primitive_type: str) -> QgsGeometry:
        """Cria geometria de teste."""
        if primitive_type == 'MultiPoint':
            return QgsGeometry.fromMultiPointXY([QgsPointXY(0, 0)])
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

    def process_combinations(self, class_def: Dict, primitive_type: str) -> List[Dict]:
        """Processa as combinações de atributos em thread separada."""
        return self.generate_attribute_combinations(class_def, primitive_type)

    def generate_test_features(self, layer, class_name: str, category: str, primitive_type: str):
        """Gera feições de teste usando threads para a primitiva específica da camada."""
        # Procura a classe no masterfile usando nome e categoria
        class_def = find_class_in_masterfile(self.masterfile, class_name, category)

        if not class_def:
            self.progressUpdated.emit(
                f"Classe {class_name} com categoria {category} não encontrada", 0
            )
            return

        # Verifica se a primitiva é válida para a classe
        if primitive_type not in class_def['primitivas']:
            self.progressUpdated.emit(
                f"Primitiva {primitive_type} não é válida para a classe {class_name}", 0
            )
            return

        # Cria a geometria uma única vez fora do loop
        geometry = self.create_test_geometry(primitive_type)
        
        # Processa combinações em thread separada
        with ThreadPoolExecutor(max_workers=self.get_optimal_workers()) as executor:
            future = executor.submit(self.process_combinations, class_def, primitive_type)
            combinations = future.result()
            
            if not combinations:
                feature = QgsFeature()
                if geometry:
                    feature.setGeometry(geometry)
                # Inicializa todos os atributos com None
                feature.setAttributes([None for field in layer.fields()])
                layer.addFeature(feature)
                return

            # Cria lista de feições reutilizando a mesma geometria
            features = []
            for attrs in combinations:
                feature = QgsFeature()
                if geometry:
                    feature.setGeometry(geometry)
                feature.setAttributes([attrs.get(field.name(), None) 
                                for field in layer.fields()])
                features.append(feature)
            
            # Adiciona todas as feições de uma vez
            layer.addFeatures(features)

def find_class_in_masterfile(masterfile: Dict, class_name: str, category: str) -> Dict:
    """
    Procura a classe no masterfile considerando nome e categoria.
    
    Args:
        masterfile: Dicionário do masterfile
        class_name: Nome da classe
        category: Categoria da classe
        
    Returns:
        Dict: Definição da classe ou None se não encontrada
    """
    # Procura nas classes principais
    for c in masterfile['classes']:
        if c['nome'] == class_name and c.get('categoria') == category:
            return c
            
    # Procura nas classes de extensão
    if 'extension_classes' in masterfile:
        for c in masterfile['extension_classes']:
            if c['nome'] == class_name and c.get('categoria') == category:
                return c
                
    return None

def extract_class_info_from_layer_name(layer_name: str) -> tuple:
    """
    Extrai nome da classe, categoria e tipo primitivo do nome da camada.
    
    Args:
        layer_name: Nome da camada (ex: 'centroide_elemento_hidrografico_p')
        
    Returns:
        tuple: (nome_classe, categoria, tipo_primitivo)
    """
    parts = layer_name.split('_')
    
    # O último elemento é sempre o tipo primitivo (p, l, a)
    primitive_suffix = parts[-1]
    primitive_type = {
        'p': 'MultiPoint',
        'l': 'MultiLinestring',
        'a': 'MultiPolygon'
    }.get(primitive_suffix)
    
    # O primeiro elemento é a categoria
    categoria = parts[0]
    
    # O restante (exceto último) forma o nome da classe
    nome_classe = '_'.join(parts[1:-1])
    
    return nome_classe, categoria, primitive_type

def main():
    # Instancia o gerador de feições
    generator = FeatureGenerator()
    
    # Conecta sinais
    generator.progressUpdated.connect(lambda msg, progress: print(msg))
    
    # Carrega o masterfile
    generator.load_masterfile('c:/Diniz/modelagens/modelagens_legadas/edgv_300_topo/1_3/master_file_300_topo_13.json')
    
    # Processa cada camada
    for layer in QgsProject.instance().mapLayers().values():
        if layer.type() != QgsMapLayer.VectorLayer:
            continue
            
        # Extrai informações do nome da camada
        class_name, category, primitive_type = extract_class_info_from_layer_name(layer.name())
        
        if not primitive_type:
            continue
        
        layer.startEditing()
        generator.generate_test_features(layer, class_name, category, primitive_type)
        layer.commitChanges()
        
        print(f"Feições de teste geradas para {layer.name()}")

main()