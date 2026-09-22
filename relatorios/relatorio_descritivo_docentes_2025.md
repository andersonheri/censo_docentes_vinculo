# Docentes da Educação Básica: Vínculo Contratual e Etapa de Ensino

### Relatório descritivo — Censo Escolar (INEP), com cruzamento ao IDEB

Data de referência: Censo Escolar 2025 (série histórica de etapa: 2015 a 2025) e IDEB 2025.
Fonte: microdados do Censo Escolar da Educação Básica (INEP) e divulgação oficial do IDEB (INEP).

---

## 1. Introdução e objetivo

Este relatório descreve o perfil dos docentes da educação básica brasileira em 2025, com foco em duas dimensões: a etapa de ensino em que atuam (educação infantil, anos iniciais e finais do fundamental, ensino médio) e, principalmente, o tipo de vínculo contratual que mantêm com a rede de ensino (concursado/efetivo, contratado temporário, CLT ou terceirizado). A pergunta central é simples de enunciar e relevante para a gestão educacional: que proporção do corpo docente brasileiro trabalha sem estabilidade de vínculo (contratos temporários, CLT ou terceirização), e como essa proporção varia entre redes de ensino, regiões, UFs e municípios?

Como desdobramento, o relatório também examina se essa característica do vínculo contratual está associada ao desempenho educacional medido pelo IDEB, testando a hipótese de que uma maior proporção de docentes contratados (em vez de concursados) esteja relacionada a resultados piores.

O relatório é descritivo: apresenta distribuições, comparações entre grupos e uma análise de correlação simples. Não se trata de uma análise causal, e as limitações de cada etapa são explicitadas ao longo do texto.

---

## 2. Fonte de dados e nota metodológica

**Etapa de ensino.** A variável de etapa (quantos docentes atuam na educação infantil, nos anos iniciais e finais do fundamental e no ensino médio) está disponível em todos os Censos Escolares de 2015 a 2025, permitindo observar a evolução da década.

**Vínculo contratual.** A variável de vínculo contratual do docente (`QT_DOC_BAS_VINCULO_CONCUR`, `_CONTRA`, `_TERCEIR`, `_CLT`) só passou a existir no Censo Escolar a partir da edição de 2025. Isso foi confirmado exaustivamente nos microdados de 2015 a 2024: a variável simplesmente não existe nessas edições. Por esse motivo, toda a análise de vínculo contratual deste relatório é um retrato do ano de 2025, sem série histórica.

**A variável de vínculo só é informada para a rede pública.** A rede privada (federal, estadual e municipal são as três redes públicas; a quarta categoria de dependência administrativa é a rede privada) não reporta essa informação ao Censo — as quatro categorias de vínculo aparecem como zero para 100% dos docentes da rede privada. Isso é coerente com a própria natureza da variável (vínculo estatutário/CLT/temporário é um conceito de gestão de pessoal do setor público) e é tratado de forma explícita ao longo do relatório: a rede privada representa 651.655 docentes da educação básica em 2025 (21,8% do total), e todos eles ficam fora do indicador de vínculo.

**Duas bases de cálculo para as percentagens de vínculo.** Ao longo do relatório, os percentuais de vínculo (concursado, contratado, CLT, terceirizado) aparecem calculados sobre duas bases diferentes, dependendo da comparação:

- **(a) sobre o total de docentes do grupo** (denominador = total de docentes da educação básica daquele grupo, incluindo a rede privada quando o grupo mistura redes, como uma UF ou um município). Essa é a base usada nos rankings por município e por UF.
- **(b) sobre o subtotal de docentes com vínculo efetivamente informado** (soma das quatro categorias de vínculo, que na prática coincide com a rede pública). Essa é a base usada nas comparações por rede de ensino, localização urbana/rural, região e no total nacional.

Como o "não informado" é, na prática, quase inteiramente a rede privada, os dois cálculos convergem dentro de um grupo 100% público (uma rede estadual, por exemplo) e diferem quando o grupo mistura rede pública e privada. Um exemplo concreto: nacionalmente, 32,3% do total geral de docentes são contratados (base a, denominador inclui a rede privada), mas 40,8% dos docentes com vínculo informado são contratados (base b, denominador é só quem responde a essa variável). Cada seção deste relatório indica qual base está sendo usada.

**IDEB.** O IDEB da edição 2025 já havia sido divulgado pelo INEP no momento desta análise, o que permitiu cruzar vínculo contratual (2025) e IDEB (2025) no mesmo ano, sem descompasso temporal. O IDEB não avalia a educação infantil (não há Saeb nessa etapa), então o cruzamento cobre apenas anos iniciais, anos finais e ensino médio. Além disso, na base de UF/região do IDEB, a etapa de Ensino Médio não possui uma linha agregada "rede pública" (a rede municipal não oferece ensino médio e a rede federal é residual e não aparece separada nessa aba); nesse caso específico, usou-se a rede Estadual como proxy da rede pública, o que é razoável dado que o ensino médio público é, na prática, quase inteiramente estadual.

---

## 3. Panorama geral do vínculo contratual dos docentes (Brasil, 2025)

Em 2025, o Brasil tinha 2.992.045 docentes na educação básica. Considerando o total geral de docentes (base a, incluindo a rede privada, que não informa vínculo):

| Vínculo | Docentes | % do total geral |
|---|---:|---:|
| Concursado/efetivo | 1.343.389 | 44,9% |
| Contratado (não concursado) | 967.599 | 32,3% |
| CLT | 42.311 | 1,4% |
| Terceirizado | 15.903 | 0,5% |
| Sem informação de vínculo (rede privada) | ≈ 622.843 | ≈ 20,9% |

Restringindo a leitura aos 2.369.202 docentes com vínculo efetivamente informado (base b, essencialmente a rede pública):

| Vínculo | % dos docentes com vínculo informado |
|---|---:|
| Concursado/efetivo | 56,7% |
| Contratado (não concursado) | 40,8% |
| CLT | 1,8% |
| Terceirizado | 0,7% |

A leitura central deste indicador é: **entre os docentes da rede pública, quase 2 em cada 5 (40,8%) não têm vínculo concursado** — trabalham sob contrato temporário. Esse é o grupo mais exposto a rotatividade, descontinuidade pedagógica e insegurança no emprego, e é o foco do restante deste relatório.

---

## 4. Vínculo por rede de ensino (dependência administrativa)

A proporção de docentes contratados varia de forma muito acentuada entre as quatro redes de ensino. Os percentuais abaixo usam a base (b): são calculados sobre o subtotal de docentes com vínculo informado dentro de cada rede.

| Rede | Docentes (educação básica) | Concursado/efetivo | Contratado | CLT | Terceirizado |
|---|---:|---:|---:|---:|---:|
| Federal | 40.052 | 85,8% | 13,5% | 0,3% | 0,4% |
| Estadual | 805.009 | 47,8% | 49,6% | 2,0% | 0,5% |
| Municipal | 1.495.329 | 60,7% | 36,9% | 1,7% | 0,7% |
| Privada | 651.655 | — não informa vínculo — | | | |

A rede **federal** é a mais estável: apenas 13,5% de seus docentes são contratados, refletindo o peso dos institutos federais e universidades federais com corpo docente concursado. A rede **estadual** é a mais dividida: praticamente meio a meio entre concursados (47,8%) e contratados (49,6%) — ou seja, é a rede pública com a maior dependência proporcional de contratação temporária. A rede **municipal**, embora tenha maioria concursada (60,7%), ainda apresenta uma parcela relevante de contratados (36,9%), sobre uma base de quase 1,5 milhão de docentes, o maior contingente entre as quatro redes.

*(Ver `outputs/figures/03_vinculo_por_dependencia_2025.png`)*

---

## 5. Vínculo por localização (urbana e rural)

| Localização | Docentes (educação básica) | Concursado/efetivo | Contratado | CLT | Terceirizado |
|---|---:|---:|---:|---:|---:|
| Urbana | 2.578.581 | 59,8% | 37,6% | 2,0% | 0,7% |
| Rural | 413.464 | 42,1% | 56,4% | 0,8% | 0,7% |

A diferença é grande e vai no sentido esperado: nas escolas rurais, a **maioria dos docentes (56,4%) é contratada**, contra 37,6% nas escolas urbanas. Isso sugere que a fragilidade do vínculo contratual não está distribuída de forma uniforme pelo território: escolas rurais, tipicamente mais distantes e com menor atratividade para concursos e fixação de efetivos, dependem proporcionalmente mais de contratação temporária para preencher vagas docentes.

*(Ver `outputs/figures/06_vinculo_por_localizacao_2025.png`)*

---

## 6. Vínculo por região e Unidade da Federação

### 6.1 Por região (base b, % sobre docentes com vínculo informado)

| Região | Concursado/efetivo | Contratado | CLT | Terceirizado |
|---|---:|---:|---:|---:|
| Sudeste | 60,6% | 35,2% | 3,4% | 0,8% |
| Sul | 58,3% | 39,6% | 1,6% | 0,5% |
| Norte | 55,2% | 44,3% | 0,4% | 0,1% |
| Nordeste | 52,5% | 46,2% | 0,4% | 0,9% |
| Centro-Oeste | 51,4% | 47,2% | 1,0% | 0,4% |

O Sudeste e o Sul são as regiões com maior proporção de docentes concursados. O Centro-Oeste, o Nordeste e o Norte concentram, proporcionalmente, mais docentes contratados — o Centro-Oeste é, nessa base de cálculo, a região com a maior fração de contratados (47,2%), seguida de perto pelo Nordeste (46,2%).

*(Ver `outputs/figures/10_vinculo_por_regiao_2025.png`)*

### 6.2 Por UF (base a, % contratados sobre o total geral de docentes da UF)

O ranking completo das 27 UFs está no gráfico `outputs/figures/12_ranking_uf_contratados_2025.png`. A média nacional nessa base é 32,3%. Destaques:

**Maiores proporções de docentes contratados:**

| UF | % contratados |
|---|---:|
| Acre (AC) | 67,7% |
| Espírito Santo (ES) | 54,8% |
| Mato Grosso do Sul (MS) | 53,5% |
| Alagoas (AL) | 49,4% |
| Maranhão (MA) | 46,9% |

**Menores proporções de docentes contratados:**

| UF | % contratados |
|---|---:|
| Rio de Janeiro (RJ) | 10,5% |
| Goiás (GO) | 22,2% |
| Rondônia (RO) | 23,1% |
| São Paulo (SP) | 23,5% |
| Paraná (PR) | 25,8% |

A diferença entre os extremos é enorme: o Acre tem uma proporção de docentes contratados **mais de seis vezes maior** que o Rio de Janeiro (67,7% contra 10,5%). Note que esse ranking usa base (a) (total geral de docentes, incluindo rede privada), o que explica por que os números não são diretamente comparáveis, célula a célula, com a tabela de regiões da seção 6.1 (que usa base b). Ainda assim, o padrão geral é o mesmo: UFs do Norte e Nordeste tendem a concentrações mais altas de contratação temporária, e UFs do Sudeste e Sul (com excepções, como o próprio ES) tendem a concentrações mais baixas.

---

## 7. Heterogeneidade municipal do vínculo contratual

A média de uma UF esconde uma variação interna muito maior entre seus municípios. Para captar essa dimensão, restringimos a análise a municípios com pelo menos 30 docentes (para evitar que municípios muito pequenos, onde um ou dois docentes já mudam o percentual drasticamente, distorçam o retrato).

### 7.1 Municípios com maior e menor % de docentes contratados (2025)

**10 maiores:**

| Município/UF | % contratados |
|---|---:|
| Bertópolis/MG | 96,4% |
| Santa Rosa do Purus/AC | 95,3% |
| Centro do Guilherme/MA | 95,2% |
| Carnaubeira da Penha/PE | 94,6% |
| Divino de São Lourenço/ES | 93,2% |
| Carmésia/MG | 93,1% |
| São João das Missões/MG | 92,9% |
| Acarape/CE | 92,2% |
| Mucurici/ES | 90,5% |
| Canapi/AL | 90,2% |

**10 menores:**

| Município/UF | % contratados |
|---|---:|
| Pinheiral/RJ | 1,1% |
| Piraí/RJ | 1,0% |
| Quatis/RJ | 0,8% |
| Feira de Santana/BA | 0,8% |
| Paty do Alferes/RJ | 0,2% |
| São José de Ubá/RJ | 0,0% |
| Lajedo do Tabocal/BA | 0,0% |
| Contendas do Sincorá/BA | 0,0% |
| Canápolis/BA | 0,0% |
| Aporá/BA | 0,0% |

A amplitude é total: de municípios onde **praticamente nenhum docente é contratado** (vários municípios da Bahia e do interior fluminense, próximos de 0%) até municípios onde **quase todo o corpo docente é contratado** (Bertópolis/MG, com 96,4%). É notável que municípios do Rio de Janeiro e da Bahia aparecem nos dois extremos da distribuição (RJ e BA concentram vários dos menores percentuais, mas municípios baianos e mineiros também aparecem entre os maiores), o que já é um indício de que a variação **dentro** de uma mesma UF pode ser tão ou mais importante que a variação **entre** UFs.

*(Ver `outputs/figures/11_ranking_municipios_contratados_2025.png`)*

### 7.2 Variabilidade dentro de cada UF (boxplot)

O gráfico de boxplot (`outputs/figures/13_boxplot_contratados_por_uf_2025.png`), com os municípios de cada UF ordenados pela mediana, confirma esse padrão: mesmo UFs com médias moderadas escondem amplitudes internas muito grandes. O Acre, por exemplo, tem mediana municipal alta (em torno de 70%) mas caixa (intervalo interquartil) que vai de aproximadamente 50% a 85%. Roraima e o Rio de Janeiro têm as caixas mais largas relativas à sua mediana, indicando municípios extremamente heterogêneos entre si dentro do mesmo estado. O Distrito Federal, por ser essencialmente um único município, aparece como uma linha praticamente sem variação (não há "outros municípios" do DF para comparar).

A conclusão prática desta seção é que **políticas ou diagnósticos formulados apenas no nível de UF podem mascarar realidades municipais muito distintas** — inclusive municípios com pouquíssima dependência de contratação temporária e municípios quase inteiramente dependentes dela, dentro do mesmo estado.

---

## 8. Evolução do quadro docente por etapa de ensino (2015 a 2025)

Diferente do vínculo contratual, a variável de etapa de ensino existe em toda a série 2015–2025, permitindo observar tendência.

| Ano | Total de docentes | % Infantil | % Anos iniciais | % Anos finais | % Ensino médio |
|---|---:|---:|---:|---:|---:|
| 2015 | 2.784.910 | 19,6% | 29,9% | 34,2% | 22,7% |
| 2020 | 2.757.776 | 22,7% | 29,8% | 33,2% | 22,3% |
| 2025 | 2.992.045 | 24,7% | 29,6% | 31,0% | 22,4% |

*(Nota: como um mesmo docente pode atuar em mais de uma etapa, essas participações não são mutuamente exclusivas e sua soma pode superar 100%; o que importa aqui é a variação de cada participação ao longo do tempo, não a soma.)*

O total de docentes da educação básica cresceu 7,4% na década (de 2,78 milhões para 2,99 milhões). O destaque da década é o crescimento da participação da **educação infantil**, que passou de 19,6% para 24,7% dos docentes — um aumento de 5,1 pontos percentuais, coerente com a expansão de creches e pré-escolas observada no período (em linha com metas do Plano Nacional de Educação para essa etapa). Em contrapartida, a participação dos **anos finais do fundamental** recuou de 34,2% para 31,0%. Anos iniciais e ensino médio mantiveram participação relativamente estável.

*(Ver `outputs/figures/01_docentes_por_etapa_2015_2025.png`)*

Olhando a composição por rede em 2025, o padrão de especialização por etapa é nítido: a rede **municipal** concentra a maior parte dos docentes de educação infantil e anos iniciais (reflexo do processo histórico de municipalização dessas etapas), a rede **estadual** concentra-se nos anos finais do fundamental e, sobretudo, no ensino médio, a rede **federal** atua quase exclusivamente no ensino médio (institutos federais), e a rede **privada** distribui seus docentes de forma relativamente equilibrada entre todas as etapas.

*(Ver `outputs/figures/08_etapa_por_dependencia_2015_2025.png` e `outputs/figures/09_etapa_por_localizacao_2015_2025.png`)*

---

## 9. Cruzamento entre vínculo contratual e desempenho educacional (IDEB)

Uma pergunta natural, dado o retrato acima, é se a maior dependência de docentes contratados está associada a um IDEB mais baixo. Essa seção testa essa hipótese, restrita à rede pública (federal, estadual e municipal, exceto no ensino médio a nível de UF, onde se usa a rede estadual como proxy — ver seção 2), no mesmo ano de referência (2025).

### 9.1 Correlação entre % de docentes contratados e IDEB

| Nível | Etapa | N | Pearson (r) | p-valor (Pearson) | Spearman (ρ) | p-valor (Spearman) |
|---|---|---:|---:|---:|---:|---:|
| Município | Anos Iniciais | 5.478 | -0,053 | 8,1 × 10⁻⁵ | -0,094 | 3,4 × 10⁻¹² |
| Município | Anos Finais | 5.491 | -0,039 | 3,6 × 10⁻³ | -0,088 | 6,5 × 10⁻¹¹ |
| Município | Ensino Médio | 5.428 | -0,110 | 5,6 × 10⁻¹⁶ | -0,125 | 2,6 × 10⁻²⁰ |
| UF | Anos Iniciais | 27 | 0,111 | 0,581 | 0,121 | 0,547 |
| UF | Anos Finais | 27 | 0,056 | 0,780 | 0,101 | 0,618 |
| UF | Ensino Médio | 27 | 0,077 | 0,702 | 0,062 | 0,757 |

A leitura correta desses números exige separar dois conceitos que costumam ser confundidos: **significância estatística** e **relevância prática**.

No nível **município**, com uma amostra grande (entre 5.400 e 5.500 municípios), todas as correlações são estatisticamente significativas (p-valores muito pequenos, bem abaixo de 0,05). Mas os coeficientes de correlação são muito baixos: variam entre -0,04 e -0,11, o que em termos de magnitude é uma correlação **fraca a desprezível**. Em outras palavras: com uma amostra grande, mesmo relações praticamente inexistentes tendem a aparecer como "estatisticamente significativas" — a significância aqui é, em boa parte, um artefato do tamanho da amostra, não evidência de uma relação forte ou substantiva entre as duas variáveis.

No nível **UF**, com apenas 27 observações, nenhuma correlação é estatisticamente significativa (todos os p-valores muito acima de 0,05, entre 0,55 e 0,78). Aqui não há evidência estatística de associação alguma.

O sinal da correlação, quando estatisticamente detectável (nível município), é sempre **negativo**: mais docentes contratados está associado a um IDEB levemente mais baixo, nunca mais alto. Esse sinal é consistente com a hipótese inicial (mais contratação temporária, pior desempenho), mas sua magnitude é pequena demais para sustentar qualquer afirmação de que o tipo de vínculo contratual seja, isoladamente, um fator explicativo relevante das diferenças de IDEB entre municípios.

*(Ver `outputs/figures/15_dispersao_contratados_ideb_municipio_2025.png` e `outputs/figures/16_dispersao_contratados_ideb_uf_2025.png`)*

### 9.2 Leitura visual

Os gráficos de dispersão (município e UF, um painel por etapa) tornam visível o que os números de correlação já indicam: as nuvens de pontos são dispersas e sem padrão visual claro, com uma linha de tendência praticamente plana (levemente descendente). Não há, visualmente, nenhum agrupamento que sugira um efeito de limiar (por exemplo, "acima de X% de contratados o IDEB despenca") nem uma relação linear forte em nenhuma direção.

---

## 10. Síntese das principais conclusões

1. **Quase 2 em cada 5 docentes da rede pública (40,8%) têm vínculo contratado, não concursado.** Esse é o número-chave do retrato de 2025: entre os docentes com vínculo informado (essencialmente a rede pública), a maioria ainda é concursada (56,7%), mas a fração de contratados temporários é grande demais para ser tratada como marginal.

2. **A rede privada (21,8% dos docentes) simplesmente não reporta essa informação ao Censo**, o que limita todo o indicador de vínculo à rede pública e deve ser lembrado sempre que se falar em "percentual de docentes contratados no Brasil".

3. **A estabilidade do vínculo varia muito entre as três redes públicas**: a rede federal é a mais estável (13,5% de contratados), a rede estadual é a mais dividida e a mais dependente de contratação temporária proporcionalmente (49,6%), e a rede municipal, apesar de majoritariamente concursada, ainda tem mais de um terço de seus docentes (36,9%) sob contrato temporário — sobre a maior base absoluta de docentes do país.

4. **A zona rural depende muito mais de contratação temporária que a zona urbana** (56,4% contra 37,6%), sugerindo que a fragilidade do vínculo contratual está concentrada nas áreas mais distantes e de menor atratividade para fixação de efetivos.

5. **Regionalmente, Centro-Oeste, Nordeste e Norte concentram, proporcionalmente, mais contratação temporária**; Sudeste e Sul concentram mais concursados. Ao nível de UF, a variação é enorme, indo de 10,5% (Rio de Janeiro) a 67,7% (Acre) — mais de seis vezes de diferença entre os extremos.

6. **A heterogeneidade municipal é ainda maior que a estadual.** Municípios variam de 0% a mais de 96% de docentes contratados, muitas vezes dentro da mesma UF, o que indica que diagnósticos e políticas formulados apenas no nível estadual podem mascarar realidades municipais completamente distintas.

7. **A educação infantil ganhou peso relativo na década (2015–2025)**, subindo de 19,6% para 24,7% da força docente, provavelmente refletindo a expansão de creches e pré-escolas no período; os anos finais do fundamental perderam peso relativo (de 34,2% para 31,0%).

8. **Não há evidência de que o tipo de vínculo contratual, isoladamente, explique diferenças relevantes de desempenho educacional (IDEB).** As correlações entre % de docentes contratados e IDEB são estatisticamente significativas ao nível de município (por conta do tamanho grande da amostra), mas de magnitude muito baixa (r entre -0,04 e -0,11); ao nível de UF, com apenas 27 observações, nenhuma correlação é estatisticamente significativa. O sinal, quando detectável, é sempre negativo (mais contratação, IDEB levemente menor), mas pequeno demais para ser tratado como uma explicação central. Outros fatores (contexto socioeconômico, infraestrutura escolar, formação docente, entre outros) provavelmente pesam muito mais na explicação das diferenças de IDEB do que o tipo de vínculo contratual isoladamente.

Em conjunto, esses resultados sugerem que o problema da contratação temporária no magistério público brasileiro é real, expressivo e desigualmente distribuído (por rede, por localização, por região e, principalmente, por município), mas que seu impacto direto e isolado sobre o indicador de desempenho educacional mais usado no país (o IDEB) é, com os dados de 2025, estatisticamente fraco. Isso não significa que o vínculo contratual seja irrelevante para a qualidade da educação — apenas que essa relação, se existir de forma mais substantiva, provavelmente opera de forma indireta ou em conjunto com outros fatores, e não como uma relação simples e direta capturada por uma correlação bivariada.

---

## Anexo — Lista de figuras e tabelas geradas

Todas as figuras referenciadas neste relatório estão em `outputs/figures/` e as tabelas de apoio em `outputs/tables/`, geradas pelos scripts em `R/` (ver `README.md` do projeto para o pipeline completo, executável via `run_all.R`).
