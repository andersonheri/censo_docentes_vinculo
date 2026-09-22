# ============================================================
# 05_importar_ideb.R
# Importação do IDEB (município e UF), todas as edições disponíveis
# ============================================================
#
# O QUE ESTE SCRIPT FAZ:
#   1. Baixa (se ainda não existirem em data/raw_ideb/) os arquivos
#      oficiais de divulgação do IDEB do INEP: município (anos
#      iniciais, anos finais e ensino médio) e UF/região.
#   2. Lê cada planilha de forma ADAPTATIVA: em vez de assumir uma
#      posição fixa de linha/coluna, localiza a linha de cabeçalho
#      procurando pela célula "CO_MUNICIPIO" (ou "SG_UF", no arquivo
#      de UF), e localiza as colunas de interesse por PADRÃO DE NOME
#      (regex), não por posição.
#   3. Converte cada planilha (formato largo, 1 coluna por edição) para
#      formato longo (1 linha por unidade x edição) e salva em
#      data/processed/.
#
# POR QUE ADAPTATIVO E NÃO POSIÇÃO FIXA:
#   A planilha de divulgação do IDEB tem cabeçalho em múltiplas linhas
#   mescladas, e o número de colunas por edição MUDA entre anos (edições
#   mais antigas têm taxa de aprovação detalhada por série 1º-5º ano;
#   edições mais recentes não). Um `skip` e uma lista fixa de nomes de
#   coluna quebrariam silenciosamente se o INEP mudar o arquivo, ou se
#   a inspeção manual da estrutura (feita sem conseguir rodar R) tiver
#   errado algum detalhe. Buscar por nome/regex é mais lento de
#   escrever, mas não depende de acertar a posição exata de memória.
#
# IMPORTANTE — RODE ISTO PRIMEIRO E CONFIRA O CONSOLE:
#   Como o cabeçalho foi inspecionado manualmente a partir do XML bruto
#   do .xlsx (sem conseguir testar em R), há checagens com `stopifnot()`
#   e mensagens que imprimem o que foi detectado (linha de cabeçalho,
#   colunas de identificação, colunas de IDEB encontradas, valores
#   únicos de "Rede"). Rode este script sozinho primeiro e confira essas
#   mensagens antes de seguir para o cruzamento com os docentes.

source("R/00_setup.R")

pacotes_ideb <- c("readxl")
invisible(lapply(pacotes_ideb, function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
}))

library(readxl)

# Os .zip do IDEB chegam a ~25MB; o timeout padrão de download.file() (60s)
# pode não bastar em conexões mais lentas.
options(timeout = max(300, getOption("timeout")))

dir_raw_ideb <- file.path("data", "raw_ideb")
if (!dir.exists(dir_raw_ideb)) dir.create(dir_raw_ideb, recursive = TRUE)

# ── Arquivos oficiais (edição 2025, que traz o histórico 2005-2025) ─────────
# Confirmado manualmente em set/2026: o INEP já publicou a divulgação do
# Ideb 2025 (https://www.gov.br/inep/.../ideb/resultados).
urls_ideb <- c(
  anos_iniciais_municipios = "https://download.inep.gov.br/ideb/resultados/divulgacao_anos_iniciais_municipios_2025.zip",
  anos_finais_municipios   = "https://download.inep.gov.br/ideb/resultados/divulgacao_anos_finais_municipios_2025.zip",
  ensino_medio_municipios  = "https://download.inep.gov.br/ideb/resultados/divulgacao_ensino_medio_municipios_2025.zip",
  regioes_ufs              = "https://download.inep.gov.br/ideb/resultados/divulgacao_regioes_ufs_ideb_2025.zip"
)

#' Baixa um arquivo tentando alguns métodos, na ordem, até um funcionar.
#' No Windows o método padrão do download.file() (`wininet`) às vezes
#' falha em HTTPS que `libcurl` resolve sem problema — por isso a
#' tentativa múltipla, em vez de travar no primeiro método que falhar.
baixar_com_fallback <- function(url, destino, metodos = c("libcurl", "wininet", "auto")) {
  for (metodo in metodos) {
    resultado <- tryCatch({
      download.file(url, destino, mode = "wb", quiet = FALSE, method = metodo)
      TRUE
    }, error = function(e) {
      message("    [falhou com method = '", metodo, "'] ", conditionMessage(e))
      FALSE
    })
    if (isTRUE(resultado) && file.exists(destino) && file.size(destino) > 0) {
      message("    [ok] Baixado com method = '", metodo, "'")
      return(invisible(TRUE))
    }
  }
  stop("Não consegui baixar ", url, " com nenhum dos métodos testados (",
       paste(metodos, collapse = ", "), "). Se sua rede usa proxy/firewall ",
       "corporativo, tente baixar esse arquivo manualmente pelo navegador e ",
       "salvar em '", destino, "'.")
}

#' Baixa e descompacta um arquivo do IDEB, se ainda não existir localmente.
#' Retorna o caminho do .xlsx extraído.
baixar_ideb <- function(nome, url) {
  destino_zip <- file.path(dir_raw_ideb, paste0(nome, ".zip"))
  dir_extraido <- file.path(dir_raw_ideb, nome)

  if (!dir.exists(dir_extraido)) {
    # file.size() > 0 evita reaproveitar um .zip de 0 bytes/corrompido
    # deixado por uma tentativa de download que falhou no meio.
    if (!file.exists(destino_zip) || file.size(destino_zip) == 0) {
      message(">>> Baixando ", nome, "...")
      baixar_com_fallback(url, destino_zip)
    }
    message(">>> Descompactando ", nome, "...")
    unzip(destino_zip, exdir = dir_extraido)
  }

  arquivos_xlsx <- list.files(dir_extraido, pattern = "\\.xlsx$",
                               recursive = TRUE, full.names = TRUE)
  if (length(arquivos_xlsx) == 0) {
    stop("Nenhum .xlsx encontrado em ", dir_extraido,
         " — confira se o download/descompactação funcionou.")
  }
  arquivos_xlsx[1]
}

# ============================================================
# Leitura adaptativa de uma planilha de divulgação do IDEB
# ============================================================

#' Lê uma planilha de divulgação do IDEB (município ou UF/região) e
#' devolve um data.table em formato LONGO: 1 linha por unidade x
#' edição x rede, com o valor do IDEB observado.
#'
#' @param caminho_xlsx caminho do arquivo .xlsx
#' @param coluna_ancora um ou mais nomes candidatos de coluna de
#'   identificação, usados para localizar a linha de cabeçalho (ex.:
#'   "CO_MUNICIPIO", ou c("SG_UF", "UF", "CO_UF") quando não se tem
#'   certeza do nome exato usado no arquivo)
#' @param aba nome ou índice da aba a ler (o arquivo de município tem 1
#'   aba só; o de UF/região tem 3 abas, uma por etapa — ver bloco de
#'   execução mais abaixo)
ler_ideb_xlsx <- function(caminho_xlsx, coluna_ancora, aba = 1) {

  message("\n>>> Lendo ", basename(caminho_xlsx), " [aba: ", aba, "]...")

  # 1) Lê um preview cru (sem cabeçalho) só para localizar em qual linha
  #    está a "âncora" (célula com um dos nomes candidatos, ex.:
  #    "CO_MUNICIPIO") e em qual linha estão os códigos "VL_OBSERVADO_*".
  #    20 linhas é folga suficiente: o cabeçalho observado tem 10 linhas.
  #    As duas buscas podem apontar para linhas diferentes se colunas de
  #    identificação e de valor estiverem "achatadas" em profundidades
  #    diferentes do cabeçalho mesclado — nesse caso usa-se a linha mais
  #    profunda (mais completa), com aviso.
  preview <- suppressMessages(
    read_excel(caminho_xlsx, sheet = aba, col_names = FALSE, n_max = 20)
  )

  linha_ancora <- which(apply(preview, 1, function(linha) {
    any(trimws(as.character(linha)) %in% coluna_ancora, na.rm = TRUE)
  }))[1]

  linha_ideb <- which(apply(preview, 1, function(linha) {
    any(grepl("^VL_OBSERVADO_\\d{4}$", trimws(as.character(linha))), na.rm = TRUE)
  }))[1]

  if (is.na(linha_ancora) && is.na(linha_ideb)) {
    stop("Não encontrei nem a(s) coluna(s)-âncora (", paste(coluna_ancora, collapse = " / "),
         ") nem colunas 'VL_OBSERVADO_<ano>' nas primeiras 20 linhas de ",
         caminho_xlsx, ". A estrutura do arquivo pode ter mudado — abra o ",
         "arquivo no Excel/LibreOffice e confira em qual linha está o ",
         "cabeçalho com esses nomes.")
  }

  linha_cabecalho <- max(c(linha_ancora, linha_ideb), na.rm = TRUE)

  if (!is.na(linha_ancora) && !is.na(linha_ideb) && linha_ancora != linha_ideb) {
    message("    [aviso] Âncora de identificação (linha ", linha_ancora,
            ") e colunas VL_OBSERVADO_<ano> (linha ", linha_ideb,
            ") apareceram em linhas diferentes do cabeçalho mesclado. ",
            "Usando a linha mais profunda (", linha_cabecalho, ") — confira ",
            "se as colunas de identificação abaixo saíram corretas.")
  }

  message("    [ok] Linha de cabeçalho detectada: ", linha_cabecalho)

  # 2) Relê a planilha inteira usando essa linha como cabeçalho.
  dados_bruto <- suppressMessages(
    read_excel(caminho_xlsx, sheet = aba, skip = linha_cabecalho - 1, col_names = TRUE)
  )
  names(dados_bruto) <- trimws(names(dados_bruto))
  setDT(dados_bruto)

  # 3) Colunas de valor do IDEB observado, uma por edição — padrão
  #    confirmado na inspeção manual do arquivo: VL_OBSERVADO_<ano>.
  #    Calculado ANTES da detecção de colunas de identificação porque é
  #    usado logo abaixo para descartar linhas de rodapé.
  cols_ideb <- grep("^VL_OBSERVADO_\\d{4}$", names(dados_bruto), value = TRUE)
  if (length(cols_ideb) == 0) {
    stop("Nenhuma coluna 'VL_OBSERVADO_<ano>' encontrada em ", caminho_xlsx,
         ". O padrão de nome pode ter mudado — confira os nomes de coluna ",
         "reais com names(readxl::read_excel('", caminho_xlsx, "', skip = ",
         linha_cabecalho - 1, ")).")
  }

  # 3b) Descarta linhas de rodapé/nota (ex.: "Fonte: MEC/Inep", "(*) Média
  # calculada a partir de...") que a planilha do INEP deixa no final,
  # abaixo da última linha de dado real. Como essas linhas de nota não
  # têm nenhum valor de IDEB preenchido (só texto explicativo em uma
  # célula mesclada), o critério "tem pelo menos 1 edição não-NA" separa
  # dado real de rodapé sem depender de saber a última linha de dado.
  n_antes <- nrow(dados_bruto)
  linhas_com_dado <- rowSums(!is.na(dados_bruto[, ..cols_ideb])) > 0
  dados_bruto <- dados_bruto[linhas_com_dado]
  message("    [ok] ", n_antes - nrow(dados_bruto), " linha(s) de rodapé/nota ",
          "descartada(s) (sem nenhum valor de IDEB preenchido); ",
          nrow(dados_bruto), " linhas de dado real restantes")

  # Colunas sem nome (restos de mesclagem) e duplicadas viram NA/"...N"
  # pelo próprio readxl. A maioria é lixo de mesclagem e pode ser
  # descartada, mas no arquivo de UF/região a própria coluna de
  # identificação (Região/UF) não tem rótulo na linha de cabeçalho
  # "achatada" e cai nesse grupo — por isso `dados_bruto` (sem remover
  # nada) é mantido à parte para o fallback por valor mais abaixo.
  dados <- dados_bruto[, !grepl("^\\.\\.\\.|^NA$|^$", names(dados_bruto)), with = FALSE]

  # 4) Colunas de identificação, localizadas por nome (não por posição).
  col_uf    <- grep("^SG_UF$|^UF$|^CO_UF$|Sigla da UF", names(dados), value = TRUE)[1]
  col_mun   <- grep("^CO_MUNICIPIO$", names(dados), value = TRUE)[1]
  # Regex de MUNICIPIO sozinho também casaria com "CO_MUNICIPIO" (código);
  # por isso exige que o nome comece com NO_/NOME (nunca com CO_/SG_), e
  # exclui explicitamente o que já foi capturado em col_mun.
  col_nome  <- setdiff(
    grep("^NO_MUNICIPIO$|^NOME.*MUNIC[IÍ]PIO", names(dados),
         value = TRUE, ignore.case = TRUE),
    col_mun
  )[1]
  col_rede  <- grep("^REDE$", names(dados), value = TRUE, ignore.case = TRUE)[1]

  # 4b) Fallback POR VALOR (não por nome): se nenhuma coluna com nome
  # SG_UF/UF foi encontrada, procura entre as colunas SEM NOME (as que
  # foram descartadas de `dados` acima) uma cujos valores sejam quase
  # todos siglas de UF ou nomes de região — típico do arquivo de
  # UF/região, cuja coluna de identificação não tem rótulo na linha de
  # cabeçalho achatada. Já roda sobre `dados_bruto` SEM as linhas de
  # rodapé (passo 3b), então o texto de nota não atrapalha mais aqui.
  if (is.na(col_uf) && is.na(col_mun)) {
    vocabulario_uf <- c(names(uf_regiao), unique(uf_regiao), "Brasil", "BR")
    candidatos <- names(dados_bruto)[vapply(dados_bruto, function(col) {
      valores <- na.omit(as.character(col))
      length(valores) > 0 && mean(valores %in% vocabulario_uf) > 0.8
    }, logical(1))]

    if (length(candidatos) >= 1) {
      col_uf <- candidatos[1]
      dados[[col_uf]] <- dados_bruto[[col_uf]]
      message("    [fallback por valor] Nenhuma coluna nomeada SG_UF/UF; ",
              "detectei '", col_uf, "' pelo conteúdo (siglas de UF/nomes ",
              "de região). Confira os valores abaixo.")
    }
  }

  message("    Colunas de identificação encontradas: ",
          paste(na.omit(c(col_uf, col_mun, col_nome, col_rede)), collapse = ", "))
  message("    Colunas de IDEB (VL_OBSERVADO_<ano>) encontradas: ",
          length(cols_ideb), " -> ", paste(sort(cols_ideb), collapse = ", "))
  if (!is.na(col_uf)) {
    message("    Valores únicos de '", col_uf, "': ",
            paste(sort(unique(dados[[col_uf]])), collapse = " | "))
  }

  if (is.na(col_mun) && is.na(col_uf)) {
    # Diagnóstico: em vez de só falhar, mostra uma amostra de cada coluna
    # "candidata" (as que sobraram sem nome, tipicamente onde a
    # identificação mora quando não tem rótulo na linha de cabeçalho),
    # para decidir o próximo ajuste sem outra rodada de tentativa e erro.
    cols_sem_nome <- names(dados_bruto)[grepl("^\\.\\.\\.|^NA$|^$", names(dados_bruto))]
    message("    [diagnóstico] Nenhuma coluna de UF/município identificada. ",
            "Colunas sem nome no cabeçalho (candidatas mais prováveis): ",
            paste(cols_sem_nome, collapse = ", "))
    for (col in cols_sem_nome) {
      valores <- na.omit(as.character(dados_bruto[[col]]))
      amostra <- unique(valores)
      message("      '", col, "' (", length(valores), " valores não-NA, ",
              length(amostra), " únicos): ",
              paste(head(amostra, 15), collapse = " | "),
              if (length(amostra) > 15) " | ..." else "")
    }
    stop("Não encontrei nem CO_MUNICIPIO nem SG_UF/UF em ", caminho_xlsx,
         ". Veja o diagnóstico acima (colunas sem nome e uma amostra de ",
         "valores) para decidir qual é a coluna de identificação.")
  }

  cols_id <- na.omit(c(SG_UF = col_uf, CO_MUNICIPIO = col_mun,
                        NO_MUNICIPIO = col_nome, REDE = col_rede))

  if (anyDuplicated(cols_id)) {
    stop("A mesma coluna do arquivo foi identificada para mais de um papel ",
         "(", paste(names(cols_id)[duplicated(cols_id) | duplicated(cols_id, fromLast = TRUE)],
                     collapse = ", "), " apontam para a coluna '",
         cols_id[duplicated(cols_id)][1], "'). Ajuste os regex de detecção ",
         "em ler_ideb_xlsx() para essa planilha.")
  }

  if (!is.na(col_rede)) {
    message("    Valores únicos de '", col_rede, "': ",
            paste(sort(unique(dados[[col_rede]])), collapse = " | "))
  }

  # 5) Formato longo: 1 linha por unidade x rede x edição.
  longo <- melt(
    dados,
    id.vars       = unname(cols_id),
    measure.vars  = cols_ideb,
    variable.name = "coluna_ideb",
    value.name    = "ideb"
  )
  longo[, ano := as.integer(sub("^VL_OBSERVADO_", "", coluna_ideb))]
  longo[, coluna_ideb := NULL]

  # "ND", "ND*", "-" etc. viram NA; vírgula decimal vira ponto.
  longo[, ideb := suppressWarnings(as.numeric(
    gsub(",", ".", as.character(ideb))
  ))]

  # Renomeia para os nomes canônicos usados no resto do projeto.
  setnames(longo, unname(cols_id), names(cols_id))

  message("    [ok] ", format(nrow(longo), big.mark = ".", decimal.mark = ","),
          " linhas no formato longo (", length(unique(longo$ano)), " edições)")

  longo[]
}

# ============================================================
# Execução: município (3 etapas) e UF/região
# ============================================================

etapas_municipio <- c(
  anos_iniciais_municipios = "Anos Iniciais",
  anos_finais_municipios   = "Anos Finais",
  ensino_medio_municipios  = "Ensino Médio"
)

lista_ideb_mun <- lapply(names(etapas_municipio), function(nome) {
  caminho <- baixar_ideb(nome, urls_ideb[[nome]])
  dt <- ler_ideb_xlsx(caminho, coluna_ancora = c("CO_MUNICIPIO", "Código do Município"))
  dt[, etapa_ideb := etapas_municipio[[nome]]]
  dt
})

ideb_municipios <- rbindlist(lista_ideb_mun, use.names = TRUE, fill = TRUE)

message("\n>>> IDEB município (todas as etapas): ",
        format(nrow(ideb_municipios), big.mark = ",", decimal.mark = "."), " linhas")

saveRDS(ideb_municipios, file.path(dir_proc, "ideb_municipios_long.rds"))
fwrite(ideb_municipios, file.path(dir_proc, "ideb_municipios_long.csv"), sep = ";")

# ── UF/região: a mesma planilha traz as 3 etapas em ABAS separadas
#    (confirmado inspecionando o arquivo: "UF e Regiões (AI)", "(AF)",
#    "(EM)"), diferente dos municípios, que vêm em 3 arquivos .zip
#    separados. Por isso cada aba é lida individualmente.
caminho_uf <- baixar_ideb("regioes_ufs", urls_ideb[["regioes_ufs"]])

abas_uf <- c(
  "Anos Iniciais" = "UF e Regiões (AI)",
  "Anos Finais"   = "UF e Regiões (AF)",
  "Ensino Médio"  = "UF e Regiões (EM)"
)

lista_ideb_uf <- lapply(names(abas_uf), function(etapa) {
  dt <- ler_ideb_xlsx(caminho_uf,
                       coluna_ancora = c("SG_UF", "UF", "CO_UF", "Sigla da UF"),
                       aba = abas_uf[[etapa]])
  dt[, etapa_ideb := etapa]
  dt
})

ideb_uf <- rbindlist(lista_ideb_uf, use.names = TRUE, fill = TRUE)

message("\n>>> IDEB UF/região: ", format(nrow(ideb_uf), big.mark = ",", decimal.mark = "."), " linhas")

saveRDS(ideb_uf, file.path(dir_proc, "ideb_uf_long.rds"))
fwrite(ideb_uf, file.path(dir_proc, "ideb_uf_long.csv"), sep = ";")

message("\n>>> IDEB importado e salvo em: ", dir_proc)
message(">>> CONFIRA as mensagens acima (linha de cabeçalho, colunas e ",
        "valores de 'Rede' detectados) antes de seguir para o cruzamento ",
        "com os docentes.")
