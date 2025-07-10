# Análise de Regras de Associação com R

Este projeto realiza uma análise exploratória de regras de associação utilizando o algoritmo Apriori, aplicado a uma base de dados socioeconômicos de famílias. O objetivo é identificar padrões e relações entre características dos domicílios.

---

## Descrição do Projeto

Este script em R:

- Importa uma base de dados CSV com informações de famílias.
- Realiza amostragem aleatória para reduzir o volume de dados.
- Faz o pré-processamento e formatação das variáveis categóricas.
- Executa o algoritmo Apriori para extrair regras de associação com parâmetros definidos (support ≥ 0.1 e confidence ≥ 0.5).
- Seleciona as 10 regras mais relevantes baseadas no lift.
- Gera gráficos interativos e estáticos para análise visual das regras.
- Exporta os resultados para arquivo CSV.

---

## Tecnologias Utilizadas

- R (>= 4.0)
- Pacotes R:
  - **arules**: mineração de regras de associação  
  - **arulesViz**: visualização das regras  
  - **ggplot2**: gráficos estáticos avançados  
  - **plotly**: gráficos interativos 3D  
  - **RColorBrewer**: paletas de cores  

---

## Pré-requisitos

Instale os pacotes necessários:

```r
install.packages(c("arules", "arulesViz", "ggplot2", "plotly", "RColorBrewer"))
