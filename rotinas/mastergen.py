# -*- coding: utf-8 -*-
import os
# from jinja2 import Environment, FileSystemLoader
import json
from collections import defaultdict

THIS_DIR = os.path.dirname(os.path.abspath(__file__))
class MasterGen():
    PostGIS, GPKG, Spatialite = range(3)
    def __init__(self, master_path):
        try:
            with open(master_path, 'r', encoding='utf-8') as master_file:
                self.master = json.load(master_file)
        except EOFError as e:
            print("Caught the EOF error.")
            raise e
        except IOError as e:
            print("Caught the I/O error.")
            raise e
        else:
            # TODO Validate JSON file against JsonSchema
            pass

    def buildSQL(self, dest, atributos_padrao=False, extension_classes=False, owner='postgres'):
        master = self.master
        sql = []
        sql.append(u"CREATE SCHEMA {0};".format(master["schema_dados"]))
        sql.append(u"CREATE SCHEMA {0};".format(master["schema_dominios"]))
        sql.append(u"")
        sql.append(u"CREATE EXTENSION postgis;")
        sql.append(u"SET search_path TO pg_catalog,public,{0},{1};".format(
            master["schema_dados"], master["schema_dominios"]))
        sql.append(u"")
        sql.append(u"CREATE TABLE public.db_metadata(")
        sql.append(u"\t edgvversion varchar(50) NOT NULL DEFAULT '{0}',".format(
            master["modelo"]))
        sql.append(u"\t dbimplversion varchar(50) NOT NULL DEFAULT '{0}',".format(
            master["versao"]))
        sql.append(u"\t CONSTRAINT edgvversioncheck CHECK (edgvversion = '{0}')".format(
            master["modelo"]))
        sql.append(u");")
        sql.append(u"INSERT INTO public.db_metadata (edgvversion, dbimplversion) VALUES ('{0}','{1}');".format(
            master["modelo"], master["versao"]))
        sql.append(u"")

        for dominio in master["dominios"]:
            sql.append(u"CREATE TABLE {0}.{1} (".format(
                master["schema_dominios"], dominio["nome"]))
            sql.append(u"\t code smallint NOT NULL,")
            sql.append(u"\t code_name text NOT NULL,")
            sql.append(
                u"\t filter text NOT NULL,") if "filtro" in dominio and dominio["filtro"] else None
            sql.append(
                u"\t CONSTRAINT {0}_pk PRIMARY KEY (code)".format(dominio["nome"]))
            sql.append(u");")
            sql.append(u"")

            for valor in dominio["valores"]:
                domain_value = u"{0} ({1})".format(valor["value"].replace("'", "''"), valor["code"])
                if "filtro" in dominio and dominio["filtro"]:
                    sql.append(u"INSERT INTO {0}.{1} (code,code_name, filter) VALUES ({2},'{3}','{4}');".format(master["schema_dominios"],
                                                                                                                dominio["nome"], valor["code"], domain_value, valor["valor_filtro"]))
                else:
                    sql.append(u"INSERT INTO {0}.{1} (code,code_name) VALUES ({2},'{3}');".format(master["schema_dominios"],
                                                                                                dominio["nome"], valor["code"], domain_value))

            if 'a_ser_preenchido' in master:
                domain_value = u"{0} ({1})".format(master["a_ser_preenchido"]["value"], master["a_ser_preenchido"]["code"])
                if "filtro" in dominio and dominio["filtro"]:
                    sql.append(u"INSERT INTO {0}.{1} (code,code_name, filter) VALUES ({2},'{3}','{3}');".format(master["schema_dominios"],
                                                                                                                dominio["nome"], master["a_ser_preenchido"]["code"], domain_value))
                else:
                    sql.append(u"INSERT INTO {0}.{1} (code,code_name) VALUES ({2},'{3}');".format(master["schema_dominios"],
                                                                                                dominio["nome"], master["a_ser_preenchido"]["code"], domain_value))

            sql.append(u"")

            if owner:
                sql.append(u"ALTER TABLE {0}.{1} OWNER TO {2};".format(master["schema_dominios"], dominio["nome"], owner))

            sql.append(u"")

        if extension_classes and "extension_classes" in master:
            master["classes"].extend(master["extension_classes"])

        for classe in master["classes"]:
            if atributos_padrao and "atributos_padrao" in master:
                classe["atributos"].extend(master["atributos_padrao"])
                
            for primitiva in classe["primitivas"]:
                if "geom_suffix" in classe:
                    class_name = "{0}{1}".format(classe["nome"], classe["geom_suffix"][primitiva])
                elif "geom_prefix" in classe:
                    class_name = "{1}{0}".format(classe["nome"], classe["geom_prefix"][primitiva])
                elif "geom_suffix" in master:
                    class_name = "{0}{1}".format(classe["nome"], master["geom_suffix"][primitiva])
                elif "geom_prefix" in master:
                    class_name = "{1}{0}".format(classe["nome"], master["geom_prefix"][primitiva])
                
                if classe["categoria"]:
                    class_name = "{0}_{1}".format(classe["categoria"], class_name)

                sql.append(u"CREATE TABLE {0}.{1}(".format(
                    master["schema_dados"], class_name))
                sql.append(u"\t {0} serial NOT NULL,".format(
                    master["nome_id"]))

                for atributo in classe["atributos"]:
                    if atributo["cardinalidade"] == "0..1":
                        sql.append(u"\t {0} {1},".format(
                            atributo["nome"], atributo["tipo"]))
                    elif atributo["cardinalidade"] == "1..1":
                        sql.append(u"\t {0} {1} NOT NULL,".format(
                            atributo["nome"], atributo["tipo"]))
                    elif atributo["cardinalidade"] == "0..*":
                        sql.append(u"\t {0} {1}[],".format(
                            atributo["nome"], atributo["tipo"]))
                    elif atributo["cardinalidade"] == "1..*":
                        sql.append(u"\t {0} {1}[] NOT NULL,".format(
                            atributo["nome"], atributo["tipo"]))

                sql.append(u"\t {0} geometry({1}, {2}),".format(
                    master["nome_geom"], primitiva, master["coord_sys"]))
                sql.append(u"\t CONSTRAINT {0}_pk PRIMARY KEY ({1})".format(class_name, master["nome_id"]))
                sql.append(u"\t WITH (FILLFACTOR = {0})".format(
                    master["fill_factor"]))
                sql.append(u");")
                sql.append(u"CREATE INDEX {0}_geom ON {1}.{0} USING gist ({2});".format(class_name,master["schema_dados"], master["nome_geom"]))

                sql.append(u"")

                if owner:
                    sql.append(u"ALTER TABLE {0}.{1} OWNER TO {2};".format(master["schema_dados"], class_name, owner))
                
                sql.append(u"")

                for atributo in classe["atributos"]:

                    if "mapa_valor" in atributo:
                        valores_att = None
                        if "valores" in atributo:
                            valores_att = [valor["code"] for valor in atributo["valores"]
                                        if ("primitivas" in valor and primitiva in valor["primitivas"]) or "primitivas" not in valor]

                        if atributo["cardinalidade"] == "0..1" or atributo["cardinalidade"] == "1..1":
                            sql.append(u"ALTER TABLE {1}.{0}".format(class_name, master["schema_dados"]))
                            sql.append(u"\t ADD CONSTRAINT {0}_{1}_fk FOREIGN KEY ({1})".format(class_name, atributo["nome"]))
                            sql.append(u"\t REFERENCES {1}.{0} (code) MATCH FULL".format(
                                atributo["mapa_valor"], master["schema_dominios"]))
                            sql.append(
                                u"\t ON UPDATE NO ACTION ON DELETE NO ACTION;")
                            sql.append(u"")
                            dominio = [dominio for dominio in master["dominios"] if "nome" in dominio and dominio["nome"] == atributo["mapa_valor"]][0]
                            dominio_att = [valor["code"] for valor in dominio["valores"]]

                            if valores_att and len(set(dominio_att).difference(valores_att)) > 0:
                                sql.append(u"ALTER TABLE {0}.{1}".format(master["schema_dados"], class_name))
                                sql.append(u"\t ADD CONSTRAINT {0}_{1}_check ".format(class_name, atributo["nome"]))

                                if 'a_ser_preenchido' in master:
                                    valores_att.append(
                                        master["a_ser_preenchido"]["code"])
                                    sql.append(u"\t CHECK ({0} = ANY(ARRAY[{1}])); ".format(atributo["nome"],
                                                                                            ", ".join(["{0} :: SMALLINT".format(valor) for valor in valores_att])))
                                else:
                                    sql.append(u"\t CHECK ({0} = ANY(ARRAY[{1}])); ".format(atributo["nome"],
                                                                                            ", ".join(["{0} :: SMALLINT".format(valor) for valor in valores_att])))

                                    sql.append(u"")

                            if master['a_ser_preenchido']:
                                sql.append(u"ALTER TABLE {1}.{0} ALTER COLUMN {2} SET DEFAULT {3};".format(class_name,
                                                                                                                master["schema_dados"], atributo["nome"],
                                                                                                                master["a_ser_preenchido"]["code"]))
                                sql.append(u"")

                        elif atributo["cardinalidade"] == "0..*" or atributo["cardinalidade"] == "1..*":

                            sql.append(u"ALTER TABLE {0}.{1}".format(master["schema_dados"], class_name))
                            sql.append(u"\t ADD CONSTRAINT {0}_{1}_check ".format(class_name, atributo["nome"]))

                            if 'a_ser_preenchido' in master:
                                valores_att.append(
                                    master["a_ser_preenchido"]["code"])
                                sql.append(u"\t CHECK ({0} <@ ANY(ARRAY[{1}])); ".format(atributo["nome"],
                                                                                        ", ".join(["{0} :: SMALLINT".format(valor) for valor in valores_att])))
                            else:
                                sql.append(u"\t CHECK ({0} <@ ANY(ARRAY[{1}])); ".format(atributo["nome"],
                                                                                        ", ".join(["{0} :: SMALLINT".format(valor) for valor in valores_att])))

                            sql.append(u"")

                            if master['a_ser_preenchido']:
                                sql.append(u"ALTER TABLE {1}.{0} ALTER COLUMN {2} SET DEFAULT ARRAY[{3} :: SMALLINT];".format(class_name,
                                                                                                                                    master["schema_dados"], atributo["nome"],
                                                                                                                                    master["a_ser_preenchido"]["code"]))
                                sql.append(u"")

        try:
            with open(dest, 'wb') as sql_file:
                sql_text = "\r".join(sql).encode('utf-8')
                sql_file.write(sql_text)
                return "Arquivo de modelagem SQL gerado com sucesso em {0}".format(dest)
        except Exception as e:
            return "Erro: {0}".format(e)

    def buildRCO(self, dest, template):
        master = self.master

        tipo_map = {}
        tipo_map["smallint"] = u"Mapa de valores (Inteiro)"
        tipo_map["varchar"] = u"Alfanumérico"
        tipo_map["integer"] = u"Inteiro"

        dominio_by_code = {}
        for dominio in master["dominios"]:
            dominio_by_code[dominio["nome"]] = {}
            for valor in dominio["valores"]:
                dominio_by_code[dominio["nome"]][valor["code"]] = {}
                dominio_by_code[dominio["nome"]][valor["code"]]["value"] = valor["value"]
                dominio_by_code[dominio["nome"]][valor["code"]]["descricao"] = valor["descricao"]

        dominio_by_class_attribute = {}
        for classe in master["classes"]:
            dominio_by_class_attribute[classe["nome"]] = {}
            for atributo in classe["atributos"]:
                if "valores" in atributo:
                    dominio_by_class_attribute[classe["nome"]][atributo["nome"]] = dominio_by_code[atributo["mapa_valor"]]

        for classe in master["classes"]:
            classe["print_nome"] = "_".join(
                [parte.title() for parte in classe["nome"].split("_")])
            geoms = [master["geom_suffix"][geom].upper() for geom in classe["primitivas"]]
            geoms = sorted(geoms, reverse=True)
            classe["print_geometrias"] = " ".join(geoms)

            for atributo in classe["atributos"]:
                atributo["print_tipo"] = tipo_map[atributo["tipo"].split("(")[0]]
                if "valores" in atributo:
                    atributo["rowspan"] = len(atributo["valores"])

                    for valor in atributo["valores"]:
                        valor["print_nome"] = u"{0} ({1})".format(
                            dominio_by_class_attribute[classe["nome"]][atributo["nome"]][valor["code"]]["value"], valor["code"])
                        valor["descricao"] = dominio_by_class_attribute[classe["nome"]
                                                                        ][atributo["nome"]][valor["code"]]["descricao"]

                    atributo["valores"].sort(key=lambda k: k['print_nome'])

                else:
                    atributo["valor_nome"] = u"A ser preenchido"
                    atributo["valor_descricao"] = u"-"

        try:
            with open(dest, 'w') as f:
                j2_env = Environment(loader=FileSystemLoader(THIS_DIR), trim_blocks=True)
                html = j2_env.get_template(template).render(
                    master=master
                )
                f.write(html.encode('utf-8'))
                return "Arquivo da RCO gerado com sucesso em {0}".format(dest)
        except Exception as e:
            return "Erro: {0}".format(e)

    def build_gpkg_SQL(self, dest, atributos_padrao=False, extension_classes=False):
        master = self.master
        domainDict = defaultdict(list)
        sql = []
        sql.append(u"CREATE TABLE db_metadata(")
        sql.append(u"\t edgvversion varchar(50) NOT NULL DEFAULT '{0}',".format(
            master["modelo"]))
        sql.append(u"\t dbimplversion varchar(50) NOT NULL DEFAULT '{0}',".format(
            master["versao"]))
        sql.append(u"\t CONSTRAINT edgvversioncheck CHECK (edgvversion = '{0}')".format(
            master["modelo"]))
        sql.append(u");")
        sql.append(u"INSERT INTO db_metadata (edgvversion, dbimplversion) VALUES ('{0}','{1}');".format(
            master["modelo"], master["versao"]))
        sql.append(u"")

        for dominio in master["dominios"]:
            sql.append(u"CREATE TABLE {0}_{1} (".format(
                master["schema_dominios"], dominio["nome"]))
            sql.append(u"\t code smallint NOT NULL,")
            sql.append(u"\t code_name text NOT NULL,")
            sql.append(
                u"\t filter text NOT NULL,") if "filtro" in dominio and dominio["filtro"] else None
            sql.append(
                u"\t CONSTRAINT {0}_pk PRIMARY KEY (code)".format(dominio["nome"]))
            sql.append(u");")
            sql.append(u"")

            for valor in dominio["valores"]:
                domainDict[dominio['nome']].append(valor['code'])
                if "filtro" in dominio and dominio["filtro"]:
                    sql.append(u"INSERT INTO {0}_{1} (code,code_name, filter) VALUES ({2},'{3}','{4}');".format(master["schema_dominios"],
                                                                                                                dominio["nome"], valor["code"], valor["value"].replace("'", "''"), valor["valor_filtro"]))
                else:
                    sql.append(u"INSERT INTO {0}_{1} (code,code_name) VALUES ({2},'{3}');".format(master["schema_dominios"],
                                                                                                dominio["nome"], valor["code"], valor["value"].replace("'", "''")))

            sql.append(u"")

        for classe in master["classes"]:
            if atributos_padrao and "atributos_padrao" in master:
                classe["atributos"].extend(master["atributos_padrao"])
                
            for primitiva in classe["primitivas"]:
                if "geom_suffix" in classe:
                    class_name = "{0}{1}".format(classe["nome"], classe["geom_suffix"][primitiva])
                elif "geom_prefix" in classe:
                    class_name = "{1}{0}".format(classe["nome"], classe["geom_prefix"][primitiva])
                elif "geom_suffix" in master:
                    class_name = "{0}{1}".format(classe["nome"], master["geom_suffix"][primitiva])
                elif "geom_prefix" in master:
                    class_name = "{1}{0}".format(classe["nome"], master["geom_prefix"][primitiva])
                
                if classe["categoria"]:
                    class_name = "{0}_{1}".format(classe["categoria"], class_name)

                sql.append(u"CREATE TABLE {0}_{1}(".format(
                    master["schema_dados"], class_name))
                sql.append(u"\t {0} INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,".format(
                    master["nome_id"]))

                for atributo in classe["atributos"]:
                    if atributo["cardinalidade"] == "0..1":
                        sql.append(u"\t {0} {1},".format(
                            atributo["nome"], atributo["tipo"]))
                    elif atributo["cardinalidade"] == "1..1":
                        sql.append(u"\t {0} {1} NOT NULL,".format(
                            atributo["nome"], atributo["tipo"]))
                    elif atributo["cardinalidade"] == "0..*":
                        sql.append(u"\t {0} TEXT,".format(
                            atributo["nome"]))
                    elif atributo["cardinalidade"] == "1..*":
                        sql.append(u"\t {0} {1} text NOT NULL,".format(
                            atributo["nome"]))

                sql.append(u"\t {0} {1}".format(
                    master["nome_geom"], primitiva, master["coord_sys"]))

                for atributo in classe["atributos"]:

                    if "mapa_valor" in atributo:
                        sql[-1] = sql[-1]+u","
                        valores_att = domainDict[atributo["mapa_valor"]]
                        checkConstraintList = [valor['code'] for valor in atributo['valores']] if 'valores' in atributo else []
                        if atributo["cardinalidade"] == "0..1" or atributo["cardinalidade"] == "1..1":
                            # sql.append(u"\t CONSTRAINT {0}_{1}_fk FOREIGN KEY ({1}) REFERENCES {3}_{2} (code)".format(
                            #     class_name, atributo["nome"], atributo["mapa_valor"], master["schema_dominios"]))
                            dominio_att = valores_att if checkConstraintList == [] else checkConstraintList
                            if len(dominio_att) > 0:
                                constraint_string = '('+' OR '.join(
                                        ['({0} = {1})'.format(atributo["nome"], i) for i in dominio_att]
                                    ) + ')'
                                sql.append(u"\t CONSTRAINT {0}_{1}_check CHECK {2}".format(
                                        class_name, atributo["nome"], constraint_string
                                    )
                                )
                sql.append(u");")
            
                #sql.append(u"SELECT CreateSpatialIndex('{1}_{0}', '{2}');".format(class_name,master["schema_dados"], master["nome_geom"]))
                sql.append(u"INSERT into gpkg_contents (table_name, data_type, identifier, description, min_x, min_y, max_x, max_y, srs_id) VALUES ('{0}_{1}', 'features','{0}_{1}', 'Camada {1} da EDGV', NULL, NULL, NULL, NULL, {2});".format(
                    master["schema_dados"], class_name, master["coord_sys"]
                ))
                sql.append(u"INSERT into gpkg_ogr_contents (table_name, feature_count) VALUES ('{table_schema}_{table_name}', 0);".format(
                    table_schema=master["schema_dados"],
                    table_name=class_name
                    )
                )
                sql.append(u"INSERT into gpkg_geometry_columns VALUES ('{0}_{1}', '{2}', '{3}', {4}, 0, 0 );".format(
                    master["schema_dados"], class_name, master["nome_geom"], primitiva.upper(), master["coord_sys"]
                ))
                sql.append(u"""CREATE TRIGGER "trigger_insert_feature_count_{0}_{1}" AFTER INSERT ON "{0}_{1}" BEGIN UPDATE gpkg_ogr_contents SET feature_count = feature_count + 1 WHERE lower(table_name) = lower('{0}_{1}'); END ;""".format(
                        master["schema_dados"], class_name
                    )
                )
                sql.append(u"""CREATE TRIGGER "trigger_delete_feature_count_{0}_{1}" AFTER DELETE ON "{0}_{1}" BEGIN UPDATE gpkg_ogr_contents SET feature_count = feature_count - 1 WHERE lower(table_name) = lower('{0}_{1}'); END ;""".format(
                        master["schema_dados"], class_name
                    )
                )
                sql.append(u"")

        try:
            with open(dest, 'w', encoding='utf-8') as sql_file:
                sql_text = "\r".join(sql)
                sql_file.write(sql_text)
                return "Arquivo de modelagem SQL gerado com sucesso em {0}".format(dest)
        except Exception as e:
            return "Erro: {0}".format(e)

    def build_SHP(self, dest):
        pass

    def buildTableMetadataDict(self, dest, outputDbType=PostGIS):
        schemaSep = "." if outputDbType == self.PostGIS else "_"
        domainTableDict = self.buildDomainTableDict(schemaSep)
        metadataDict = defaultdict(dict)
        for item in self.master["classes"]:
            attributeDomainDict = self.buildAttributeDomainDict(
                item["atributos"],
                domainTableDict
            )
            self.addTablesToMetadataDict(
                metadataDict,
                item,
                attributeDomainDict,
                outputDbType
            )
        with open(dest, 'w', encoding='utf-8') as output_json:
            output_json.write(
                json.dumps(metadataDict, indent=4, ensure_ascii=False)
            )
        

    def buildDomainTableDict(self, schemaSep):
        domainTableDict = defaultdict(dict)
        for dominio in self.master["dominios"]:
            domainSpecsDict = domainTableDict[dominio["nome"]]
            domainSpecsDict["references"] = schemaSep.join(
                [self.master["schema_dominios"], dominio["nome"]]
            )
            domainSpecsDict["refPk"] = "code"
            domainSpecsDict["otherKey"] = "value"
            domainSpecsDict["values"] = {valor["code"]:valor["value"] \
                    for valor in dominio["valores"] }
            
            domainSpecsDict["filterAttr"] = "filtro" \
                if "valor_filtro" in self.master["dominios"] else None
        return domainTableDict
    
    def buildAttributeDomainDict(self, attrList, domainTableDict):
        attrDomainDict = dict()
        for item in attrList:
            auxDict = dict()
            auxDict["name"] = item["nome"]
            auxDict["nullable"] = True \
                if item["cardinalidade"] in ["0..1", "0..*"] else False
            auxDict["column_type"] = item["tipo"]
            auxDict["isMulti"] = True \
                if "*" in item["cardinalidade"] else False
            if "mapa_valor" in item:
                auxDict.update(domainTableDict[item["mapa_valor"]])
            if "valores" in item:
                auxDict["constraintList"] = [] if "valores" not in item \
                    else [i["code"] for i in item["valores"]]
            attrDomainDict[item["nome"]] = auxDict
        return attrDomainDict

    def addTablesToMetadataDict(self, metadataDict, item, attributeDomainDict, outputDbType):
        for primitiva in item["primitivas"]:
            table_name = "{schema}{category}_{class_name}{geom_suffix}".format(
                schema = '' if outputDbType == self.PostGIS else self.master["schema_dados"]+'_',
                category=item["categoria"],
                class_name=item["nome"],
                geom_suffix=self.master["geom_suffix"][primitiva]
            )
            metadataDict[table_name]["table_schema"] = self.master["schema_dados"]
            metadataDict[table_name]["table_name"] = table_name
            metadataDict[table_name]["primary_key"] = "id"
            metadataDict[table_name]["geometry_column"] = self.master["nome_geom"]
            metadataDict[table_name]["gemetry_type"] = primitiva
            metadataDict[table_name]["columns"] = attributeDomainDict
            metadataDict[table_name]["sqlFilter"] = None

if __name__ == '__main__':
    import os
    outputFolder = 'edgv_3.0'
    masterFileName = 'masterfile300_dsgtools.json'
    outputPath = os.path.join(os.path.dirname(__file__), '..', outputFolder)
    masterFile = os.path.join(outputPath, masterFileName)
    outputFile = os.path.join(outputPath, 'edgv3_gpkg.sql')
    mg = MasterGen(masterFile)
    x=mg.build_gpkg_SQL(outputFile)
    # x = mg.buildTableMetadataDict(outputFile, outputDbType=MasterGen.GPKG)
    print(x)
