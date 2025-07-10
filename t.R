library(arules)
library(arulesViz)
library(ggplot2)
library(RColorBrewer)
library(plotly)

# Ler os dados
dados <- read.csv("C:/Users/gabriel/Downloads/mineração/base_amostra_familia_201812.csv", stringsAsFactors = FALSE)

# Verificar as primeiras linhas dos dados
head(dados)

# Definir a quantidade desejada de dados (50%)
n <- round(nrow(dados) * 0.10)

# Amostrar aleatoriamente 50% dos dados
set.seed(123)  # Para garantir a reprodutibilidade
dados_amostra <- dados[sample(nrow(dados), n), , drop = FALSE]

# Exemplo de divisão da coluna em várias colunas
dados_split <- strsplit(dados_amostra[, 1], ";")
dados_split <- do.call(rbind, dados_split)

# Definir os nomes das colunas manualmente
col_names <- c("cd_ibge", "estrato", "classf", "id_familia", "dat_cadastramento_fam", 
               "dat_alteracao_fam", "vlr_renda_media_fam", "dat_atualizacao_familia", 
               "cod_local_domic_fam", "cod_especie_domic_fam", "qtd_comodos_domic_fam", 
               "qtd_comodos_dormitorio_fam", "cod_material_piso_fam", "cod_material_domic_fam", 
               "cod_agua_canalizada_fam", "cod_abaste_agua_domic_fam", "cod_banheiro_domic_fam", 
               "cod_escoa_sanitario_domic_fam", "cod_destino_lixo_domic_fam", 
               "cod_iluminacao_domic_fam", "cod_calcamento_domic_fam", "cod_familia_indigena_fam", 
               "ind_familia_quilombola_fam", "nom_estab_assist_saude_fam", "cod_eas_fam", 
               "nom_centro_assist_fam", "cod_centro_assist_fam", "ind_parc_mds_fam", 
               "marc_pbf", "qtde_pessoas", "peso_fam")

colnames(dados_split) <- col_names
dados_amostra <- as.data.frame(dados_split, stringsAsFactors = FALSE)

# Verificar se as colunas existem na amostra
cols <- c("qtd_comodos_dormitorio_fam", "cod_material_piso_fam", "cod_agua_canalizada_fam")
if (!all(cols %in% colnames(dados_amostra))) {
  stop("Uma ou mais colunas necessárias não foram encontradas na amostra.")
}

# Criar um dataframe com os dados relevantes da amostra
dados_comodos <- dados_amostra[, cols, drop = FALSE]

# Transformar as variáveis em fatores
dados_comodos$qtd_comodos_dormitorio_fam <- as.factor(dados_comodos$qtd_comodos_dormitorio_fam)
dados_comodos$cod_material_piso_fam <- as.factor(dados_comodos$cod_material_piso_fam)
dados_comodos$cod_agua_canalizada_fam <- as.factor(dados_comodos$cod_agua_canalizada_fam)

# Aplicar o algoritmo de regras de associação
regras_comodos <- apriori(dados_comodos, parameter = list(support = 0.1, confidence = 0.5))
print(as(regras_comodos, "data.frame"))

# Ordenar e selecionar as 10 melhores regras
regras_top10 <- head(sort(regras_comodos, by = "lift", decreasing = TRUE), 10)

# Converter as regras para um dataframe
regras_df <- as(regras_top10, "data.frame")
regras_df$rule <- factor(regras_df$rules, levels = regras_df$rules[order(regras_df$lift, decreasing = TRUE)])

# Gráfico 3D com suporte, confiança e lift
fig <- plot_ly(regras_df, x = ~support, y = ~confidence, z = ~lift, text = ~rules, type = 'scatter3d', mode = 'markers',
               marker = list(size = 5, color = ~lift, colorscale = 'Viridis', showscale = TRUE))

fig <- fig %>% layout(scene = list(
  xaxis = list(title = 'Support'),
  yaxis = list(title = 'Confidence'),
  zaxis = list(title = 'Lift')
))

fig <- fig %>% layout(title = 'Regras de Associação: Support vs Confidence vs Lift')

# Mostrar o gráfico 3D
fig

# Gráfico 2D com ggplot2
ggplot(regras_df, aes(x = support, y = confidence, size = lift, color = lift)) +
  geom_point(alpha = 0.7) +
  scale_color_gradient(low = "blue", high = "red") +
  labs(title = "Regras de Associação: Support vs Confidence",
       x = "Support", y = "Confidence", size = "Lift", color = "Lift") +
  theme_minimal() +
  theme(legend.position = "right")

# Gráfico de barras melhorado
ggplot(regras_df, aes(x = rule, y = lift, fill = lift)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  scale_fill_gradient(low = "blue", high = "red") +
  labs(title = "Top 10 Regras de Associação por Lift", x = "Regras", y = "Lift") +
  theme_minimal() +
  geom_text(aes(label = round(lift, 2)), hjust = -0.2, color = "black")

# Extrair as métricas das regras
lift <- quality(regras_top10)$lift
count <- quality(regras_top10)$count
support <- quality(regras_top10)$support
confidence <- quality(regras_top10)$confidence

# Extrair as regras associadas (lhs e rhs) e combiná-las em uma string
rules <- paste0("{", labels(lhs(regras_top10)), "} => {", labels(rhs(regras_top10)), "}")

# Criar a tabela de regras com colunas separadas
tabela_regras <- data.frame(
  rules = rules,
  lift = lift,
  count = count,
  support = support,
  confidence = confidence
)

# Escrever a tabela em um arquivo CSV
write.csv(tabela_regras, file = "tabela_regras.csv", row.names = FALSE)
