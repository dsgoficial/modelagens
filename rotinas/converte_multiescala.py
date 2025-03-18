import json

with open('../edgv_300_topo/1_4/master_file_300_topo_14.json', 'r', encoding='utf-8') as f:
    master = json.load(f)

mapping = {
    "metadados": {
        "versao_arquivo": "1.0",
        "modelo_A": "EDGV 3.0 Topo",
        "versao_modelo_A": "1.4.3",
        "modelo_B": "EDGV 3.0 Topo Multiescala",
        "versao_modelo_B": "1.4.3"
    },
    "schema_A": master["schema_dados"],
    "schema_B": master["schema_dados"],
    "afixo_geom_A": {
        "tipo": "sufixo",
        "POINT": "p",
        "LINESTRING": "_l",
        "POLYGON": "_a"
    },
    "afixo_geom_B": {
        "tipo": "sufixo",
        "POINT": "_250k_p",
        "MultiLinestring": "_250k_l",
        "MultiPolygon": "_250k_a"
    },
    "agregar_geom_A": True,
    "agregar_geom_B": True,
    "mapeamento_classes": []
}

def map_attributes(classe):
    mapped_attributes = []
    for attr in classe["atributos"]:
        if "mapa_valor" in attr:
            # Create the _code mapping
            mapped_attributes.append({
                "attr_A": attr["nome"],
                "attr_B": attr["nome"] + "_code"
            })

            # Create the _value mapping with translations
            traducao = []
            for domain in master["dominios"]:
                if domain["nome"] == attr["mapa_valor"]:
                    for valor in domain["valores"]:
                        traducao.append({
                            "valor_A": valor["code"],
                            "valor_B": valor["value"]
                        })

            mapped_attributes.append({
                "attr_A": attr["nome"],
                "attr_B": attr["nome"] + "_value",
                "traducao": traducao
            })
    return mapped_attributes

master["classes"].extend(master["extension_classes"])

for classe in master["classes"]:
    if classe["categoria"] in ('centroide', 'delimitador'):
        pass
    if classe["categoria"] in ('aux') and classe["nome"] not in ('moldura', 'moldura_area_continua'):
        pass
    if classe["categoria"] in ('edicao') and classe["nome"] not in ('limite_especial', 'simb_torre_energia', 'identificador_trecho_rod', 'simb_vegetacao'):
        pass
    class_name_ida = classe["categoria"] + '_' + classe["nome"]
    class_name_volta = classe["categoria"] + '_' + classe["nome"]
    
    mapping["mapeamento_classes"].append({
        "classe_A": class_name_ida,
        "classe_B": class_name_volta,
        "mapeamento_atributos": map_attributes(classe)
    })

with open('./conversao_pg-edgv-300topo14_pg-edgv-300topo-multiescala14.json', 'w', encoding='utf-8') as f:
    json.dump(mapping, f, ensure_ascii=False, indent=4)

print("Mapping file created successfully.")
