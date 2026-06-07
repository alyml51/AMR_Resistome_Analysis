# 03_pca_analysis.R
# Purpose: PCA analysis of resistance profiles

library(tidyverse)

# Set working directory
project_dir <- "E:/A-4137/AMR_Resistome_Analysis"
setwd(project_dir)

# Load merged dataset
source("scripts/01_merge_data.R")

# Create abundance matrix
pca_data <- resistance_split %>%
  filter(sample_type == "farm_sample") %>%
  group_by(sample_name, class) %>%
  summarise(
    abundance = sum(as.numeric(value), na.rm = TRUE)
  ) %>%
  
  pivot_wider(
    names_from = class,
    values_from = abundance,
    values_fill = 0
  )

# Convert to matrix
pca_matrix <- pca_data %>%
  column_to_rownames("sample_name")

# Remove zero variance columns
pca_matrix <- pca_matrix[, apply(pca_matrix, 2, var) != 0]

# Run PCA
pca_result <- prcomp(
  pca_matrix,
  scale. = TRUE
)

# Create PCA dataframe
pca_plot_data <- data.frame(
  Sample = rownames(pca_result$x),
  PC1 = pca_result$x[,1],
  PC2 = pca_result$x[,2]
)

# Check PCA data
head(pca_plot_data)

# PCA plot
pca_plot <- ggplot(pca_plot_data,
  aes(x = PC1, y = PC2)) +
  geom_point(size = 4,
    color = "#5B4B8A"
  ) +
  geom_text(
    aes(label = Sample),
    vjust = -1,
    size = 3
  ) +
  theme_minimal() +
  labs(
    title = "PCA of resistance profiles",
    x = "PC1",
    y = "PC2"
  ) +
  theme(
    plot.title = element_text(
      size = 16,
      face = "bold"
      ),
    axis.title = element_text(
      size = 13
      ),
    axis.text = element_text(
      size = 10)
  )

# Show PCA plot
pca_plot

# Save PCA figure
ggsave(
  "figures/pca_resistance_profiles.png",
  pca_plot,
  width = 8,
  height = 6
)

