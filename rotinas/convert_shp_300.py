import json
import csv

jsonfile = r'C:\Users\marcel\Desktop\GitHub\modelagens\edgv_300\master_file_300.json'
csvfile = r'C:\Users\marcel\Desktop\GitHub\modelagens\rotinas\fixed_att_shp.csv'

fix_att = []
with open(csvfile, newline='') as csvfile:
    aux = csv.DictReader(csvfile)
    for att in aux:
        fix_att.append(att)
    with open(jsonfile, encoding='utf-8') as f:
            master = json.load(f)
            mapeamento_classe = []
            for classe in master['classes']:
                aux = {}
                aux['classe_A'] = classe['categoria'] + '_' + classe['nome']
                classe['nome'] = '_'.join([x.title() for x in classe['nome'].split('_')])
                classe['categoria'] = classe['categoria'].upper()
                aux['classe_B'] = classe['categoria'] + '_' + classe['nome']
                mapeamento_classe.append(aux)
            
            with open('map_classe.json', 'w', encoding='utf-8') as outfile:
                json.dump(mapeamento_classe, outfile, ensure_ascii=False, indent=4)


            mapeamento_atributo_aux = {}
            for classe in master['classes']:
                for atributo in classe['atributos']:
                    aux = atributo['nome']
                    for att in fix_att:
                        if aux == att['original']:
                            aux = att['novo']
                    aux = aux.upper()
                    if atributo['nome'] not in mapeamento_atributo_aux:
                        mapeamento_atributo_aux[atributo['nome']] = {}
                        mapeamento_atributo_aux[atributo['nome']]['attr_A'] = atributo['nome']
                        mapeamento_atributo_aux[atributo['nome']]['attr_B'] = aux
                        
                        if 'mapa_valor' in atributo:
                            mapeamento_atributo_aux[atributo['nome']]['traducao'] = []
                            for dominio in master['dominios']:
                                if atributo['mapa_valor'] == dominio['nome']:
                                    for valor in dominio['valores']:
                                        aux2 = {}
                                        aux2['valor_A'] = valor['code']
                                        aux2['valor_B'] = valor['value']
                                        mapeamento_atributo_aux[atributo['nome']]['traducao'].append(aux2)

            mapeamento_atributo = []
            for key in mapeamento_atributo_aux:
                mapeamento_atributo.append(mapeamento_atributo_aux[key])

            with open('map_dominio.json', 'w', encoding='utf-8') as outfile2:
                json.dump(mapeamento_atributo, outfile2, ensure_ascii=False, indent=4)
            

