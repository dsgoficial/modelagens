import json

with open('../edgv_300_topo/1_3/master_file_300_topo_13.json', 'r', encoding='utf-8') as f:
    master = json.load(f)

mapping = {
    "metadados": {
        "versao_arquivo": "1.0",
        "modelo_ida": "EDGV 3.0 Topo",
        "versao_modelo_ida": "1.3.2",
        "modelo_volta": "EDGV 3.0 Topo Multiescala",
        "versao_modelo_volta": "1.3.2"
    },
    "schema_ida": master["schema_dados"],
    "schema_volta": master["schema_dados"],
    "afixo_geom_ida": master["geom_suffix"],
    "afixo_geom_volta": {
        "tipo": "sufixo",
        "MultiPoint": "_250k_p",
        "MultiLinestring": "_250k_l",
        "MultiPolygon": "_250k_a"
    },
    "agregar_geom_ida": True,
    "agregar_geom_volta": True,
    "mapeamento_classes": [],
    "mapeamento_atributos": [],
}

def map_attributes(classe, mapping):
    mapped_attributes = []
    for attr in classe["atributos"]:
        if "mapa_valor" in attr:
            # Create the _code mapping
            mapped_attributes.append({
                "attr_ida": attr["nome"],
                "attr_volta": attr["nome"] + "_code"
            })
            # Create the _value mapping with translations
            traducao = []
            for domain in master["dominios"]:
                if domain["nome"] == attr["mapa_valor"]:
                    for valor in domain["valores"]:
                        traducao.append({
                            "valor_ida": valor["code"],
                            "valor_volta": valor["value"]
                        })
            mapping["mapeamento_atributos"].append({
                "attr_ida": attr["nome"],
                "attr_volta": attr["nome"] + "_value",
                "traducao": traducao
            })
    return mapped_attributes

for classe in master["classes"]:
    class_name_ida = classe["nome"]
    class_name_volta = classe["nome"]
    
    mapping["mapeamento_classes"].append({
        "classe_ida": class_name_ida,
        "classe_volta": class_name_volta,
        "mapeamento_atributos": map_attributes(classe, mapping)
    })

with open('./conversao_pg-edgv-300topo_pg-edgv-300topo-multiescala.json', 'w', encoding='utf-8') as f:
    json.dump(mapping, f, ensure_ascii=False, indent=4)

print("Mapping file created successfully.")
