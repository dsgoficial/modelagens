# -*- coding: utf-8 -*-

import sys
import json
import re
from pathlib import Path
from osgeo import gdal, ogr, osr

SQL = Path(__file__, '../../edgv_300/edgv_300.sql').resolve()
MASTERFILE = Path(__file__, '../../edgv_300/master_file_300.json').resolve()
output = Path.cwd() / 'teste.gpkg'

# Options
gdal.SetConfigOption('CREATE_METADATA_TABLES', 'NO')
dataset_options = ['VERSION=1.2', 'ADD_GPKG_OGR_CONTENTS=YES']
layer_options = ['SPATIAL_INDEX=YES']

with open(MASTERFILE, 'r') as f:
    mf = json.load(f)

srs = osr.SpatialReference()
srs.ImportFromEPSG(mf['coord_sys'])

def getGeomType(geom_type):
    mapGeomType = {
        'MultiPoint': ogr.wkbMultiPoint,
        'MultiLinestring': ogr.wkbMultiLineString,
        'MultiPolygon': ogr.wkbMultiPolygon
    }
    return mapGeomType[geom_type]

def getAttrDataType(data_type):
    mapDataType = {
        'boolean': (ogr.OFTInteger, ogr.OFSTBoolean),
        'timestamp': (ogr.OFTDateTime, ogr.OFSTNone),
        'smallint': (ogr.OFTInteger, ogr.OFSTInt16),
        'integer': (ogr.OFTInteger, ogr.OFSTNone),
        'real': (ogr.OFTReal, ogr.OFSTNone)
    }
    if str(data_type).lower().startswith('varchar'):
        length = re.search(r'varchar\((.+)\)', data_type)
        return (ogr.OFTString, ogr.OFSTNone ,length.group(1))
    else:
        return mapDataType[data_type]

# Organizing masterfile to get domain restrictions
full_codelist = []
for classe in mf['classes']:
    for prim in classe['primitivas']:
        attr_in_class = []
        for attr in classe['atributos']:
            if attr.get('mapa_valor'):
                if attr.get('valores'):
                    value_map = [x['code'] for x in attr['valores']]
                else:
                    domain = [x for x in mf['dominios']
                                if x['nome'] == attr['mapa_valor']][0]
                    value_map = [x['code'] for x in domain['valores']]
                valueSet = (attr['nome'],getAttrDataType(attr['tipo']), value_map)
                attr_in_class.append(valueSet)
            else:
                valueSet = (attr['nome'], getAttrDataType(attr['tipo']))
                attr_in_class.append(valueSet)
        classSet = (
            f"{mf['schema_dados']}_{classe['nome']}{mf['geom_suffix'][prim]}",
            getGeomType(prim),
            attr_in_class)
        full_codelist.append(classSet)

# print(full_codelist)

ds = gdal.GetDriverByName('GPKG').Create(str(output), 0,0,0,0)

# Creating layers
for item in full_codelist:
    lyr = ds.CreateLayer(item[0], geom_type = item[1], options = layer_options, srs = srs)
    for field in item[2]:
        defn = ogr.FieldDefn(field[0])
        typ, styp, *extra = field[1]
        defn.SetType(typ)
        if styp:
            defn.SetSubType(styp)
        if extra and typ == ogr.OFTString:
            defn.SetWidth(int(extra[0]))
        lyr.CreateField(defn)

# Inserting domain restrictions
lyr_domain = ds.CreateLayer('domain', geom_type = ogr.wkbNone, options=layer_options)
lyr_domain.CreateField(ogr.FieldDefn('classe', ogr.OFTString))
lyr_domain.CreateField(ogr.FieldDefn('keylist', ogr.OFTString))
for item in full_codelist:
    feat = ogr.Feature(lyr_domain.GetLayerDefn())
    fn = map(lambda x: x[0] if len(x) == 2 else (x[0], x[-1]), item[2])
    feat['classe'] = item[0]
    feat['keylist'] = str(list(fn))
    lyr_domain.CreateFeature(feat)

# Inserting metadata table
lyr_metadata = ds.CreateLayer('metadata', geom_type = ogr.wkbNone, options=layer_options)
lyr_metadata.CreateField(ogr.FieldDefn('item', ogr.OFTString))
lyr_metadata.CreateField(ogr.FieldDefn('version', ogr.OFTString))
feat = ogr.Feature(lyr_metadata.GetLayerDefn())
feat['item'] = 'Generator version'
feat['version'] = '0.0'
lyr_metadata.CreateFeature(feat)