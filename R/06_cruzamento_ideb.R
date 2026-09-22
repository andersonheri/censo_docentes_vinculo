# ============================================================
# 06_cruzamento_ideb.R
# Cruzamento entre docentes (vínculo/etapa) e IDEB — município e UF
# ============================================================
#
# O QUE ESTE SCRIPT FAZ:
#   1. Monta uma base município x etapa (2025): % de docentes com
#      vínculo "contratado" e o IDEB de cada etapa, restrito à rede
#      PÚBLICA (Federal+Estadual+Municipal) — IDEB não avalia rede
#      privada nesse nível de agregação.
#   2. A mesma base agregada por UF.
#   3. Gráficos de dispersão (% contratados x IDEB), com linha de
#      tendência, um painel por etapa.
#   4. Tabela de correlação (Pearson e Spearman) entre % contratados e
#      IDEB, por etapa e nível (município/UF).
#
# ESCOPO E LIMITAÇÃO:
#   Vínculo contratual só existe no Censo 2025 (ver README). IDEB 2025
#   também já foi divulgado (confirmado em 05_importar_ideb.R), então
#   os dois lados do cruzamento são do MESMO ano — sem o descompasso
#   que motivou a mudança de plano combinada com o usuário.
#
#   IDEB não avalia educação infantil (não há Saeb nessa etapa), então
#   o cruzamento cobre Anos Iniciais, Anos Finais e Ensino Médio — não
#   Infantil.
#
# PRÉ-REQUISITO: rodar R/01_importar_docentes.R e R/05_importar_ideb.R
# antes (os três arquivos .rds usados abaixo precisam existir em
# data/processed/).

source("R/00_setup.R")

pacotes_viz <- c("ggplot2", "scales")
invisible(lapply(pacotes_viz, function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
}))

library(ggplot2)
library(scales)

dir_fig <- file.path("outputs", "figures")
if (!dir.exists(dir_fig)) dir.create(dir_fig, recursive = TRUE)

theme_set(theme_minimal(base_size = 14))

# ── Carrega os 3 insumos ──────────────────────────────────────────────────────
caminho_painel <- file.path(dir_proc, "painel_docentes_escola_2015_2025.rds")
caminho_ideb_mun <- file.path(dir_proc, "ideb_municipios_long.rds")
caminho_ideb_uf  <- file.path(dir_proc, "ideb_uf_long.rds")

for (caminho in c(caminho_painel, caminho_ideb_mun, caminho_ideb_uf)) {
  if (!file.exists(caminho)) {
    stop("Arquivo não encontrado: ", caminho, ". Rode primeiro ",
         "R/01_importar_docentes.R e R/05_importar_ideb.R.")
  }
}

painel_docentes <- readRDS(caminho_painel)
ideb_municipios <- readRDS(caminho_ideb_mun)
ideb_uf         <- readRDS(caminho_ideb_uf)

# ── Normalização de texto (acento-insensível) ────────────────────────────────
# Strings vindas de um .xlsx podem chegar em uma forma Unicode diferente da
# usada aqui no código-fonte (ex.: "á" como um único caractere pré-composto
# vs. "a" + acento combinante) — visualmente idênticas, mas que falham numa
# comparação exata como REDE == "Pública". `sem_acento()` remove essa
# ambiguidade comparando sem acento, em maiúsculas.
sem_acento <- function(x) toupper(trimws(iconv(as.character(x), to = "ASCII//TRANSLIT")))

# Rótulos de etapa alinhados entre os dois lados do cruzamento.
etapas_ideb <- c("Anos Iniciais", "Anos Finais", "Ensino Médio")

# Recanoniza etapa_ideb pela mesma razão (garante que os nomes das colunas
# geradas pelo dcast() mais abaixo batam exatamente com `etapas_ideb`).
normalizar_etapa <- function(x) {
  fcase(
    sem_acento(x) == "ANOS INICIAIS", "Anos Iniciais",
    sem_acento(x) == "ANOS FINAIS",   "Anos Finais",
    sem_acento(x) == "ENSINO MEDIO",  "Ensino Médio",
    default = as.character(x)
  )
}
ideb_municipios[, etapa_ideb := normalizar_etapa(etapa_ideb)]
ideb_uf[, etapa_ideb := normalizar_etapa(etapa_ideb)]

# ============================================================
# BLOCO 1 — Base MUNICÍPIO x etapa (2025, rede pública)
# ============================================================

# ── Lado docentes: agregado por município, só rede pública (Federal +
#    Estadual + Municipal — TP_DEPENDENCIA 1/2/3), para bater com o
#    escopo do IDEB nesse nível ─────────────────────────────────────────────
docentes_mun_2025 <- painel_docentes[
  NU_ANO_CENSO == 2025 & TP_DEPENDENCIA %in% c(1, 2, 3) & !is.na(CO_MUNICIPIO),
  .(
    doc_bas             = sum(QT_DOC_BAS,     na.rm = TRUE),
    doc_fund_ai         = sum(QT_DOC_FUND_AI, na.rm = TRUE),
    doc_fund_af         = sum(QT_DOC_FUND_AF, na.rm = TRUE),
    doc_med             = sum(QT_DOC_MED,     na.rm = TRUE),
    doc_vinculo_contrat = sum(QT_DOC_BAS_VINCULO_CONTRA, na.rm = TRUE)
  ),
  by = CO_MUNICIPIO
]
docentes_mun_2025[, pct_contratados := round(100 * doc_vinculo_contrat / doc_bas, 1)]

# ── Lado IDEB: rede pública, edição 2025, formato largo (1 coluna por
#    etapa) ───────────────────────────────────────────────────────────────
ideb_mun_2025 <- ideb_municipios[
  ano == 2025 & sem_acento(REDE) == "PUBLICA" & etapa_ideb %in% etapas_ideb
]
ideb_mun_2025_wide <- dcast(
  ideb_mun_2025, CO_MUNICIPIO ~ etapa_ideb, value.var = "ideb"
)

faltando <- setdiff(etapas_ideb, names(ideb_mun_2025_wide))
if (length(faltando) > 0) {
  stop("Depois de filtrar IDEB município (ano 2025, REDE Pública), faltam ",
       "colunas de etapa: ", paste(faltando, collapse = ", "), ". ",
       "Linhas restantes no filtro: ", nrow(ideb_mun_2025), ". Valores de ",
       "REDE disponíveis em ideb_municipios: ",
       paste(sort(unique(ideb_municipios$REDE)), collapse = " | "))
}

base_mun_2025 <- merge(docentes_mun_2025, ideb_mun_2025_wide,
                        by = "CO_MUNICIPIO", all.x = TRUE)

message(">>> Base município x etapa (2025, rede pública): ",
        format(nrow(base_mun_2025), big.mark = ".", decimal.mark = ","), " municípios")

fwrite(base_mun_2025, file.path(dir_out, "cruzamento_docentes_ideb_municipio_2025.csv"), sep = ";")

# ============================================================
# BLOCO 2 — Base UF x etapa (2025, rede pública)
# ============================================================

docentes_uf_2025 <- painel_docentes[
  NU_ANO_CENSO == 2025 & TP_DEPENDENCIA %in% c(1, 2, 3) & !is.na(SG_UF) & SG_UF != "",
  .(
    doc_bas             = sum(QT_DOC_BAS, na.rm = TRUE),
    doc_vinculo_contrat = sum(QT_DOC_BAS_VINCULO_CONTRA, na.rm = TRUE)
  ),
  by = SG_UF
]
docentes_uf_2025[, pct_contratados := round(100 * doc_vinculo_contrat / doc_bas, 1)]

# ideb_uf: NIVEL == "UF" filtra as 27 UFs (exclui as 5 linhas de região,
# que ficaram com SG_UF = NA — ver 05_importar_ideb.R).
ideb_uf_2025 <- ideb_uf[
  ano == 2025 & sem_acento(REDE) == "PUBLICA" & NIVEL == "UF" & etapa_ideb %in% etapas_ideb
]
ideb_uf_2025_wide <- dcast(ideb_uf_2025, SG_UF ~ etapa_ideb, value.var = "ideb")

faltando_uf <- setdiff(etapas_ideb, names(ideb_uf_2025_wide))
if (length(faltando_uf) > 0) {
  stop("Depois de filtrar IDEB UF (ano 2025, REDE Pública, NIVEL UF), faltam ",
       "colunas de etapa: ", paste(faltando_uf, collapse = ", "), ". ",
       "Linhas restantes no filtro: ", nrow(ideb_uf_2025), ". Valores de ",
       "REDE disponíveis em ideb_uf: ",
       paste(sort(unique(ideb_uf$REDE)), collapse = " | "))
}

base_uf_2025 <- merge(docentes_uf_2025, ideb_uf_2025_wide, by = "SG_UF", all.x = TRUE)

message(">>> Base UF x etapa (2025, rede pública): ",
        nrow(base_uf_2025), " UFs")

fwrite(base_uf_2025, file.path(dir_out, "cruzamento_docentes_ideb_uf_2025.csv"), sep = ";")

# ============================================================
# BLOCO 3 — Correlação entre % contratados e IDEB, por etapa e nível
# ============================================================

calcular_correlacoes <- function(base, nivel) {
  rbindlist(lapply(etapas_ideb, function(etapa) {
    x <- base$pct_contratados
    y <- base[[etapa]]
    ok <- stats::complete.cases(x, y)
    if (sum(ok) < 3) {
      return(data.table(nivel = nivel, etapa = etapa, n = sum(ok),
                         pearson = NA_real_, spearman = NA_real_))
    }
    data.table(
      nivel    = nivel,
      etapa    = etapa,
      n        = sum(ok),
      pearson  = round(cor(x[ok], y[ok], method = "pearson"), 3),
      spearman = round(cor(x[ok], y[ok], method = "spearman"), 3)
    )
  }))
}

correlacoes <- rbindlist(list(
  calcular_correlacoes(base_mun_2025, "Município"),
  calcular_correlacoes(base_uf_2025,  "UF")
))

message("\n=== Correlação entre % de docentes contratados e IDEB (2025, rede pública) ===")
print(correlacoes)

fwrite(correlacoes, file.path(dir_out, "correlacao_docentes_ideb_2025.csv"), sep = ";")

# ============================================================
# GRÁFICO 15 — Dispersão % contratados x IDEB, por etapa (MUNICÍPIO)
# ============================================================

base_mun_long <- melt(
  base_mun_2025,
  id.vars       = c("CO_MUNICIPIO", "pct_contratados"),
  measure.vars  = etapas_ideb,
  variable.name = "etapa_ideb",
  value.name    = "ideb"
)[!is.na(ideb)]

rotulos_corr_mun <- correlacoes[nivel == "Município",
                                 .(etapa, label = paste0("r = ", pearson))]
base_mun_long <- merge(base_mun_long, rotulos_corr_mun,
                        by.x = "etapa_ideb", by.y = "etapa", all.x = TRUE)

g15 <- ggplot(base_mun_long, aes(x = pct_contratados, y = ideb)) +
  geom_point(alpha = 0.15, size = 0.8, color = "#2C7FB8") +
  geom_smooth(method = "lm", se = TRUE, color = "#D7301F", linewidth = 1) +
  geom_text(
    data = unique(base_mun_long[, .(etapa_ideb, label)]),
    aes(x = 5, y = 9, label = label),
    inherit.aes = FALSE, hjust = 0, size = 5, color = "#D7301F"
  ) +
  facet_wrap(~ etapa_ideb) +
  scale_x_continuous(labels = label_percent(scale = 1)) +
  labs(
    title    = "% de docentes contratados x IDEB — municípios, 2025 (rede pública)",
    subtitle = "Cada ponto é um município | linha vermelha = tendência linear",
    x        = "% de docentes contratados",
    y        = "IDEB"
  )

ggsave(file.path(dir_fig, "15_dispersao_contratados_ideb_municipio_2025.png"),
       g15, width = 13, height = 6, dpi = 300)

# ============================================================
# GRÁFICO 16 — Dispersão % contratados x IDEB, por etapa (UF, rotulado)
# ============================================================

base_uf_long <- melt(
  base_uf_2025,
  id.vars       = c("SG_UF", "pct_contratados"),
  measure.vars  = etapas_ideb,
  variable.name = "etapa_ideb",
  value.name    = "ideb"
)[!is.na(ideb)]

rotulos_corr_uf <- correlacoes[nivel == "UF", .(etapa, label = paste0("r = ", pearson))]
base_uf_long <- merge(base_uf_long, rotulos_corr_uf,
                       by.x = "etapa_ideb", by.y = "etapa", all.x = TRUE)

g16 <- ggplot(base_uf_long, aes(x = pct_contratados, y = ideb)) +
  geom_smooth(method = "lm", se = TRUE, color = "#D7301F", linewidth = 1) +
  geom_point(color = "#2C7FB8", size = 2) +
  geom_text(aes(label = SG_UF), vjust = -0.8, size = 3.2) +
  geom_text(
    data = unique(base_uf_long[, .(etapa_ideb, label)]),
    aes(x = min(base_uf_long$pct_contratados, na.rm = TRUE), y = 8.5, label = label),
    inherit.aes = FALSE, hjust = 0, size = 5, color = "#D7301F"
  ) +
  facet_wrap(~ etapa_ideb) +
  scale_x_continuous(labels = label_percent(scale = 1)) +
  labs(
    title    = "% de docentes contratados x IDEB — UFs, 2025 (rede pública)",
    subtitle = "Cada ponto é uma UF | linha vermelha = tendência linear",
    x        = "% de docentes contratados",
    y        = "IDEB"
  )

ggsave(file.path(dir_fig, "16_dispersao_contratados_ideb_uf_2025.png"),
       g16, width = 13, height = 6, dpi = 300)

message("\n>>> Cruzamento salvo em: ", dir_out, " e ", dir_fig)
