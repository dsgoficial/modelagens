# -*- coding: utf-8 -*-

import sys
import json
from osgeo import gdal
from osgeo import ogr
from osgeo import osr
from sqlParser import SqlParser

# Options
gdal.SetConfigOption('CREATE_METADATA_TABLES', 'NO')
dataset_options = ['VERSION=1.2', 'ADD_GPKG_OGR_CONTENTS=YES']
layer_options = ['SPATIAL_INDEX=YES']
output = 'edgv30.gpkg'

parser = SqlParser('edgv30.sql')
with open('masterfile_edgv30.json', 'r') as f:
    mf = json.load(f)

srs = osr.SpatialReference()
srs.ImportFromEPSG(mf['coord_sys'])

# Organizing masterfile to get domain restrictions
full_codelist = []
for classe in mf['classes']:
    attr_in_class = []
    for attr in classe['atributos']:
        if attr.get('mapa_valor'):
            if attr.get('valores'):
                value_map = [x['code'] for x in attr['valores']]
            else:
                domain = [x for x in mf['dominios'] if x['nome'] == attr['mapa_valor']][0]
                value_map = [x['code'] for x in domain['valores']]
            valueSet = (attr['nome'], value_map)
            attr_in_class.append(valueSet)
    classSet = (classe['nome'], attr_in_class)
    full_codelist.append(classSet)

ds = ogr.GetDriverByName('GPKG').CreateDataSource(output, options = dataset_options)

# Insert classes
for item in parser.getCreateTables():
    lyr = ds.CreateLayer(item[0], geom_type = parser.getGeomType(item[0]), options = layer_options, srs = srs)
    for field in parser.parseFields(item[1]):
        lyr.CreateField(ogr.FieldDefn(field[0], field[1]))

# Insert domain restrictions
lyr_domain = ds.CreateLayer('domain', geom_type = ogr.wkbNone, options=layer_options)
lyr_domain.CreateField(ogr.FieldDefn('classe', ogr.OFTString))
lyr_domain.CreateField(ogr.FieldDefn('keylist', ogr.OFTString))
for item in full_codelist:
    feat = ogr.Feature(lyr_domain.GetLayerDefn())
    feat['classe'] = item[0]
    feat['keylist'] = str(item[1])
    lyr_domain.CreateFeature(feat)