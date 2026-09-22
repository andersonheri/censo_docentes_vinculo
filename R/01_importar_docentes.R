# ============================================================
# 01_importar_docentes.R
# Importação e consolidação do painel escola x ano — docentes
# Censo Escolar da Educação Básica (INEP) — 2015 a 2025
# ============================================================
#
# O QUE ESTE SCRIPT FAZ:
#   1. Lê os microdados 2015-2024 (um CSV por ano, nível escola),
#      selecionando apenas as colunas de identificação da escola e
#      as de quantidade de docentes por etapa.
#   2. Lê os microdados 2025, que o INEP reestruturou em tabelas
#      separadas por assunto (Tabela_Escola / Tabela_Docente), e
#      junta as duas pelo identificador da escola (CO_ENTIDADE).
#   3. Empilha os 11 anos em um único painel escola x ano.
#   4. Salva o painel consolidado em data/processed/.
#
# PRÉ-REQUISITO: os arquivos-fonte listados em 00_setup.R devem estar
# em data/raw/ (ver data/raw/README.md).
#
# ATENÇÃO — LIMITAÇÃO DOS DADOS (não é bug, é a estrutura real do Censo):
#   A variável de vínculo contratual do docente
#   (QT_DOC_BAS_VINCULO_CONCUR / _CONTRA / _TERCEIR / _CLT) só existe a
#   partir do Censo 2025. Isso foi checado exaustivamente nos 10 CSVs de
#   2015-2024 antes de escrever este script:
#     - Busca direta pelos 4 nomes de variável -> nenhuma ocorrência.
#     - Busca por sinônimos plausíveis (temporário, efetivo, estatutário,
#       concursado, CLT, terceirizado, PSS, contrato) -> nenhuma ocorrência
#       em nenhum dos 370 (2015) / 416 (2024) campos do arquivo.
#   Conclusão: o INEP não coletava essa informação nesse formato antes de
#   2025. Por isso, para 2015-2024 o painel traz somente o total de
#   docentes e a distribuição por etapa; o vínculo fica NA estrutural
#   nesses anos e só é populado em 2025.

source("R/00_setup.R")

# ============================================================
# BLOCO 1 — 2015 a 2024 (arquivo único "microdados_ed_basica",
#            nível escola, com contagens agregadas de docentes)
# ============================================================

#' Lê um ano do Censo Escolar (formato 2015-2024) já filtrado nas
#' colunas de interesse.
#'
#' @param ano string do ano (ex.: "2015")
#' @param arquivo nome do arquivo dentro de data/raw
#' @return data.table com 1 linha por escola
ler_ano_escola <- function(ano, arquivo) {
  caminho <- file.path(dir_raw, arquivo)
  message(">>> Lendo ", ano, ": ", arquivo)

  cols_pedidas <- c(vars_id, vars_doc_etapa)

  # `select` por NOME (não por posição): confirmado que a ORDEM das colunas
  # muda de ano para ano (ex.: CO_ENTIDADE é a 14ª coluna em 2015 e a 20ª em
  # 2024), mas os NOMES são estáveis — selecionar por nome é a forma robusta.
  dt <- fread(
    caminho,
    sep        = ";",
    select     = cols_pedidas,
    encoding   = "Latin-1",              # encoding padrão dos microdados INEP
    colClasses = list(character = c("SG_UF", "NO_MUNICIPIO", "NO_ENTIDADE"))
  )

  # Colunas de vínculo não existem nesses anos: criadas como NA estrutural
  # para permitir o rbind com o painel de 2025.
  for (v in vars_doc_vinculo) dt[[v]] <- NA_real_

  dt[, NU_ANO_CENSO := as.integer(ano)]
  message("    [ok] ", format(nrow(dt), big.mark = "."), " escolas")
  dt
}

lista_2015_2024 <- Map(ler_ano_escola,
                        names(arquivos_2015_2024),
                        arquivos_2015_2024)

painel_2015_2024 <- rbindlist(lista_2015_2024, use.names = TRUE, fill = TRUE)

message("\n>>> Painel 2015-2024: ", format(nrow(painel_2015_2024), big.mark = ","),
        " linhas")

# ============================================================
# BLOCO 2 — 2025 (tabelas separadas: Tabela_Docente + Tabela_Escola)
# ============================================================

message("\n>>> Lendo 2025 (Tabela_Docente + Tabela_Escola)...")

# Tabela_Docente_2025: 1 linha por escola, com as contagens de docentes
# (etapa e vínculo). Não traz UF/município/dependência — por isso o join
# com Tabela_Escola_2025 abaixo.
doc_2025 <- fread(
  file.path(dir_raw, arquivo_docente_2025),
  sep      = ";",
  select   = c("NU_ANO_CENSO", "CO_ENTIDADE", vars_doc_etapa, vars_doc_vinculo),
  encoding = "Latin-1"
)

esc_2025 <- fread(
  file.path(dir_raw, arquivo_escola_2025),
  sep        = ";",
  select     = vars_id,
  encoding   = "Latin-1",
  colClasses = list(character = c("SG_UF", "NO_MUNICIPIO", "NO_ENTIDADE"))
)
esc_2025[, NU_ANO_CENSO := NULL]  # já vem de doc_2025, evita coluna duplicada

painel_2025 <- merge(esc_2025, doc_2025, by = "CO_ENTIDADE", all.y = TRUE)

message(">>> Painel 2025: ", format(nrow(painel_2025), big.mark = ","), " linhas")

if (nrow(painel_2025) != nrow(doc_2025)) {
  warning("[ALERTA] O join Docente x Escola de 2025 alterou o número de ",
          "linhas — checar duplicatas de CO_ENTIDADE em Tabela_Escola_2025 ",
          "antes de usar o painel.")
}

# ============================================================
# BLOCO 3 — CONSOLIDAÇÃO E EXPORTAÇÃO
# ============================================================

painel_docentes <- rbindlist(
  list(painel_2015_2024, painel_2025),
  use.names = TRUE, fill = TRUE
)[order(NU_ANO_CENSO, CO_ENTIDADE)]

message("\n>>> PAINEL COMPLETO 2015-2025: ",
        format(nrow(painel_docentes), big.mark = ","), " linhas | ",
        ncol(painel_docentes), " colunas")

print(painel_docentes[, .N, by = NU_ANO_CENSO][order(NU_ANO_CENSO)])

# Checagem de sanidade: uma linha por escola/ano
dupl <- painel_docentes[, .N, by = .(CO_ENTIDADE, NU_ANO_CENSO)][N > 1]
if (nrow(dupl) > 0) {
  warning("[ALERTA] ", nrow(dupl), " combinações CO_ENTIDADE x NU_ANO_CENSO ",
          "duplicadas no painel final.")
} else {
  message("[ok] Sem duplicatas de chave CO_ENTIDADE x NU_ANO_CENSO.")
}

saveRDS(painel_docentes, file.path(dir_proc, "painel_docentes_escola_2015_2025.rds"))
fwrite(painel_docentes, file.path(dir_proc, "painel_docentes_escola_2015_2025.csv"), sep = ";")

message("\n>>> Painel salvo em: ", dir_proc)
