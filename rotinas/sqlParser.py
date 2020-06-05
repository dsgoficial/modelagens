import re
from osgeo import ogr

class SqlParser():

    def __init__(self, path):
        with open(path, 'r') as sql:
            self.sql = sql.read()

    def getCreateTables(self):
        return re.findall(r'(?s)CREATE TABLE edgv\.([A-Za-z_]+)\(\n(.+?)(?=\n\);)', self.sql)
        
    def parseFields(self, tableIter):
        fields = []
        keys = tableIter.strip(' ').replace('\n', '').replace('\t', '').split(',')
        for key in keys:
            splits = key.split(' ')
            if len(splits) <= 2:
                continue
            elif 'VARCHAR' in splits[2] or 'varchar' in splits[2]:
                fields.append((splits[1], ogr.OFTString))
            elif 'smallint' in splits[2]:
                fields.append((splits[1], ogr.OFTInteger))
            elif 'timestamp' in splits[2]:
                fields.append((splits[1], ogr.OFTDateTime))
            else:
                continue
        return fields

    def getGeomType(self, classe):
        suffix = classe.split('_')[-1]
        if suffix == 'a':
            return ogr.wkbPolygon
        elif suffix == 'l':
            return ogr.wkbLineString
        elif suffix == 'p':
            return ogr.wkbPoint

if __name__ == '__main__':
    parser = SqlParser('edgv30.sql')
    for item in parser.getCreateTables():
        print(parser.parseFields(item[1]))
        print(item[0])