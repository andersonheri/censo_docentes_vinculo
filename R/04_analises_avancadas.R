# ============================================================
# 04_analises_avancadas.R
# Análises adicionais para apresentação — ranking, variabilidade e
# resumo executivo do vínculo contratual dos docentes (Censo 2025)
# ============================================================
#
# O QUE ESTE SCRIPT FAZ:
#   11. Ranking dos 10 municípios com maior e menor % de docentes
#       contratados (2025), em um único gráfico
#   12. Ranking completo das 27 UFs por % de docentes contratados (2025)
#   13. Boxplot da % de contratados por UF, a partir dos municípios
#       dentro de cada UF (2025) — mostra a variabilidade que a média
#       por UF (gráficos 4b/12) esconde
#   14. Painel-resumo executivo: uma única imagem com os números-chave
#       (total de docentes, % contratados), o mapa por UF e o top-5
#       de UFs — pensado para abrir uma apresentação/relatório
#
# PRÉ-REQUISITO: rodar R/01_importar_docentes.R (o painel precisa
# existir em data/processed/painel_docentes_escola_2015_2025.rds).
#
# PACOTES ADICIONAIS: ggplot2, scales, geobr, sf (mapa do gráfico 14)
# e patchwork (para montar o painel-resumo a partir de vários ggplots).

source("R/00_setup.R")

pacotes_viz <- c("ggplot2", "scales", "geobr", "sf", "patchwork")
invisible(lapply(pacotes_viz, function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
}))

library(ggplot2)
library(scales)
library(patchwork)

dir_fig <- file.path("outputs", "figures")
if (!dir.exists(dir_fig)) dir.create(dir_fig, recursive = TRUE)

theme_set(theme_minimal(base_size = 14))

caminho_painel <- file.path(dir_proc, "painel_docentes_escola_2015_2025.rds")
if (!file.exists(caminho_painel)) {
  stop("Painel não encontrado em ", caminho_painel,
       ". Rode primeiro R/01_importar_docentes.R.")
}

painel_docentes <- readRDS(caminho_painel)

# Município com poucos docentes (ex.: 5 docentes, 1 contratado = 20%)
# distorce o ranking com ruído de amostra pequena. MIN_DOCENTES define
# o corte mínimo de QT_DOC_BAS para um município entrar nos rankings e
# no boxplot — valor arbitrário, mas comum em análises municipais para
# evitar que outliers de porte dominem a leitura.
MIN_DOCENTES <- 30

# ============================================================
# Base: docentes e vínculo por município (2025), com nome e UF
# ============================================================

dist_mun_2025_nome <- painel_docentes[
  NU_ANO_CENSO == 2025 & !is.na(CO_MUNICIPIO),
  .(
    doc_bas             = sum(QT_DOC_BAS, na.rm = TRUE),
    doc_vinculo_contrat = sum(QT_DOC_BAS_VINCULO_CONTRA, na.rm = TRUE)
  ),
  by = .(CO_MUNICIPIO, NO_MUNICIPIO, SG_UF)
]
dist_mun_2025_nome[, pct_contratados := round(100 * doc_vinculo_contrat / doc_bas, 1)]

fwrite(dist_mun_2025_nome,
       file.path(dir_out, "dist_docentes_municipio_nomeado_2025.csv"), sep = ";")

# ============================================================
# GRÁFICO 11 — Top/bottom 10 municípios por % de contratados (2025)
# ============================================================

mun_elegiveis <- dist_mun_2025_nome[doc_bas >= MIN_DOCENTES]

top10 <- mun_elegiveis[order(-pct_contratados)][1:10]
top10[, grupo := "10 maiores % de contratados"]

bottom10 <- mun_elegiveis[order(pct_contratados)][1:10]
bottom10[, grupo := "10 menores % de contratados"]

ranking_mun <- rbindlist(list(top10, bottom10))
ranking_mun[, municipio_uf := paste0(NO_MUNICIPIO, "/", SG_UF)]

g11 <- ggplot(ranking_mun,
              aes(x = reorder(municipio_uf, pct_contratados), y = pct_contratados,
                  fill = grupo)) +
  geom_col() +
  geom_text(aes(label = paste0(percent(pct_contratados / 100, accuracy = 0.1))),
            hjust = -0.1, size = 4) +
  coord_flip(clip = "off") +
  facet_wrap(~ grupo, scales = "free_y") +
  scale_fill_manual(values = c("10 maiores % de contratados" = "#D7301F",
                                "10 menores % de contratados" = "#2C7FB8")) +
  scale_y_continuous(labels = label_percent(scale = 1),
                      expand = expansion(mult = c(0, .25))) +
  labs(
    title    = "Municípios com maior e menor % de docentes contratados — Brasil, 2025",
    subtitle = paste0("Só municípios com pelo menos ", MIN_DOCENTES,
                       " docentes (evita ruído de amostra pequena)"),
    x        = NULL,
    y        = "% de docentes contratados"
  ) +
  theme(legend.position = "none")

ggsave(file.path(dir_fig, "11_ranking_municipios_contratados_2025.png"),
       g11, width = 12, height = 7, dpi = 300)

# ============================================================
# GRÁFICO 12 — Ranking completo das 27 UFs por % de contratados (2025)
# ============================================================

dist_uf_2025 <- painel_docentes[
  NU_ANO_CENSO == 2025 & !is.na(SG_UF) & SG_UF != "",
  .(
    doc_bas             = sum(QT_DOC_BAS, na.rm = TRUE),
    doc_vinculo_contrat = sum(QT_DOC_BAS_VINCULO_CONTRA, na.rm = TRUE)
  ),
  by = SG_UF
]
dist_uf_2025[, pct_contratados := round(100 * doc_vinculo_contrat / doc_bas, 1)]

media_brasil <- dist_uf_2025[, sum(doc_vinculo_contrat) / sum(doc_bas) * 100]

g12 <- ggplot(dist_uf_2025, aes(x = reorder(SG_UF, pct_contratados), y = pct_contratados)) +
  geom_col(fill = "#2C7FB8") +
  geom_hline(yintercept = media_brasil, linetype = "dashed", color = "#D7301F", linewidth = 0.7) +
  geom_text(aes(label = paste0(percent(pct_contratados / 100, accuracy = 0.1))),
            hjust = -0.15, size = 3.6) +
  annotate("text", x = 1.5, y = media_brasil, label = paste0("Média Brasil: ",
           percent(media_brasil / 100, accuracy = 0.1)),
           hjust = 0, vjust = -0.6, color = "#D7301F", size = 4) +
  coord_flip(clip = "off") +
  scale_y_continuous(labels = label_percent(scale = 1),
                      expand = expansion(mult = c(0, .18))) +
  labs(
    title    = "Ranking de UFs por % de docentes contratados — Brasil, 2025",
    subtitle = "Linha tracejada = média nacional",
    x        = NULL,
    y        = "% de docentes contratados"
  )

ggsave(file.path(dir_fig, "12_ranking_uf_contratados_2025.png"),
       g12, width = 9, height = 9, dpi = 300)

# ============================================================
# GRÁFICO 13 — Boxplot: variabilidade da % de contratados entre
# municípios, por UF (2025)
# ============================================================
# A média por UF (gráficos 4b/12) esconde a variação interna: uma UF
# pode ter média moderada mas municípios muito diferentes entre si.
# O boxplot mostra essa dispersão a partir dos municípios elegíveis
# (mesmo corte de MIN_DOCENTES do gráfico 11).

ordem_uf_mediana <- mun_elegiveis[
  , .(mediana = median(pct_contratados, na.rm = TRUE)), by = SG_UF
][order(mediana), SG_UF]

mun_elegiveis[, SG_UF := factor(SG_UF, levels = ordem_uf_mediana)]

g13 <- ggplot(mun_elegiveis, aes(x = SG_UF, y = pct_contratados)) +
  geom_boxplot(fill = "#2C7FB8", alpha = 0.6, outlier.size = 0.8) +
  coord_flip() +
  scale_y_continuous(labels = label_percent(scale = 1)) +
  labs(
    title    = "Variabilidade da % de contratados entre municípios, por UF — 2025",
    subtitle = paste0("Municípios com pelo menos ", MIN_DOCENTES,
                       " docentes | ordenado pela mediana"),
    x        = NULL,
    y        = "% de docentes contratados (por município)"
  )

ggsave(file.path(dir_fig, "13_boxplot_contratados_por_uf_2025.png"),
       g13, width = 9, height = 10, dpi = 300)

# ============================================================
# GRÁFICO 14 — Painel-resumo executivo (2025)
# ============================================================
# Combina indicadores-chave em uma única imagem (via patchwork):
# 2 "cartões" de número grande + mapa por UF + top-5 UFs.

doc_bas_total     <- dist_uf_2025[, sum(doc_bas)]
pct_contrat_total <- media_brasil

cartao_numero <- function(valor, rotulo, cor = "#2C7FB8") {
  ggplot() +
    annotate("text", x = 0, y = 0.6, label = valor, size = 13, fontface = "bold", color = cor) +
    annotate("text", x = 0, y = 0.15, label = rotulo, size = 5, color = "grey30") +
    xlim(-1, 1) + ylim(0, 1) +
    theme_void(base_size = 14)
}

cartao_total <- cartao_numero(
  label_number(big.mark = ".", decimal.mark = ",")(doc_bas_total),
  "docentes na educação básica (Brasil, 2025)"
)

cartao_pct <- cartao_numero(
  percent(pct_contrat_total / 100, accuracy = 0.1),
  "dos docentes têm vínculo \"contratado\" (não concursado)",
  cor = "#D7301F"
)

top5_uf <- dist_uf_2025[order(-pct_contratados)][1:5]

g_top5 <- ggplot(top5_uf, aes(x = reorder(SG_UF, pct_contratados), y = pct_contratados)) +
  geom_col(fill = "#D7301F") +
  geom_text(aes(label = paste0(percent(pct_contratados / 100, accuracy = 0.1))),
            hjust = -0.15, size = 4) +
  coord_flip(clip = "off") +
  scale_y_continuous(labels = label_percent(scale = 1),
                      expand = expansion(mult = c(0, .25))) +
  labs(title = "Top 5 UFs — % contratados", x = NULL, y = NULL) +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())

mapa_uf_resumo <- tryCatch(geobr::read_state(year = 2020, showProgress = FALSE),
                            error = function(e) {
                              message("[AVISO] Não foi possível baixar a malha de UFs (geobr). ",
                                      "Painel-resumo será montado sem o mapa. Erro: ", e$message)
                              NULL
                            })

if (!is.null(mapa_uf_resumo)) {
  mapa_uf_resumo_docentes <- merge(
    mapa_uf_resumo, dist_uf_2025, by.x = "abbrev_state", by.y = "SG_UF", all.x = TRUE
  )

  g_mapa_resumo <- ggplot(mapa_uf_resumo_docentes) +
    geom_sf(aes(fill = pct_contratados), color = "white", linewidth = 0.15) +
    scale_fill_viridis_c(option = "magma", labels = label_percent(scale = 1)) +
    labs(title = "% contratados por UF", fill = "%") +
    theme_void(base_size = 14) +
    theme(legend.position = "right")

  painel_resumo <-
    (cartao_total | cartao_pct) /
    (g_mapa_resumo | g_top5) +
    plot_layout(heights = c(1, 2.2)) +
    plot_annotation(
      title    = "Docentes da educação básica — vínculo contratual, Brasil 2025",
      subtitle = "Resumo executivo | Fonte: Censo Escolar / INEP",
      theme    = theme(plot.title = element_text(size = 18, face = "bold"),
                        plot.subtitle = element_text(size = 13, color = "grey30"))
    )

  ggsave(file.path(dir_fig, "14_painel_resumo_executivo_2025.png"),
         painel_resumo, width = 12, height = 11, dpi = 300)

  message("[ok] Painel-resumo executivo salvo em ", dir_fig)
} else {
  painel_resumo <-
    (cartao_total | cartao_pct) / g_top5 +
    plot_layout(heights = c(1, 1.6)) +
    plot_annotation(
      title    = "Docentes da educação básica — vínculo contratual, Brasil 2025",
      subtitle = "Resumo executivo (sem mapa — geobr indisponível) | Fonte: Censo Escolar / INEP",
      theme    = theme(plot.title = element_text(size = 18, face = "bold"),
                        plot.subtitle = element_text(size = 13, color = "grey30"))
    )

  ggsave(file.path(dir_fig, "14_painel_resumo_executivo_2025.png"),
         painel_resumo, width = 12, height = 8, dpi = 300)

  message("[pulado parcialmente] Painel-resumo salvo sem o mapa (geobr indisponível).")
}

message("\n>>> Análises avançadas salvas em: ", dir_fig, " e ", dir_out)
