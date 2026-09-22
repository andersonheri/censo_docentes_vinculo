# data/raw/

Esta pasta **não é versionada** no Git (ver `.gitignore` na raiz do projeto) —
os microdados do Censo Escolar são grandes (~200MB/ano) e de distribuição
pública, então não faz sentido subi-los ao GitHub.

## Como obter os dados

Fonte oficial: [Microdados do Censo Escolar — INEP](https://www.gov.br/inep/pt-br/acesso-a-informacao/dados-abertos/microdados/censo-escolar).

Baixe os pacotes de microdados de 2015 a 2025 e coloque nesta pasta os
seguintes arquivos, exatamente com estes nomes (os nomes e a extensão
maiúscula de 2020 refletem como o INEP distribui os arquivos):

```
microdados_ed_basica_2015.csv
microdados_ed_basica_2016.csv
microdados_ed_basica_2017.csv
microdados_ed_basica_2018.csv
microdados_ed_basica_2019.csv
microdados_ed_basica_2020.CSV   # extensão maiúscula (assim mesmo)
microdados_ed_basica_2021.csv
microdados_ed_basica_2022.csv
microdados_ed_basica_2023.csv
microdados_ed_basica_2024.csv
Tabela_Docente_2025.csv
Tabela_Escola_2025.csv
```

A partir de 2025 o INEP reestruturou o Censo Escolar em tabelas separadas
por assunto (Escola, Docente, Turma, Matrícula, Gestor Escolar, Curso
Técnico) — por isso 2025 usa dois arquivos (`Tabela_Docente_2025.csv` e
`Tabela_Escola_2025.csv`) em vez do arquivo único `microdados_ed_basica`.
Os demais arquivos de 2025 (Turma, Matrícula, Gestor, Curso Técnico) não
são usados neste projeto.

## Encoding e separador

Todos os arquivos usam separador `;` (ponto e vírgula) e encoding
Latin-1 (ISO-8859-1) — já tratado nos scripts de importação via
`data.table::fread(..., sep = ";", encoding = "Latin-1")`.
