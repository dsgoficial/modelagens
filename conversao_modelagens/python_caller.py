import fme
import fmeobjects
import copy
import sys
import os
import json

class FeatureProcessor(object):
    def __init__(self):
        self.mappingDict = self.buildFileDict(FME_MacroValues['JsonMapeamento'])
        self.mappingType = FME_MacroValues['direcao']

    def buildFileDict(self, mappingPath):
        with open(mappingPath, 'r', encoding='utf-8') as file:
            mapDict = json.loads(file.read())
        return mapDict

    def buildFeatureDict(self, feature):
        featDict = dict()
        for attr in feature.getAllAttributeNames():
            if attr == 'fme_feature_type' or ('multi_writer' not in attr and 'multi_reader_' not in attr and 'fme_' not in attr and 'postgis_' not in attr):
                if feature.getAttribute(attr) or feature.getAttribute(attr) == 0:
                    featDict[attr] = feature.getAttribute(attr)
                else:
                    featDict[attr] = None
        if feature.performFunction('@GeometryType()') == 'fme_polygon' or feature.performFunction('@GeometryType()') == 'fme_donut':
            featDict["$GEOM_TYPE"] = 'POLYGON'
        elif feature.performFunction('@GeometryType()') == 'fme_line':
            featDict["$GEOM_TYPE"] = 'LINESTRING'
        elif feature.performFunction('@GeometryType()') == 'fme_point':
            featDict["$GEOM_TYPE"] = 'POINT'
        else:
             featDict["INVALID_GEOM"] = True
        return featDict

    def evaluateExpression(self, featDict, expression):
        return expression["nome_atributo"] in featDict and u"{0}".format(featDict[expression["nome_atributo"]]) == u"{0}".format(expression["valor"])

    def evaluateFilter(self, featDict, filter_condition):
        if "$and" in filter_condition:
            return all([self.evaluateFilter(featDict, condition) for condition in filter_condition["$and"]])
        elif "$or" in filter_condition:
            return any([self.evaluateFilter(featDict, condition) for condition in filter_condition["$or"]])
        elif "$not" in filter_condition:
            return not self.evaluateFilter(featDict, filter_condition["$not"])
        else:
            return self.evaluateExpression(featDict, filter_condition)

    def convertFeature(self, featDict):
        if self.mappingType == "ida":
            key_attr_origin = "attr_ida"
            key_attr_destiny = "attr_volta"
            key_value_origin = "valor_ida"
            key_value_destiny = "valor_volta"
            key_default = "atributos_default_ida"
            key_filter = "filtro_ida"
            key_class_origin = "classe_ida"
            key_class_destiny = "classe_volta"
            key_group_origin = "tupla_ida"
            key_group_destiny = "tupla_volta"
            key_affix_origin = "afixo_geom_ida"
            key_affix_destiny = "afixo_geom_volta"
            key_schema_origin = "schema_ida"
            key_schema_destiny = "schema_volta"
            key_class_affix_origin = "com_afixo_geom_ida"
            key_class_affix_destiny = "com_afixo_geom_volta"
            key_class_schema_origin = "com_schema_ida"
            key_class_schema_destiny = "com_schema_volta"
            key_agregar = "agregar_geom_ida"
        else:
            key_attr_origin = "attr_volta"
            key_attr_destiny = "attr_ida"
            key_value_origin = "valor_volta"
            key_value_destiny = "valor_ida"
            key_default = "atributos_default_volta"
            key_filter = "filtro_volta"
            key_class_origin = "classe_volta"
            key_class_destiny = "classe_ida"
            key_group_origin = "tupla_volta"
            key_group_destiny = "tupla_ida"
            key_affix_origin = "afixo_geom_volta"
            key_affix_destiny = "afixo_geom_ida"
            key_schema_origin = "schema_volta"
            key_schema_destiny = "schema_ida"
            key_class_affix_origin = "com_afixo_geom_volta"
            key_class_affix_destiny = "com_afixo_geom_ida"
            key_class_schema_origin = "com_schema_volta"
            key_class_schema_destiny = "com_schema_ida"
            key_agregar = "agregar_geom_volta"

        featDict["fme_feature_type_original"] = featDict["fme_feature_type"]

        if key_schema_origin in self.mappingDict and self.mappingDict[key_schema_origin]:
            featDict["fme_feature_type"] = featDict["fme_feature_type"][len(self.mappingDict[key_schema_origin])+1:]
        
        featDict["fme_feature_type_sem_schema"] = featDict["fme_feature_type"]

        if key_affix_origin in self.mappingDict and 'tipo' in self.mappingDict[key_affix_origin] and self.mappingDict[key_affix_origin]['tipo'] == 'sufixo':
            featDict["fme_feature_type"] = featDict["fme_feature_type"][:-len(self.mappingDict[key_affix_origin][featDict["$GEOM_TYPE"]])]
            featDict["fme_feature_type_sem_afixo"] = featDict["fme_feature_type_original"][:-len(self.mappingDict[key_affix_origin][featDict["$GEOM_TYPE"]])]

        if key_affix_origin in self.mappingDict and 'tipo' in self.mappingDict[key_affix_origin] and self.mappingDict[key_affix_origin]['tipo'] == 'prefixo':
            featDict["fme_feature_type"] = featDict["fme_feature_type"][len(self.mappingDict[key_affix_origin][featDict["$GEOM_TYPE"]]):]
            featDict["fme_feature_type_sem_afixo"] = featDict["fme_feature_type_original"][len(self.mappingDict[key_affix_origin][featDict["$GEOM_TYPE"]]):]

        should_map = False
        for classmap in self.mappingDict['mapeamento_classes']:
            if "sentido" not in classmap or ("sentido" in classmap and classmap["sentido"] == self.mappingType):
                if key_class_affix_origin in classmap and classmap[key_class_affix_origin] and key_class_schema_origin in classmap and classmap[key_class_schema_origin]:
                    class_name = featDict["fme_feature_type_original"]
                elif key_class_affix_origin in classmap and classmap[key_class_affix_origin]:
                    class_name = featDict["fme_feature_type_sem_schema"]
                elif key_class_schema_origin in classmap and classmap[key_class_schema_origin]:
                    class_name = featDict["fme_feature_type_sem_afixo"]
                else:
                     class_name = featDict["fme_feature_type"]
                
                if classmap[key_class_origin] == class_name:
                    if key_filter in classmap:
                        if not self.evaluateFilter(featDict, classmap[key_filter]):
                            continue
                    should_map = True
        if not should_map:
            featDict["CLASS_NOT_FOUND"] = True
            return featDict

        mappedFeat = copy.deepcopy(featDict)

        if key_default in self.mappingDict:
            for default in self.mappingDict[key_default]:
                mappedFeat[default["nome_atributo"]] = default["valor"]

        if 'mapeamento_atributos' in self.mappingDict:
            for attmap in self.mappingDict['mapeamento_atributos']:
                if attmap[key_attr_origin] in featDict:
                    mappedFeat[attmap[key_attr_destiny]] = featDict[attmap[key_attr_origin]]
                    if "traducao" in attmap:
                        for valuemap in attmap["traducao"]:
                            if u"{0}".format(valuemap[key_value_origin]) == u"{0}".format(featDict[attmap[key_attr_origin]]) and ("sentido" not in valuemap or ("sentido" in valuemap and valuemap["sentido"] == self.mappingType)):
                                mappedFeat[attmap[key_attr_destiny]] = valuemap[key_value_destiny]

        if 'mapeamento_classes' in self.mappingDict:
            for classmap in self.mappingDict['mapeamento_classes']:
                if "sentido" not in classmap or ("sentido" in classmap and classmap["sentido"] == self.mappingType):
                    if key_class_affix_origin in classmap and classmap[key_class_affix_origin] and key_class_schema_origin in classmap and classmap[key_class_schema_origin]:
                        class_name = featDict["fme_feature_type_original"]
                    elif key_class_affix_origin in classmap and classmap[key_class_affix_origin]:
                        class_name = featDict["fme_feature_type_sem_schema"]
                    elif key_class_schema_origin in classmap and classmap[key_class_schema_origin]:
                        class_name = featDict["fme_feature_type_sem_afixo"]
                    else:
                        class_name = featDict["fme_feature_type"]
                    
                    if classmap[key_class_origin] == class_name:
                        if key_filter in classmap:
                            if not self.evaluateFilter(featDict, classmap[key_filter]):
                                continue

                        mappedFeat["fme_feature_type"] = classmap[key_class_destiny]

                        if key_class_affix_destiny in classmap and classmap[key_class_affix_destiny]:
                            pass
                        elif key_affix_destiny in self.mappingDict and 'tipo' in self.mappingDict[key_affix_destiny]:
                            if self.mappingDict[key_affix_destiny]['tipo'] == 'sufixo':
                                mappedFeat["fme_feature_type"] = mappedFeat["fme_feature_type"] + self.mappingDict[key_affix_destiny][featDict["$GEOM_TYPE"]]

                            if self.mappingDict[key_affix_destiny]['tipo'] == 'prefixo':
                                mappedFeat["fme_feature_type"] = self.mappingDict[key_affix_destiny][featDict["$GEOM_TYPE"]] + mappedFeat["fme_feature_type"]
                        
                        if key_class_schema_destiny in classmap and classmap[key_class_schema_destiny]:
                            pass
                        elif key_schema_destiny in self.mappingDict and self.mappingDict[key_schema_destiny]:
                            mappedFeat["fme_feature_type"] = self.mappingDict[key_schema_destiny] + '.' + mappedFeat["fme_feature_type"]


                        if key_default in classmap:
                            for default in classmap[key_default]:
                                mappedFeat[default["nome_atributo"]] = default["valor"]
                    
                        if "mapeamento_atributos" in classmap:
                            for attmap in classmap['mapeamento_atributos']:
                                if attmap[key_attr_origin] in featDict:
                                    if attmap[key_attr_destiny] not in mappedFeat:
                                        mappedFeat[attmap[key_attr_destiny]] = featDict[attmap[key_attr_origin]]
                                    if "traducao" in attmap:
                                        for valuemap in attmap["traducao"]:
                                            if u"{0}".format(valuemap[key_value_origin]) == u"{0}".format(featDict[attmap[key_attr_origin]]) and ("sentido" not in valuemap or ("sentido" in valuemap and valuemap["sentido"] == self.mappingType)):
                                                mappedFeat[attmap[key_attr_destiny]] = valuemap[key_value_destiny]
                        
                        if "mapeamento_multiplo" in classmap:
                            for attmap in classmap['mapeamento_multiplo']:
                                if "sentido" not in attmap or ("sentido" in attmap and attmap["sentido"] == self.mappingType):
                                    if all([self.evaluateExpression(featDict, condition) for condition in attmap[key_group_origin]]):
                                        for valuemap in attmap[key_group_destiny]:
                                            if "concatenar" in valuemap and valuemap["concatenar"] and valuemap["nome_atributo"] in mappedFeat and mappedFeat[valuemap["nome_atributo"]]:
                                                mappedFeat[valuemap["nome_atributo"]] = mappedFeat[valuemap["nome_atributo"]] + ' | ' + valuemap["valor"]
                                            else:
                                                mappedFeat[valuemap["nome_atributo"]] = valuemap["valor"]
                        
                        if key_agregar in classmap:
                            mappedFeat["AGGREGATE_GEOM"] = classmap[key_agregar]
                        elif key_agregar in self.mappingDict:
                            mappedFeat["AGGREGATE_GEOM"] = self.mappingDict[key_agregar]
                        
                        break
                                    
        return mappedFeat

    def mapDictToFeature(self, feat, featDict):
        for attr, value in featDict.items():
            if value or value == 0:
                feat.setAttribute(attr, u'{0}'.format(value))
            else:
                feat.setAttributeNullWithType(attr,0)
        if "AGGREGATE_GEOM" in featDict and featDict["AGGREGATE_GEOM"]:
            feat.buildAggregateFeat([feat])
        return feat

    def input(self,feature):
        if feature.performFunction('@GeometryType()') == 'fme_aggregate':
            features = feature.splitAggregate(True)
        else:
            features = [feature]
        for simple_feature in features:
            feat = self.buildFeatureDict(simple_feature)
            if "INVALID_GEOM" in feat and not feat["INVALID_GEOM"]:
                simple_feature.setAttribute("INVALID_GEOM", u'True')
                self.pyoutput(simple_feature)
                continue
            
            outputFeatDict = self.convertFeature(feat)
            if "CLASS_NOT_FOUND" in outputFeatDict and not outputFeatDict["CLASS_NOT_FOUND"]:
                simple_feature.setAttribute("CLASS_NOT_FOUND", u'True')
                self.pyoutput(simple_feature)
            else:
                outputFeature = self.mapDictToFeature(simple_feature, outputFeatDict)
                self.pyoutput(outputFeature)

    def close(self):
        pass