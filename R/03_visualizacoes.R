# ============================================================
# 03_visualizacoes.R
# Análises descritivas visuais (ggplot2) — docentes por etapa e
# vínculo contratual, e mapa da distribuição no Brasil por UF
# ============================================================
#
# O QUE ESTE SCRIPT FAZ:
#   1. Evolução do total de docentes por etapa, 2015-2025 (linha)
#   2. Distribuição percentual por vínculo contratual, Brasil 2025 (barra)
#   3. Vínculo contratual por dependência administrativa, 2025 (barra empilhada)
#   4. Mapa do Brasil por UF: total de docentes e % de docentes
#      contratados (vínculo "CONTRA"), Censo 2025
#   5. Mapa do Brasil por MUNICÍPIO: total de docentes e % de docentes
#      contratados, Censo 2025 (mapa mais pesado — ver nota no bloco 5)
#
# Todos os gráficos usam texto tamanho 14 (theme_minimal(base_size = 14)).
#
# PRÉ-REQUISITO: rodar R/01_importar_docentes.R (o painel precisa existir
# em data/processed/painel_docentes_escola_2015_2025.rds).
#
# PACOTES ADICIONAIS (só usados neste script, por isso não estão em
# 00_setup.R — mantém 01/02 leves para quem só precisa do painel):
#   ggplot2, scales — gráficos
#   geobr, sf        — malha dos estados brasileiros para o mapa
#                      (geobr baixa o shapefile do IBGE na primeira vez
#                      que é chamado; requer internet)

source("R/00_setup.R")

pacotes_viz <- c("ggplot2", "scales", "geobr", "sf")
invisible(lapply(pacotes_viz, function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
}))

library(ggplot2)
library(scales)

dir_fig <- file.path("outputs", "figures")
if (!dir.exists(dir_fig)) dir.create(dir_fig, recursive = TRUE)

# ── Tema padrão do projeto: texto tamanho 14 em todos os gráficos ────────────
theme_set(theme_minimal(base_size = 14))

caminho_painel <- file.path(dir_proc, "painel_docentes_escola_2015_2025.rds")
if (!file.exists(caminho_painel)) {
  stop("Painel não encontrado em ", caminho_painel,
       ". Rode primeiro R/01_importar_docentes.R.")
}

painel_docentes <- readRDS(caminho_painel)

# Paleta única para as etapas, reaproveitada nos gráficos que as usam
cores_etapa <- c(
  "Infantil"              = "#1B9E77",
  "Fundamental - anos iniciais" = "#D95F02",
  "Fundamental - anos finais"   = "#7570B3",
  "Médio"                 = "#E7298A"
)

# ============================================================
# GRÁFICO 1 — Evolução do total de docentes por etapa (2015-2025)
# ============================================================

dist_etapa_ano <- painel_docentes[
  , .(
    "Infantil"                     = sum(QT_DOC_INF,     na.rm = TRUE),
    "Fundamental - anos iniciais"  = sum(QT_DOC_FUND_AI, na.rm = TRUE),
    "Fundamental - anos finais"    = sum(QT_DOC_FUND_AF, na.rm = TRUE),
    "Médio"                        = sum(QT_DOC_MED,     na.rm = TRUE)
  ),
  by = NU_ANO_CENSO
]

dist_etapa_long <- melt(
  dist_etapa_ano,
  id.vars       = "NU_ANO_CENSO",
  variable.name = "etapa",
  value.name    = "n_docentes"
)

g1 <- ggplot(dist_etapa_long, aes(x = NU_ANO_CENSO, y = n_docentes, color = etapa)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  scale_x_continuous(breaks = sort(unique(dist_etapa_long$NU_ANO_CENSO))) +
  scale_y_continuous(labels = label_number(big.mark = ".", decimal.mark = ",")) +
  scale_color_manual(values = cores_etapa) +
  labs(
    title    = "Docentes da educação básica por etapa — Brasil, 2015-2025",
    subtitle = "Fonte: Censo Escolar / INEP",
    x        = "Ano do Censo",
    y        = "Número de docentes",
    color    = "Etapa"
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "bottom"
  )

ggsave(file.path(dir_fig, "01_docentes_por_etapa_2015_2025.png"),
       g1, width = 10, height = 6.5, dpi = 300)

# ============================================================
# GRÁFICO 2 — Distribuição percentual por vínculo contratual (2025)
# ============================================================

vinculo_labels <- c(
  QT_DOC_BAS_VINCULO_CONCUR  = "Concursado/efetivo",
  QT_DOC_BAS_VINCULO_CONTRA  = "Contratado (não concursado)",
  QT_DOC_BAS_VINCULO_TERCEIR = "Terceirizado",
  QT_DOC_BAS_VINCULO_CLT     = "CLT"
)

dist_vinculo_2025 <- painel_docentes[
  NU_ANO_CENSO == 2025,
  .(
    QT_DOC_BAS_VINCULO_CONCUR  = sum(QT_DOC_BAS_VINCULO_CONCUR,  na.rm = TRUE),
    QT_DOC_BAS_VINCULO_CONTRA  = sum(QT_DOC_BAS_VINCULO_CONTRA,  na.rm = TRUE),
    QT_DOC_BAS_VINCULO_TERCEIR = sum(QT_DOC_BAS_VINCULO_TERCEIR, na.rm = TRUE),
    QT_DOC_BAS_VINCULO_CLT     = sum(QT_DOC_BAS_VINCULO_CLT,     na.rm = TRUE)
  )
]

dist_vinculo_long <- melt(
  dist_vinculo_2025,
  measure.vars  = names(vinculo_labels),
  variable.name = "vinculo",
  value.name    = "n_docentes"
)
dist_vinculo_long[, vinculo := vinculo_labels[as.character(vinculo)]]
dist_vinculo_long[, pct := round(100 * n_docentes / sum(n_docentes), 1)]

g2 <- ggplot(dist_vinculo_long,
             aes(x = reorder(vinculo, n_docentes), y = n_docentes)) +
  geom_col(fill = "#2C7FB8") +
  geom_text(aes(label = paste0(percent(pct / 100, accuracy = 0.1))),
            hjust = -0.1, size = 4.5) +
  coord_flip(clip = "off") +
  scale_y_continuous(labels = label_number(big.mark = ".", decimal.mark = ","),
                      expand = expansion(mult = c(0, .18))) +
  labs(
    title    = "Docentes por vínculo contratual — Brasil, 2025",
    subtitle = "Variável disponível somente a partir do Censo 2025 (ver README)",
    x        = NULL,
    y        = "Número de docentes"
  )

ggsave(file.path(dir_fig, "02_docentes_por_vinculo_2025.png"),
       g2, width = 10, height = 6, dpi = 300)

# ============================================================
# GRÁFICO 3 — Vínculo contratual por dependência administrativa (2025)
# ============================================================

dep_labels <- c(`1` = "Federal", `2` = "Estadual", `3` = "Municipal", `4` = "Privada")

dist_vinculo_dep_2025 <- painel_docentes[
  NU_ANO_CENSO == 2025 & !is.na(TP_DEPENDENCIA),
  .(
    QT_DOC_BAS_VINCULO_CONCUR  = sum(QT_DOC_BAS_VINCULO_CONCUR,  na.rm = TRUE),
    QT_DOC_BAS_VINCULO_CONTRA  = sum(QT_DOC_BAS_VINCULO_CONTRA,  na.rm = TRUE),
    QT_DOC_BAS_VINCULO_TERCEIR = sum(QT_DOC_BAS_VINCULO_TERCEIR, na.rm = TRUE),
    QT_DOC_BAS_VINCULO_CLT     = sum(QT_DOC_BAS_VINCULO_CLT,     na.rm = TRUE)
  ),
  by = TP_DEPENDENCIA
]

dist_vinculo_dep_long <- melt(
  dist_vinculo_dep_2025,
  id.vars       = "TP_DEPENDENCIA",
  measure.vars  = names(vinculo_labels),
  variable.name = "vinculo",
  value.name    = "n_docentes"
)
dist_vinculo_dep_long[, `:=`(
  dependencia = dep_labels[as.character(TP_DEPENDENCIA)],
  vinculo     = vinculo_labels[as.character(vinculo)]
)]
dist_vinculo_dep_long[, pct := round(100 * n_docentes / sum(n_docentes), 1),
                       by = dependencia]

g3 <- ggplot(dist_vinculo_dep_long,
             aes(x = dependencia, y = pct, fill = vinculo)) +
  geom_col(position = "stack") +
  scale_y_continuous(labels = label_percent(scale = 1)) +
  labs(
    title    = "Vínculo contratual por dependência administrativa — Brasil, 2025",
    subtitle = "% de docentes dentro de cada dependência",
    x        = "Dependência administrativa",
    y        = "% de docentes",
    fill     = "Vínculo"
  ) +
  theme(legend.position = "bottom")

ggsave(file.path(dir_fig, "03_vinculo_por_dependencia_2025.png"),
       g3, width = 10, height = 6.5, dpi = 300)

# ============================================================
# GRÁFICO 4 — Mapa do Brasil: distribuição de docentes por UF (2025)
# ============================================================
# geobr::read_state() baixa a malha dos estados do IBGE na primeira
# execução (fica em cache local depois). Requer internet na 1ª vez.

dist_uf_2025 <- painel_docentes[
  NU_ANO_CENSO == 2025 & !is.na(SG_UF) & SG_UF != "",
  .(
    doc_bas             = sum(QT_DOC_BAS, na.rm = TRUE),
    doc_vinculo_contrat  = sum(QT_DOC_BAS_VINCULO_CONTRA, na.rm = TRUE)
  ),
  by = SG_UF
]
dist_uf_2025[, pct_contratados := round(100 * doc_vinculo_contrat / doc_bas, 1)]

fwrite(dist_uf_2025, file.path(dir_out, "dist_docentes_uf_2025.csv"), sep = ";")

mapa_uf <- tryCatch(geobr::read_state(year = 2020, showProgress = FALSE),
                     error = function(e) {
                       message("[AVISO] Não foi possível baixar a malha de UFs (geobr). ",
                               "Verifique conexão com a internet. Erro: ", e$message)
                       NULL
                     })

if (!is.null(mapa_uf)) {

  mapa_uf_docentes <- merge(
    mapa_uf, dist_uf_2025,
    by.x = "abbrev_state", by.y = "SG_UF", all.x = TRUE
  )

  # ── 4a. Total de docentes por UF ──────────────────────────────────────────
  g4a <- ggplot(mapa_uf_docentes) +
    geom_sf(aes(fill = doc_bas), color = "white", linewidth = 0.2) +
    scale_fill_viridis_c(
      option = "viridis",
      labels = label_number(big.mark = ".", decimal.mark = ",")
    ) +
    labs(
      title    = "Total de docentes da educação básica por UF — Brasil, 2025",
      subtitle = "Fonte: Censo Escolar / INEP",
      fill     = "N° de\ndocentes"
    ) +
    theme_void(base_size = 14) +
    theme(legend.position = "right")

  ggsave(file.path(dir_fig, "04a_mapa_docentes_total_uf_2025.png"),
         g4a, width = 9, height = 8, dpi = 300)

  # ── 4b. % de docentes contratados (vínculo CONTRA) por UF ────────────────
  g4b <- ggplot(mapa_uf_docentes) +
    geom_sf(aes(fill = pct_contratados), color = "white", linewidth = 0.2) +
    scale_fill_viridis_c(option = "magma", labels = label_percent(scale = 1)) +
    labs(
      title    = "% de docentes com vínculo \"contratado\" por UF — Brasil, 2025",
      subtitle = "Vínculo contratual disponível somente a partir do Censo 2025",
      fill     = "% contratados"
    ) +
    theme_void(base_size = 14) +
    theme(legend.position = "right")

  ggsave(file.path(dir_fig, "04b_mapa_pct_contratados_uf_2025.png"),
         g4b, width = 9, height = 8, dpi = 300)

  message("[ok] Mapas salvos em ", dir_fig)
} else {
  message("[pulado] Mapas não gerados (geobr sem acesso à malha de UFs).")
}

# ============================================================
# GRÁFICO 5 — Mapa do Brasil: distribuição de docentes por MUNICÍPIO (2025)
# ============================================================
# geobr::read_municipality(code_muni = "all") baixa a malha dos ~5.570
# municípios do IBGE (arquivo pesado, fica em cache local depois da 1ª
# vez). Requer internet e pode levar alguns minutos na primeira execução.

dist_mun_2025 <- painel_docentes[
  NU_ANO_CENSO == 2025 & !is.na(CO_MUNICIPIO),
  .(
    doc_bas             = sum(QT_DOC_BAS, na.rm = TRUE),
    doc_vinculo_contrat = sum(QT_DOC_BAS_VINCULO_CONTRA, na.rm = TRUE)
  ),
  by = CO_MUNICIPIO
]
dist_mun_2025[, pct_contratados := round(100 * doc_vinculo_contrat / doc_bas, 1)]

fwrite(dist_mun_2025, file.path(dir_out, "dist_docentes_municipio_2025.csv"), sep = ";")

mapa_mun <- tryCatch(
  geobr::read_municipality(code_muni = "all", year = 2020, showProgress = FALSE),
  error = function(e) {
    message("[AVISO] Não foi possível baixar a malha de municípios (geobr). ",
            "Verifique conexão com a internet. Erro: ", e$message)
    NULL
  }
)

if (!is.null(mapa_mun)) {

  # code_muni no geobr tem 7 dígitos; CO_MUNICIPIO do Censo também —
  # ambos são convertidos para o mesmo tipo antes do join.
  mapa_mun[["code_muni"]] <- as.numeric(mapa_mun[["code_muni"]])
  dist_mun_2025[, CO_MUNICIPIO := as.numeric(CO_MUNICIPIO)]

  mapa_mun_docentes <- merge(
    mapa_mun, dist_mun_2025,
    by.x = "code_muni", by.y = "CO_MUNICIPIO", all.x = TRUE
  )

  # ── 5a. Total de docentes por município ───────────────────────────────────
  g5a <- ggplot(mapa_mun_docentes) +
    geom_sf(aes(fill = doc_bas), color = NA) +
    scale_fill_viridis_c(
      option    = "viridis",
      trans     = "log10",
      labels    = label_number(big.mark = ".", decimal.mark = ","),
      na.value  = "grey90"
    ) +
    labs(
      title    = "Total de docentes da educação básica por município — Brasil, 2025",
      subtitle = "Escala logarítmica (grande variação de tamanho entre municípios) | Fonte: Censo Escolar / INEP",
      fill     = "N° de\ndocentes"
    ) +
    theme_void(base_size = 14) +
    theme(legend.position = "right")

  ggsave(file.path(dir_fig, "05a_mapa_docentes_total_municipio_2025.png"),
         g5a, width = 9, height = 8, dpi = 300)

  # ── 5b. % de docentes contratados (vínculo CONTRA) por município ─────────
  g5b <- ggplot(mapa_mun_docentes) +
    geom_sf(aes(fill = pct_contratados), color = NA) +
    scale_fill_viridis_c(option = "magma", labels = label_percent(scale = 1),
                          na.value = "grey90") +
    labs(
      title    = "% de docentes com vínculo \"contratado\" por município — Brasil, 2025",
      subtitle = "Vínculo contratual disponível somente a partir do Censo 2025",
      fill     = "% contratados"
    ) +
    theme_void(base_size = 14) +
    theme(legend.position = "right")

  ggsave(file.path(dir_fig, "05b_mapa_pct_contratados_municipio_2025.png"),
         g5b, width = 9, height = 8, dpi = 300)

  message("[ok] Mapas municipais salvos em ", dir_fig)
} else {
  message("[pulado] Mapas municipais não gerados (geobr sem acesso à malha de municípios).")
}

message("\n>>> Gráficos salvos em: ", dir_fig)
