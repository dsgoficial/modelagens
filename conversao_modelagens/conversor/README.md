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

> Os caminhos de `mapping_file` sao relativos a pasta do arquivo de config. Os exemplos ficam em `conversor/config_examples/`, por isso apontam para `../../arquivos_mapeamento/`. Se voce mover o config para outra pasta, ajuste esse caminho (ou use um caminho absoluto).

## Antes de rodar: `--dry-run`

Mostra o que SERIA feito, sem ler feicao nem escrever nada: o modo (simples,
batch_clip, segment_clip), os estagios do pipeline, as tabelas de origem com a
contagem estimada de feicoes, as molduras que seriam recortadas, as classes que
o mapeamento final produz e, principalmente, **se o destino ja tem dados**.

```bash
python -m conversor.main meu_config.json --dry-run
python -m conversor.main meu_config.json --dry-run --json   # para script/agente
```

Se o banco nao responder, o plano sai mesmo assim, com a parte offline
(estagios, mapeamento, modo) e a falha registrada no lugar do que nao deu para
consultar. A senha nunca aparece na saida.

## Rodar duas vezes: `--se-existir`

A escrita em PostGIS e sempre em **append**. Rodar a mesma conversao duas vezes
duplicaria as feicoes sem erro nenhum, em silencio. Por isso, quando alguma
tabela do destino ja tem feicoes, o conversor exige uma decisao explicita:

| Valor | O que faz |
|---|---|
| `abortar` (padrao) | Nao escreve nada e lista as tabelas que ja tem feicoes |
| `replace` | Esvazia essas tabelas (`DELETE`, preservando a estrutura EDGV) e grava |
| `append` | Acrescenta mesmo assim, aceitando a duplicacao |

```bash
python -m conversor.main meu_config.json --se-existir replace
```

A checagem roda ANTES de qualquer escrita, entao o `abortar` nunca deixa o
destino meio gravado. Destino vazio ou destino shapefile nao sao afetados:
shapefile e reescrito por inteiro pelo proprio `to_file`.

> `replace` usa `DELETE`, nao `DROP`. O `if_exists="replace"` do geopandas
> derrubaria a tabela e a recriaria a partir do GeoDataFrame, perdendo chave
> primaria, dominios, constraints e triggers do DDL EDGV.

## Qual e a forma do config: `--schema`

O contrato do arquivo de configuracao e um JSON Schema versionado em
`conversor/config_schema.json`, com a descricao de cada campo:

```bash
python -m conversor.main --schema
```

Toda execucao valida o config contra ele, alem da validacao que ja existia.
Campo com nome errado (`sorce` em vez de `source`) e recusado em vez de
ignorado em silencio.

## Casos de uso

### 1. EDGV 3.0 para EDGV Topo 1.4

Converte um banco EDGV 3.0 para EDGV Topo 1.4.

Copie `config_examples/postgis300_postgis300topo14.json` e edite:

```json
{
  "mapping_file": "../../arquivos_mapeamento/conversao_pg-edgv-300_pg-edgv-300topo14.json",
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
  "mapping_file": "../../arquivos_mapeamento/conversao_pg-edgv-300_pg-edgv-300topo14.json",
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
  "mapping_file": "../../arquivos_mapeamento/conversao_pg-edgv-300_shp-edgv-300.json",
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
  "mapping_file": "../../arquivos_mapeamento/conversao_pg-edgv-300_shp-edgv-300.json",
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
  "mapping_file": "../../arquivos_mapeamento/conversao_pg-edgv-300_shp-edgv-300.json",
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

### 8. Pipeline encadeado (varios mapeamentos num unico passo)

Em vez de `mapping_file` + `direction` no topo, use um array `stages`. Cada
estagio aplica um mapeamento, na ordem, alimentando o proximo em memoria, sem
banco intermediario. So o ultimo estagio escreve no `destination` (e respeita
`batch_clip`/`segment_clip`/`reproject_to`); os intermediarios so transformam.

Caso classico: banco de producao **EDGV 3.0 Topo 1.4 -> EDGV 3.0 pura -> Shapefile
por folha** numa execucao so. Copie `config_examples/postgis300topo14_shp300_batch_chained.json`:

```json
{
  "source": {
    "type": "postgis",
    "host": "localhost",
    "database": "NOME_DO_SEU_BANCO_TOPO14",
    "user": "postgres",
    "password": "postgres",
    "schema": "edgv",
    "srid": 4674
  },
  "stages": [
    {
      "mapping_file": "../../arquivos_mapeamento/conversao_pg-edgv-300_pg-edgv-300topo14.json",
      "direction": "B=>A"
    },
    {
      "mapping_file": "../../arquivos_mapeamento/conversao_pg-edgv-300_shp-edgv-300.json",
      "direction": "A=>B"
    }
  ],
  "destination": {
    "type": "shapefile",
    "path": "D:/output/cdgv_folhas/",
    "srid": 4674,
    "encoding": "UTF-8",
    "zip": true
  },
  "batch_clip": {
    "type": "postgis",
    "host": "localhost",
    "database": "NOME_DO_SEU_BANCO_TOPO14",
    "user": "postgres",
    "password": "postgres",
    "schema": "edgv",
    "table": "aux_moldura_a",
    "geom_column": "geom",
    "folder_attribute": "inom"
  }
}
```

Resultado: um `.zip` de shapefiles EDGV 3.0 por moldura, pronto para o BDGEx,
identico ao que sairia rodando os dois mapeamentos em sequencia manual.

Notas:
- Os `mapping_file` sao relativos a pasta do arquivo de config (no exemplo, em
  `conversor/config_examples/`, o caminho ate `arquivos_mapeamento/` e `../../`).
- Os mapeamentos encadeados precisam ser compativeis: o modelo de saida de um
  estagio (classe, schema, afixo de geometria) tem que casar com a entrada do
  proximo. Um estagio que converte 0 feicoes emite um aviso no log.
- `reproject_to` e os modos de recorte valem so na escrita final; nao ha
  reprojecao entre estagios.
- O formato antigo (`mapping_file` + `direction` no topo) continua valendo e
  equivale a um pipeline de um unico estagio.

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

## Codigos de saida

| Codigo | Quando |
|---|---|
| `0` | Tudo certo (ou `--dry-run`, ou `--schema`) |
| `2` | Config invalido, ou destino nao vazio com `--se-existir abortar` |

## Testes

Nao precisam de PostGIS: usam shapefile para o caminho de ponta a ponta e
dubles para as decisoes que dependeriam do banco.

```bash
cd conversao_modelagens
pytest conversor/tests/
```
