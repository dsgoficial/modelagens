# Criador de Bancos EDGV

Cria bancos PostgreSQL/PostGIS com a estrutura EDGV a partir dos arquivos SQL do repositorio.

## Instalacao

Precisa de Python 3.10 ou superior.

```bash
pip install -r criador_bancos/requirements.txt
```

## Como usar

1. Copie o exemplo de configuracao que corresponde ao seu caso (ver abaixo)
2. Edite os dados de conexao (host, user, password)
3. Execute a partir da raiz do repositorio:

```bash
python -m criador_bancos.main meu_config.json
```

## Antes de rodar: `--dry-run`

Mostra o que SERIA feito, sem criar nem derrubar nada. Diz quais bancos seriam
criados, quais ja existem (e seriam ignorados) e quais seriam DERRUBADOS.

```bash
python -m criador_bancos.main meu_config.json --dry-run
python -m criador_bancos.main meu_config.json --dry-run --json   # para script/agente
```

Se o servidor nao responder, o plano sai mesmo assim: a existencia dos bancos
aparece como nao verificada e o resto (modelo, SRID, SQL do modelo) continua
valendo.

## Qual e a forma do config: `--schema`

O contrato do arquivo de configuracao e um JSON Schema versionado em
`criador_bancos/config_schema.json`, com a descricao de cada campo:

```bash
python -m criador_bancos.main --schema
```

Toda execucao valida o config contra ele. Campo com nome errado (`optionss` em
vez de `options`) e recusado em vez de ignorado em silencio.

## Casos de uso

### 1. Banco unico

Cria um banco EDGV 3.0 com SRID padrao (4674).

Copie `config_examples/exemplo_banco_unico.json` e edite:

```json
{
  "connection": {
    "host": "localhost",
    "port": 5432,
    "user": "postgres",
    "password": "postgres"
  },
  "databases": [
    {
      "name": "pit2026_1f_santiago_50k_4674_edgv30",
      "model": "edgv_300",
      "srid": 4674
    }
  ]
}
```

### 2. Multiplos bancos de modelagens diferentes

Cria varios bancos de uma vez, cada um com seu modelo e SRID.

Copie `config_examples/exemplo_multiplos_bancos.json` e edite:

```json
{
  "connection": {
    "host": "localhost",
    "port": 5432,
    "user": "postgres",
    "password": "postgres"
  },
  "databases": [
    {
      "name": "pit2026_1q_palmas_pr_25k_31982_edgvorto25_edicao",
      "model": "edgv_300_orto_25",
      "srid": 31982
    },
    {
      "name": "pit2026_1r_caxias_do_sul_rs_25k_4674_edgvorto25",
      "model": "edgv_300_orto_25",
      "srid": 4674
    },
    {
      "name": "pit2026_1k_sao_luiz_pr_25k_4674_edgvtopo14",
      "model": "edgv_300_topo_14",
      "srid": 4674
    },
    {
      "name": "pit2026_1f_santiago_50k_4674_edgv30",
      "model": "edgv_300",
      "srid": 4674
    }
  ],
  "options": {
    "overwrite": false
  }
}
```

### 3. Recriar bancos existentes (DESTRUTIVO)

Derrubar um banco exige DUAS coisas, e o arquivo de configuracao sozinho **nao
basta**:

1. `"overwrite": true` no config, que declara a intencao;
2. `--overwrite <nome_do_banco>` na linha de comando, um por banco, que
   autoriza aquele banco especifico.

O motivo e que config se copia, se versiona e se reusa. Um `"overwrite": true`
esquecido num config aproveitado de outra rodada apagaria um banco de producao
sem ninguem pedir. A autorizacao mora na linha de comando porque so ela e
digitada na hora, para aquela execucao.

```json
{
  "connection": {
    "host": "localhost",
    "port": 5432,
    "user": "postgres",
    "password": "postgres"
  },
  "databases": [
    {
      "name": "pit2026_1q_palmas_pr_25k_31982_edgvorto25_edicao",
      "model": "edgv_300_orto_25",
      "srid": 31982
    }
  ],
  "options": {
    "overwrite": true
  }
}
```

```bash
# Confira primeiro o que seria destruido:
python -m criador_bancos.main meu_config.json --dry-run \
    --overwrite pit2026_1q_palmas_pr_25k_31982_edgvorto25_edicao

# Depois execute de verdade:
python -m criador_bancos.main meu_config.json \
    --overwrite pit2026_1q_palmas_pr_25k_31982_edgvorto25_edicao
```

Sem a confirmacao, o CLI **recusa a execucao inteira** (nada e criado tambem) e
imprime o comando exato que confirmaria.

> `DROP DATABASE` e irreversivel e **mata as sessoes ativas** do banco
> (`pg_terminate_backend`): quem estiver editando cai na hora e perde o
> trabalho nao salvo.

Para so criar o que falta e deixar intacto o que ja existe, use
`"overwrite": false` (ou omita `options`): banco existente e ignorado.

## Modelos disponiveis

A lista viva esta em `criador_bancos/models.py` e no enum `model` do
`config_schema.json` (um teste garante que os dois nao divergem).

| Modelo | Descricao |
|---|---|
| `edgv_300` | EDGV 3.0 |
| `edgv_300_topo_14` | EDGV 3.0 Topo 1.4 |
| `edgv_300_topo_20` | EDGV 3.0 Topo 2.0 |
| `edgv_300_orto_25` | EDGV 3.0 Orto 2.5 |
| `edgv_300_orto_30` | EDGV 3.0 Orto 3.0 |

## O que editar nos configs

Na maioria dos casos voce so precisa trocar:

| Campo | O que colocar |
|---|---|
| `host` | Endereco do servidor (geralmente `localhost`) |
| `user` / `password` | Credenciais do PostgreSQL |
| `name` | Nome do banco a ser criado |
| `model` | Modelo EDGV (ver tabela acima) |
| `srid` | EPSG do sistema de coordenadas (ex: `4674`, `31982`). Se omitido, usa 4674 |

## Resumo

Ao final da execucao, aparece um resumo no terminal:

```
Criando 4 banco(s)...

  [pit2026_1q_palmas_pr_25k_31982_edgvorto25_edicao] modelo=edgv_300_orto_25, srid=31982...
  [pit2026_1q_palmas_pr_25k_31982_edgvorto25_edicao] criado: Banco criado com sucesso

  [pit2026_1r_caxias_do_sul_rs_25k_4674_edgvorto25] modelo=edgv_300_orto_25, srid=4674...
  [pit2026_1r_caxias_do_sul_rs_25k_4674_edgvorto25] criado: Banco criado com sucesso

  [pit2026_1k_sao_luiz_pr_25k_4674_edgvtopo14] modelo=edgv_300_topo_14, srid=4674...
  [pit2026_1k_sao_luiz_pr_25k_4674_edgvtopo14] criado: Banco criado com sucesso

  [pit2026_1f_santiago_50k_4674_edgv30] modelo=edgv_300, srid=4674...
  [pit2026_1f_santiago_50k_4674_edgv30] criado: Banco criado com sucesso

=== Resumo ===
Criados: 4
```

## Codigos de saida

| Codigo | Quando |
|---|---|
| `0` | Tudo certo (ou `--dry-run`, ou `--schema`) |
| `1` | Algum banco falhou ao executar o SQL do modelo |
| `2` | Config invalido, ou overwrite pedido sem confirmacao na linha de comando |

## Testes

Nao precisam de PostgreSQL: as conexoes sao substituidas por dubles que
registram o SQL que seria executado.

```bash
pytest criador_bancos/tests/
```
