# ============================================================
# 02_distribuicoes.R
# Distribuições agregadas (Brasil) de docentes por etapa e vínculo
# ============================================================
#
# O QUE ESTE SCRIPT FAZ:
#   Lê o painel escola x ano gerado em 01_importar_docentes.R e produz
#   3 tabelas-resumo, salvas em outputs/tables/:
#     - dist_docentes_etapa_2015_2025.csv
#         total de docentes e distribuição por etapa, por ano (2015-2025)
#     - dist_docentes_vinculo_2025.csv
#         total de docentes e distribuição por vínculo contratual (só 2025)
#     - dist_docentes_vinculo_dependencia_2025.csv
#         o mesmo, quebrado por dependência administrativa (só 2025)
#
# PRÉ-REQUISITO: rodar 01_importar_docentes.R antes (ou garantir que
# data/processed/painel_docentes_escola_2015_2025.rds já existe).

source("R/00_setup.R")

caminho_painel <- file.path(dir_proc, "painel_docentes_escola_2015_2025.rds")
if (!file.exists(caminho_painel)) {
  stop("Painel não encontrado em ", caminho_painel,
       ". Rode primeiro R/01_importar_docentes.R.")
}

painel_docentes <- readRDS(caminho_painel)

# ============================================================
# 1) Total de docentes e distribuição por etapa — por ano (2015-2025)
# ============================================================

dist_etapa_ano <- painel_docentes[
  , .(
    doc_bas     = sum(QT_DOC_BAS,     na.rm = TRUE),
    doc_inf     = sum(QT_DOC_INF,     na.rm = TRUE),
    doc_fund_ai = sum(QT_DOC_FUND_AI, na.rm = TRUE),
    doc_fund_af = sum(QT_DOC_FUND_AF, na.rm = TRUE),
    doc_med     = sum(QT_DOC_MED,     na.rm = TRUE)
  ),
  by = NU_ANO_CENSO
][order(NU_ANO_CENSO)]

# % em relação ao total de docentes da educação básica (QT_DOC_BAS).
# Nota: um mesmo docente pode lecionar em mais de uma etapa, então a soma
# das parcelas por etapa pode superar 100% do total — isso é esperado e
# reflete a forma como o INEP conta docentes por etapa (não é erro).
dist_etapa_ano[, `:=`(
  pct_inf     = round(100 * doc_inf     / doc_bas, 1),
  pct_fund_ai = round(100 * doc_fund_ai / doc_bas, 1),
  pct_fund_af = round(100 * doc_fund_af / doc_bas, 1),
  pct_med     = round(100 * doc_med     / doc_bas, 1)
)]

message("\n=== Distribuição de docentes por etapa (Brasil, 2015-2025) ===")
print(dist_etapa_ano)

fwrite(dist_etapa_ano, file.path(dir_out, "dist_docentes_etapa_2015_2025.csv"), sep = ";")

# ============================================================
# 2) Distribuição por vínculo contratual — só 2025
# ============================================================

dist_vinculo_2025 <- painel_docentes[
  NU_ANO_CENSO == 2025,
  .(
    doc_bas             = sum(QT_DOC_BAS, na.rm = TRUE),
    doc_vinculo_concur  = sum(QT_DOC_BAS_VINCULO_CONCUR,  na.rm = TRUE),
    doc_vinculo_contrat = sum(QT_DOC_BAS_VINCULO_CONTRA,  na.rm = TRUE),
    doc_vinculo_terceir = sum(QT_DOC_BAS_VINCULO_TERCEIR, na.rm = TRUE),
    doc_vinculo_clt     = sum(QT_DOC_BAS_VINCULO_CLT,     na.rm = TRUE)
  )
]

dist_vinculo_2025[, `:=`(
  pct_concur  = round(100 * doc_vinculo_concur  / doc_bas, 1),
  pct_contrat = round(100 * doc_vinculo_contrat / doc_bas, 1),
  pct_terceir = round(100 * doc_vinculo_terceir / doc_bas, 1),
  pct_clt     = round(100 * doc_vinculo_clt     / doc_bas, 1)
)]

message("\n=== Distribuição de docentes por vínculo contratual (Brasil, 2025) ===")
print(dist_vinculo_2025)

fwrite(dist_vinculo_2025, file.path(dir_out, "dist_docentes_vinculo_2025.csv"), sep = ";")

# ============================================================
# 3) Vínculo contratual por dependência administrativa — só 2025
# ============================================================
# TP_DEPENDENCIA: 1 = Federal, 2 = Estadual, 3 = Municipal, 4 = Privada

dist_vinculo_dependencia_2025 <- painel_docentes[
  NU_ANO_CENSO == 2025,
  .(
    doc_bas             = sum(QT_DOC_BAS, na.rm = TRUE),
    doc_vinculo_concur  = sum(QT_DOC_BAS_VINCULO_CONCUR,  na.rm = TRUE),
    doc_vinculo_contrat = sum(QT_DOC_BAS_VINCULO_CONTRA,  na.rm = TRUE),
    doc_vinculo_terceir = sum(QT_DOC_BAS_VINCULO_TERCEIR, na.rm = TRUE),
    doc_vinculo_clt     = sum(QT_DOC_BAS_VINCULO_CLT,     na.rm = TRUE)
  ),
  by = TP_DEPENDENCIA
][order(TP_DEPENDENCIA)]

message("\n=== Vínculo contratual por dependência administrativa (Brasil, 2025) ===")
print(dist_vinculo_dependencia_2025)

fwrite(dist_vinculo_dependencia_2025,
       file.path(dir_out, "dist_docentes_vinculo_dependencia_2025.csv"), sep = ";")

message("\n>>> Tabelas-resumo salvas em: ", dir_out)
