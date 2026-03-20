# Conversor de Modelagens EDGV

Converte dados geoespaciais entre modelagens EDGV usando PostGIS e Shapefile, sem precisar do FME.

## Instalacao

Precisa de Python 3.10 ou superior.

```bash
pip install -r conversor/requirements.txt
```

## Como usar

1. Copie o exemplo de configuracao que corresponde ao seu caso (ver abaixo)
2. Edite os dados de conexao (host, database, user, password)
3. Execute a partir da pasta `conversao_modelagens/`:

```bash
python -m conversor.main meu_config.json
```

## Casos de uso

### 1. EDGV 3.0 para EDGV Topo 1.4

Converte um banco EDGV 3.0 para EDGV Topo 1.4.

Copie `config_examples/postgis300_postgis300topo14.json` e edite:

```json
{
  "mapping_file": "../arquivos_mapeamento/conversao_pg-edgv-300_pg-edgv-300topo14.json",
  "direction": "A=>B",
  "source": {
    "type": "postgis",
    "host": "localhost",
    "database": "NOME_DO_SEU_BANCO_EDGV300",
    "user": "postgres",
    "password": "postgres",
    "schema": "edgv",
    "srid": 4674
  },
  "destination": {
    "type": "postgis",
    "host": "localhost",
    "database": "NOME_DO_SEU_BANCO_TOPO14",
    "user": "postgres",
    "password": "postgres",
    "schema": "edgv",
    "srid": 4674
  }
}
```

### 2. EDGV Topo 1.4 para EDGV 3.0

Usa o mesmo mapeamento do caso anterior, mas na direcao inversa.

Copie `config_examples/postgis300_postgis300topo14.json` e troque:
- `"direction"` para `"B=>A"`
- `source` aponta para o banco Topo 1.4
- `destination` aponta para o banco EDGV 3.0

```json
{
  "mapping_file": "../arquivos_mapeamento/conversao_pg-edgv-300_pg-edgv-300topo14.json",
  "direction": "B=>A",
  "source": {
    "type": "postgis",
    "host": "localhost",
    "database": "NOME_DO_SEU_BANCO_TOPO14",
    "user": "postgres",
    "password": "postgres",
    "schema": "edgv",
    "srid": 4674
  },
  "destination": {
    "type": "postgis",
    "host": "localhost",
    "database": "NOME_DO_SEU_BANCO_EDGV300",
    "user": "postgres",
    "password": "postgres",
    "schema": "edgv",
    "srid": 4674
  }
}
```

### 3. EDGV 3.0 para Shapefile (uma pasta)

Copie `config_examples/postgis300_shp300.json` e edite:

```json
{
  "mapping_file": "../arquivos_mapeamento/conversao_pg-edgv-300_shp-edgv-300.json",
  "direction": "A=>B",
  "source": {
    "type": "postgis",
    "host": "localhost",
    "database": "NOME_DO_SEU_BANCO_EDGV300",
    "user": "postgres",
    "password": "postgres",
    "schema": "edgv",
    "srid": 4674
  },
  "destination": {
    "type": "shapefile",
    "path": "D:/output/shp_edgv300/",
    "srid": 4674,
    "encoding": "UTF-8"
  }
}
```

Os shapefiles serao gerados em `D:/output/shp_edgv300/`.

### 4. EDGV 3.0 para multiplos Shapefiles zipados (um por moldura)

Copie `config_examples/postgis300_shp300_batch.json` e edite:

```json
{
  "mapping_file": "../arquivos_mapeamento/conversao_pg-edgv-300_shp-edgv-300.json",
  "direction": "A=>B",
  "source": {
    "type": "postgis",
    "host": "localhost",
    "database": "NOME_DO_SEU_BANCO_EDGV300",
    "user": "postgres",
    "password": "postgres",
    "schema": "edgv",
    "srid": 4674
  },
  "destination": {
    "type": "shapefile",
    "path": "D:/output/shp_edgv300/",
    "srid": 4674,
    "encoding": "UTF-8",
    "zip": true
  },
  "batch_clip": {
    "type": "postgis",
    "host": "localhost",
    "database": "NOME_DO_SEU_BANCO_EDGV300",
    "user": "postgres",
    "password": "postgres",
    "schema": "edgv",
    "table": "aux_moldura_a",
    "geom_column": "geom",
    "folder_attribute": "inom"
  }
}
```

Resultado: um `.zip` por moldura, pronto para upload no BDGEx:

```
D:/output/shp_edgv300/
    SB-21-Z-A-I-1.zip
    SB-21-Z-A-I-2.zip
    ...
```

Se nao quiser zipar, remova `"zip": true` — os shapefiles ficam em subpastas separadas.

### 5. Shapefile para EDGV 3.0

Usa o mesmo mapeamento do caso 3, na direcao inversa.

```json
{
  "mapping_file": "../arquivos_mapeamento/conversao_pg-edgv-300_shp-edgv-300.json",
  "direction": "B=>A",
  "source": {
    "type": "shapefile",
    "path": "D:/dados/shapefiles/",
    "srid": 4674,
    "encoding": "UTF-8"
  },
  "destination": {
    "type": "postgis",
    "host": "localhost",
    "database": "NOME_DO_SEU_BANCO_EDGV300",
    "user": "postgres",
    "password": "postgres",
    "schema": "edgv",
    "srid": 4674
  }
}
```

Coloque todos os `.shp` na pasta indicada em `source.path`.

### 6. Banco de edicao Topo 1.4

Segmenta as feicoes pelas molduras e reprojeta para UTM. Transforma um banco continuo (4674) em contiguo (feicoes cortadas nas bordas das molduras).

Copie `config_examples/banco_edicao_topo14.json` e edite:

```json
{
  "mapping_file": null,
  "direction": "A=>B",
  "source": {
    "type": "postgis",
    "host": "localhost",
    "database": "NOME_DO_BANCO_ORIGEM",
    "user": "postgres",
    "password": "postgres",
    "schema": "edgv",
    "srid": 4674
  },
  "destination": {
    "type": "postgis",
    "host": "localhost",
    "database": "NOME_DO_BANCO_EDICAO",
    "user": "postgres",
    "password": "postgres",
    "schema": "edgv",
    "srid": 4674
  },
  "segment_clip": {
    "type": "postgis",
    "host": "localhost",
    "database": "NOME_DO_BANCO_ORIGEM",
    "user": "postgres",
    "password": "postgres",
    "schema": "edgv",
    "table": "aux_moldura_a",
    "geom_column": "geom"
  },
  "options": {
    "reproject_to": 31982,
    "error_action": "skip"
  }
}
```

O `segment_clip` aponta para o mesmo banco de origem (onde esta a tabela `aux_moldura_a`).

### 7. Banco de edicao Orto 2.5

Identico ao caso 6, apenas troque os nomes dos bancos.

Copie `config_examples/banco_edicao_orto25.json` e edite os campos `database` no `source`, `destination` e `segment_clip`.

## O que editar nos configs

Na maioria dos casos voce so precisa trocar:

| Campo | O que colocar |
|---|---|
| `database` | Nome do seu banco PostgreSQL |
| `host` | Endereco do servidor (geralmente `localhost`) |
| `user` / `password` | Credenciais do PostgreSQL |
| `path` (shapefile) | Pasta de entrada ou saida dos shapefiles |
| `reproject_to` | EPSG do fuso UTM desejado (ex: `31982`, `31983`) |

Os campos `mapping_file`, `direction`, `schema` e `srid` ja vem preenchidos corretamente nos exemplos.

## Relatorio

Ao final da execucao, aparece um resumo no terminal:

```
=== Relatorio de Conversao ===
Total de feicoes processadas: 15234
Feicoes convertidas: 14890
Ignoradas (classe nao encontrada): 312
Ignoradas (geometria invalida): 32
Erros: 0
```

Se `log_file` estiver configurado nas opcoes, um arquivo `.log` e um `_report.json` sao gerados.
