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

### 3. Recriar bancos existentes

Se precisar recriar bancos que ja existem, use `"overwrite": true`. O banco sera apagado e recriado do zero.

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

## Modelos disponiveis

| Modelo | Descricao |
|---|---|
| `edgv_300` | EDGV 3.0 |
| `edgv_300_topo_14` | EDGV 3.0 Topo 1.4 |
| `edgv_300_orto_25` | EDGV 3.0 Orto 2.5 |

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
