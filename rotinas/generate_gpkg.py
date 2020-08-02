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


class SqlParser():

    def __init__(self, path):
        with open(path, 'r') as sql:
            self.sql = sql.read()

    def getCreateTables(self):
        return re.findall(r'(?s)CREATE TABLE edgv\.([A-Za-z_]+)\(\n(.+?)(?=\n\);)', self.sql)

    def parseFields(self, tableIter):
        fields = []
        keys = tableIter.strip(' ').replace(
            '\n', '').replace('\t', '').split(',')
        for key in keys:
            splits = key.split(' ')
            if len(splits) <= 2:
                continue
            elif 'VARCHAR' in splits[2] or 'varchar' in splits[2]:
                fields.append((splits[1], ogr.OFTString))
            elif 'smallint' in splits[2]:
                fields.append((splits[1], ogr.OFTInteger))
            elif 'real' in splits[2]:
                fields.append((splits[1], ogr.OFTReal))
            elif 'integer' in splits[2]:
                fields.append((splits[1], ogr.OFTInteger))
            elif 'timestamp' in splits[2]:
                fields.append((splits[1], ogr.OFTDateTime))
            elif 'boolean' in splits[2]:
                fields.append((splits[1], ogr.OFSTBoolean))
            else:
                continue
        return fields

    def getGeomType(self, classe):
        suffix = classe.split('_')[-1]
        if suffix == 'a':
            return ogr.wkbMultiPolygon
        elif suffix == 'l':
            return ogr.wkbMultiLineString
        elif suffix == 'p':
            return ogr.wkbMultiPoint

def getGeomType(geom_type):
    mapGeomType = {
        'MultiPoint': ogr.wkbMultiPoint,
        'MultiLinestring': ogr.wkbMultiLineString,
        'MultiPolygon': ogr.wkbMultiPolygon
    }
    return mapGeomType[geom_type]

def getAttrDataType(x):
    mapDataType = {
        'boolean': (ogr.OFTInteger, ogr.OFSTBoolean),
        'timestamp': (ogr.OFTDateTime, ogr.OFSTNone),
        'smallint': (ogr.OFTInteger, ogr.OFSTInt16),
        'integer': (ogr.OFTInteger, ogr.OFSTNone),
        'real': (ogr.OFTReal, ogr.OFSTNone)
    }
    # Needs to return varchar with size
    if str(x).lower().startswith('varchar'):
        length = re.search(r'varchar\((.+)\)', x)
        return (ogr.OFTString, ogr.OFSTNone ,length.group(1))
    else:
        return mapDataType[x]


parser = SqlParser(SQL)

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

# ds = ogr.GetDriverByName('GPKG').CreateDataSource(output, options = dataset_options)

ds = gdal.GetDriverByName('GPKG').Create(str(output), 0,0,0,0)
# print(full_codelist)

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

# # Insert domain restrictions
# lyr_domain = ds.CreateLayer('domain', geom_type = ogr.wkbNone, options=layer_options)
# lyr_domain.CreateField(ogr.FieldDefn('classe', ogr.OFTString))
# lyr_domain.CreateField(ogr.FieldDefn('keylist', ogr.OFTString))
# for item in full_codelist:
#     feat = ogr.Feature(lyr_domain.GetLayerDefn())
#     feat['classe'] = item[0]
#     feat['keylist'] = str(item[1])
#     lyr_domain.CreateFeature(feat)
