# Censo Escolar — Docentes por etapa e vínculo contratual (2015–2025)

Painel escola × ano com a quantidade de docentes da educação básica,
total e por etapa (infantil, fundamental anos iniciais, fundamental anos
finais e médio), e a distribuição por vínculo contratual, a partir dos
microdados do Censo Escolar (INEP).

## Escopo e limitação dos dados

A variável de vínculo contratual do docente (`QT_DOC_BAS_VINCULO_CONCUR`,
`_CONTRA`, `_TERCEIR`, `_CLT`) **só existe no Censo 2025**. Os cabeçalhos
de todos os microdados de 2015 a 2024 foram checados exaustivamente —
tanto pelos nomes exatos das variáveis quanto por sinônimos plausíveis
(temporário, efetivo, estatutário, concursado, CLT, terceirizado, PSS,
contrato) — e nenhuma dessas informações existe nos anos anteriores a
2025. Isso não é uma limitação do script: é a estrutura real dos dados
publicados pelo INEP (o detalhamento por vínculo só passou a ser
coletado/publicado na reestruturação de 2025 do Censo Escolar).

Por isso:

- **2015–2024**: o painel traz o total de docentes (`QT_DOC_BAS`) e a
  distribuição por etapa (`QT_DOC_INF`, `QT_DOC_FUND_AI`, `QT_DOC_FUND_AF`,
  `QT_DOC_MED`).
- **2025**: além do total e da distribuição por etapa, também traz a
  distribuição por vínculo contratual.

Nível do painel: **escola × ano** (`CO_ENTIDADE` × `NU_ANO_CENSO`).

## Estrutura do projeto

```
censo_docentes_vinculo/
├── censo_docentes_vinculo.Rproj   # abrir este arquivo no RStudio
├── run_all.R                      # roda o pipeline completo, na ordem
├── R/
│   ├── 00_setup.R                 # pacotes, caminhos, variáveis de interesse
│   ├── 01_importar_docentes.R     # lê 2015-2025 e monta o painel escola x ano
│   ├── 02_distribuicoes.R         # gera as tabelas-resumo (Brasil)
│   └── 03_visualizacoes.R         # gráficos ggplot2 e mapas (UF e município)
├── data/
│   ├── raw/                       # microdados brutos (NÃO versionado — ver README nesta pasta)
│   └── processed/                 # painel consolidado (NÃO versionado, gerado localmente)
└── outputs/
    ├── tables/                    # tabelas-resumo finais (versionadas, pequenas)
    └── figures/                   # gráficos e mapas em PNG (versionados)
```

## Como reproduzir

1. Baixe os microdados do Censo Escolar (INEP) e coloque em `data/raw/`
   seguindo as instruções em [`data/raw/README.md`](data/raw/README.md).
2. Abra `censo_docentes_vinculo.Rproj` no RStudio (garante que o
   diretório de trabalho seja a raiz do projeto).
3. Rode `source("run_all.R")`, ou os scripts em `R/` na ordem:
   ```r
   source("R/01_importar_docentes.R")
   source("R/02_distribuicoes.R")
   source("R/03_visualizacoes.R")
   ```

Os mapas (`03_visualizacoes.R`) usam o pacote `geobr`, que baixa a malha
de estados e municípios do IBGE na primeira execução (fica em cache
local depois) — é necessário estar conectado à internet na primeira vez.
O mapa por município baixa um shapefile pesado (~5.570 municípios) e
pode levar alguns minutos na primeira execução.

## Saídas

- `data/processed/painel_docentes_escola_2015_2025.rds` /  `.csv` —
  painel completo, nível escola × ano (gerado localmente, não versionado).
- `outputs/tables/dist_docentes_etapa_2015_2025.csv` — total de docentes
  e distribuição por etapa, por ano.
- `outputs/tables/dist_docentes_vinculo_2025.csv` — distribuição por
  vínculo contratual, Brasil, 2025.
- `outputs/tables/dist_docentes_vinculo_dependencia_2025.csv` — o mesmo,
  por dependência administrativa (Federal/Estadual/Municipal/Privada).
- `outputs/tables/dist_docentes_uf_2025.csv` — total de docentes e % de
  contratados, por UF, 2025.
- `outputs/tables/dist_docentes_municipio_2025.csv` — o mesmo, por
  município, 2025.
- `outputs/figures/01_docentes_por_etapa_2015_2025.png` — evolução do
  total de docentes por etapa, 2015-2025.
- `outputs/figures/02_docentes_por_vinculo_2025.png` — distribuição por
  vínculo contratual, Brasil, 2025.
- `outputs/figures/03_vinculo_por_dependencia_2025.png` — vínculo
  contratual por dependência administrativa, 2025.
- `outputs/figures/04a_mapa_docentes_total_uf_2025.png` /
  `04b_mapa_pct_contratados_uf_2025.png` — mapas por UF (total de
  docentes e % contratados), 2025.
- `outputs/figures/05a_mapa_docentes_total_municipio_2025.png` /
  `05b_mapa_pct_contratados_municipio_2025.png` — os mesmos mapas, por
  município, 2025.

## Dependências

- R ≥ 4.0
- [`data.table`](https://cran.r-project.org/package=data.table)
- [`ggplot2`](https://cran.r-project.org/package=ggplot2), [`scales`](https://cran.r-project.org/package=scales)
- [`geobr`](https://cran.r-project.org/package=geobr), [`sf`](https://cran.r-project.org/package=sf) — malhas geográficas para os mapas

## Fonte dos dados

[Microdados do Censo Escolar — INEP](https://www.gov.br/inep/pt-br/acesso-a-informacao/dados-abertos/microdados/censo-escolar)
