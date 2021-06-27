import json
import csv

jsonfile = 'd:/Desenvolvimento/modelagens/edgv_300/master_file_300.json'
csvfile = 'd:/Desenvolvimento/modelagens/rotinas/fixed_att_shp.csv'

fix_att = []
with open(csvfile, newline='') as csvfile:
    fixatt = csv.DictReader(csvfile)
    for att in fixatt:
        fix_att.append(att)
    with open(jsonfile, encoding='utf-8') as f:
            master = json.load(f)
            for classe in master['classes']:
                classe['nome'] = '_'.join([x.title() for x in classe['nome'].split('_')])
                classe['categoria'] = classe['categoria'].upper()
                for atributo in classe['atributos']:
                    atributo['tipo'] = 'varchar(255)' if atributo['tipo'] == 'smallint' else atributo['tipo']
                    atributo['cardinalidade'] = '0..1'
                    if 'mapa_valor' in atributo:
                        del atributo['mapa_valor']
                    if 'valores' in atributo:
                        del atributo['valores']
                    for att in fix_att:
                        if atributo['nome'] == att['original']:
                            atributo['nome'] = att['novo']
                    atributo['nome'] = atributo['nome'].upper()
            
            with open('fixed.json', 'w', encoding='utf-8') as outfile:
                json.dump(master, outfile, ensure_ascii=False, indent=4)
