import json
from qgis.PyQt.QtCore import QVariant
# Coloque o caminho do arquivo JSON Para leitura
json_path = 'D:\\Desenvolvimento\\modelagens\\edgv_300\\master_file_300_shp.json' 
# Coloque a pasta onde deseja que os arquivos shp sejam salvos.
folder_to_save = 'D:\\Desenvolvimento\\modelagens\\edgv_300\\shp300\\'


class ParserSHP():
	def __init__(self, coord_sys, nome_id):
		self.coord_sys = coord_sys
		self.nome_id = nome_id
		
	def createSHP(self, primitiva):
		#CRS = self.grid_layer.crs().postgisSrid()		
		#URI = shape_type + "Polygon?crs=epsg:"+str(CRS)+"&field=ID:integer""&index=yes"
		URI = primitiva + "?crs=epsg:" + str(self.coord_sys)+"&field=" + self.nome_id +":integer""&index=yes"
		layer_shp = QgsVectorLayer(URI,"new_layer","memory")
		return layer_shp


	def addFields(self,layer, fields):
		data_provider = layer.dataProvider()
		layer.startEditing()
		qgsfield_list = []
		for field in fields:
			nome			= field['nome']
			tipo			= field['tipo']
			descricao		= field['descricao']
			cardinalidade	= field['cardinalidade']  
			data_type = None
			if 'varchar' in tipo:
				data_type = QVariant.String
			elif 'integer' in tipo:
				data_type = QVariant.Int
			elif 'real' in tipo:
				data_type = QVariant.Double
			elif 'bool' in tipo:
				data_type = QVariant.Bool
			else:
				break
			if '(' in tipo:
				length = int(((tipo.split('(')[1]).split(')'))[0])
				qgsfield_list.append(QgsField(name=nome, type=data_type, len= length))
			else:
				qgsfield_list.append(QgsField(name=nome, type=data_type))
		data_provider.addAttributes(qgsfield_list)
		layer.updateFields()
		layer.commitChanges()
		return layer


with open(json_path) as json_file:
	data = json.load(json_file)
	coord_sys	= data['coord_sys']
	geom_suffix	= data['geom_suffix']
	nome_id		= data['nome_id']

	shpParser = ParserSHP(coord_sys, nome_id)
	classes_criar = len(data['classes'])
	print('Classes para criar SHP:' + str(classes_criar))
	steps = round(classes_criar/10)
	for i, classe in enumerate(data['classes']):
		if (i>0) and (i % steps == 0):
			print('Percentual Concluido: '+  str(round((i/classes_criar)*100)) + ' %')
		classe_nome 		=  classe['nome']
		classe_categoria 	=  classe['categoria']
		classe_descricao 	=  classe['descricao']
		classe_primitivas 	=  classe['primitivas']
		new_layer 			= None
		for primitiva in classe_primitivas:
			atributos 	=  classe['atributos']
			URI = primitiva + "?crs=epsg:" + str(coord_sys)+"&field=" + nome_id +":integer""&index=yes"
			#			URI = "Polygon?crs=epsg:"+str(coord_sys)+"&field=" + nome_id +":integer""&index=yes"
			new_layer = shpParser.createSHP(primitiva)
			new_layer = shpParser.addFields(new_layer, atributos) 
			path = folder_to_save + classe_categoria+ "_" + classe_nome + geom_suffix[primitiva] + '.shp'
			
			crs = QgsCoordinateReferenceSystem(int(coord_sys), QgsCoordinateReferenceSystem.PostgisCrsId)
			_writer = QgsVectorFileWriter.writeAsVectorFormat(new_layer ,path,"utf-8",crs,"ESRI Shapefile")
			QgsProject.instance().addMapLayer(new_layer)
			QgsProject.instance().removeMapLayer(new_layer.id())

