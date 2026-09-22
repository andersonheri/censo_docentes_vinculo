# ============================================================
# 00_setup.R
# Pacotes, caminhos e parâmetros globais do projeto
# ============================================================
#
# Este script não faz nada sozinho: ele é sempre chamado (source)
# pelos demais scripts do projeto, para garantir que todos usem
# os mesmos caminhos e as mesmas listas de variáveis.

# ── Pacotes ───────────────────────────────────────────────────────────────────
# data.table é usado por ser o pacote mais eficiente em memória/tempo para ler
# arquivos CSV de ~200MB (os microdados do Censo Escolar), permitindo
# selecionar apenas as colunas de interesse já na leitura (argumento `select`).
pacotes <- c("data.table")

invisible(lapply(pacotes, function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
}))

library(data.table)

# ── Caminhos do projeto ────────────────────────────────────────────────────────
# Caminhos relativos à raiz do projeto (.Rproj). Rodar sempre a partir da raiz,
# ou abrir o projeto via censo_docentes_vinculo.Rproj no RStudio.
dir_raw  <- file.path("data", "raw")
dir_proc <- file.path("data", "processed")
dir_out  <- file.path("outputs", "tables")

for (d in c(dir_raw, dir_proc, dir_out)) {
  if (!dir.exists(d)) dir.create(d, recursive = TRUE)
}

# ── Nomes dos arquivos-fonte esperados em data/raw ────────────────────────────
# IMPORTANTE: os microdados do Censo Escolar NÃO são versionados neste
# repositório (são pesados e de distribuição pública pelo INEP — ver
# instruções em data/raw/README.md). Este objeto documenta os nomes de
# arquivo exatamente como baixados do portal do INEP, incluindo a
# inconsistência de extensão maiúscula em 2020.
arquivos_2015_2024 <- c(
  "2015" = "microdados_ed_basica_2015.csv",
  "2016" = "microdados_ed_basica_2016.csv",
  "2017" = "microdados_ed_basica_2017.csv",
  "2018" = "microdados_ed_basica_2018.csv",
  "2019" = "microdados_ed_basica_2019.csv",
  "2020" = "microdados_ed_basica_2020.CSV",   # extensão maiúscula original do INEP
  "2021" = "microdados_ed_basica_2021.csv",
  "2022" = "microdados_ed_basica_2022.csv",
  "2023" = "microdados_ed_basica_2023.csv",
  "2024" = "microdados_ed_basica_2024.csv"
)

arquivo_docente_2025 <- "Tabela_Docente_2025.csv"
arquivo_escola_2025  <- "Tabela_Escola_2025.csv"

# ── Variáveis de interesse ─────────────────────────────────────────────────────

# Identificação da escola (nível do painel: escola x ano)
vars_id <- c(
  "NU_ANO_CENSO", "SG_UF", "CO_UF", "NO_MUNICIPIO", "CO_MUNICIPIO",
  "CO_ENTIDADE", "NO_ENTIDADE", "TP_DEPENDENCIA", "TP_LOCALIZACAO"
)

# Quantidade de docentes, total e por etapa da educação básica
vars_doc_etapa <- c(
  "QT_DOC_BAS",      # total de docentes na educação básica
  "QT_DOC_INF",      # educação infantil
  "QT_DOC_FUND_AI",  # ensino fundamental — anos iniciais
  "QT_DOC_FUND_AF",  # ensino fundamental — anos finais
  "QT_DOC_MED"       # ensino médio
)

# Quantidade de docentes por tipo de vínculo contratual
# DISPONÍVEL SOMENTE NO CENSO 2025 (ver README.md e o comentário no
# script 01_importar_docentes.R para a checagem que confirma essa ausência
# em 2015-2024).
vars_doc_vinculo <- c(
  "QT_DOC_BAS_VINCULO_CONCUR",   # concursado/efetivo
  "QT_DOC_BAS_VINCULO_CONTRA",   # contratado (não concursado / temporário)
  "QT_DOC_BAS_VINCULO_TERCEIR",  # terceirizado
  "QT_DOC_BAS_VINCULO_CLT"       # regime CLT
)
