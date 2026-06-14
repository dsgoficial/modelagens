# Topo 2.0 -> Orto 3.0 — Sem Correspondencia

Complemento da conversao `conversao_pg-edgv-topo20_pg-edgv-orto30.json`.

## 1. Classes tematicas do Topo 2.0 sem classe no Orto 3.0

19 de 42 classes tematicas. O Orto 3.0 adota escopo conservador (precedencia Orto 2.5): exclui o que e intrinsecamente nao interpretavel por ortoimagem (batimetria, geodesia de campo, subsuperficie, rotas conceituais) e o que ja estava fora do produto Orto 2.5.

| Classe Topo 2.0 | Motivo |
|---|---|
| `cobter_area_edificada` | Fora do escopo conservador do Orto 3.0 (precedencia Orto 2.5). |
| `cobter_vegetacao` | Fora do escopo conservador do Orto 3.0 (precedencia Orto 2.5). |
| `constr_area_uso_especifico` | Fora do escopo conservador do Orto 3.0 (precedencia Orto 2.5). |
| `constr_deposito` | Fora do escopo conservador do Orto 3.0 (precedencia Orto 2.5). |
| `constr_edificacao` | Fora do escopo conservador do Orto 3.0 (precedencia Orto 2.5). |
| `constr_ocupacao_solo` | Fora do escopo conservador do Orto 3.0 (precedencia Orto 2.5). |
| `elemnat_curva_batimetrica` | Nao interpretavel por ortoimagem (batimetria). |
| `elemnat_elemento_fisiografico` | Classe nova no Topo 2.0; fora do escopo conservador do Orto 3.0 (precedencia Orto 2.5). |
| `elemnat_ponto_cotado_batimetrico` | Nao interpretavel por ortoimagem (batimetria). |
| `infra_alteracao_fisiografica_antropica` | Classe nova no Topo 2.0; fora do escopo conservador do Orto 3.0 (precedencia Orto 2.5). |
| `infra_elemento_viario` | Classe nova no Topo 2.0 (detalhamento viario urbano); fora do escopo conservador do Orto 3.0 (precedencia Orto 2.5). |
| `infra_mobilidade_urbana` | Classe nova no Topo 2.0; fora do escopo conservador do Orto 3.0 (precedencia Orto 2.5). |
| `infra_obstaculo_terrestre` | Classe nova no Topo 2.0; fora do escopo conservador do Orto 3.0 (precedencia Orto 2.5). |
| `infra_travessia_hidroviaria` | Rota/travessia hidroviaria conceitual; fora do escopo conservador do Orto 3.0 (precedencia Orto 2.5). |
| `infra_trecho_duto` | Subsuperficie / nao interpretavel por ortoimagem. |
| `infra_trecho_hidroviario` | Rota hidroviaria conceitual; fora do escopo conservador do Orto 3.0 (precedencia Orto 2.5). |
| `infra_vala` | Classe nova no Topo 2.0; fora do escopo conservador do Orto 3.0 (precedencia Orto 2.5). |
| `llp_delimitacao_fisica` | Classe nova no Topo 2.0; fora do escopo conservador do Orto 3.0 (precedencia Orto 2.5). |
| `llp_ponto_controle` | Dado geodesico de campo; nao restituido de ortoimagem. |

## 2. Atributos das classes mapeadas 1:1

**Nenhum** atributo e' descartado: as classes do Orto 3.0 que existem no Topo 2.0 herdam o conjunto de atributos **integral** do Topo 2.0 (Orto 3.0 e' baseado no Topo 2.0). Conversao Topo 2.0 -> Orto 3.0 sem perda de atributos nas classes comuns.

## 3. Classes do Orto 3.0 sem fonte 1:1 no Topo 2.0

**Derivadas por `tipo`** (a partir de classes unificadas do Topo 2.0):

| Classe Orto 3.0 | Origem Topo 2.0 | tipo |
|---|---|---|
| `llp_aglomerado_rural` | `llp_localidade` | [5, 6, 7] |
| `llp_nome_local` | `llp_localidade` | [8] |
| `llp_area_pub_militar` | `llp_limite_especial` | [36] |
| `llp_terra_indigena` | `llp_limite_especial` | [2] |
| `llp_unidade_conservacao` | `llp_limite_especial` | [5, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35] |

**Proprias do produto ortoimagem** (sem equivalente no Topo 2.0):

- `edicao_area_pub_militar`
- `edicao_articulacao_imagem`
- `edicao_terra_indigena`
- `edicao_unidade_conservacao`

## 4. Observacoes

- `tipo_limite_especial` codigo 3 (Territorio quilombola) nao tem classe no Orto 3.0; tais feicoes nao sao convertidas de Topo 2.0 para Orto 3.0.
- `localidade` no Topo 2.0 com `tipo` em {1,2,3,4,9,10} -> `llp_localidade`; {5,6,7} -> `llp_aglomerado_rural`; {8} -> `llp_nome_local`.
