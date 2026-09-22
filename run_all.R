# ============================================================
# run_all.R
# Executa o pipeline completo, na ordem correta, a partir da raiz
# do projeto (abrir censo_docentes_vinculo.Rproj antes de rodar).
# ============================================================

source("R/01_importar_docentes.R")
source("R/02_distribuicoes.R")
source("R/03_visualizacoes.R")
source("R/04_analises_avancadas.R")
source("R/05_importar_ideb.R")
source("R/06_cruzamento_ideb.R")