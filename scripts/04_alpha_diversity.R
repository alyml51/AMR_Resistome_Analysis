# 04_alpha_diversity.R
# Purpose: Compare alpha diversity across corral types
# Input: data/resistance_split_processed.csv from 01_merge_data.R
# Output: alpha diversity summary tables and plots

# This analysis calculates alpha diversity metrics for each sample.
# Observed richness and Shannon diversity are used to compare resistome diversity between corral types.

# Load packages
library(tidyverse)
library(vegan)

# Set working directory
project_dir <- "E:/A-4137/AMR_Resistome_Analysis"

# Define project folders
data_dir <- file.path(project_dir, "data")
figures_dir <- file.path(project_dir, "figures")

# Load processed data from 01_merge_data.R
resistance_split <- read.csv(
  file.path(
    data_dir,
    "resistance_split_processed.csv"
  )
)

# Keep farm samples only
farm_data <- resistance_split %>%
  filter(sample_type == "farm_sample")

# Combine S1 and S into one category
farm_data <- farm_data %>%
  mutate(
    corral_type = ifelse(
      corral_type == "S1",
      "S",
      corral_type
    )
  )

# Summarise abundance by sample and resistance class
alpha_data <- farm_data %>%
  group_by(
    sample_name,
    farm_id,
    corral_type,
    class_group
  ) %>%
  summarise(
    abundance = sum(abundance,na.rm = TRUE),
    .groups = "drop"
  )

# Create sample by resistance class matrix
alpha_matrix <- alpha_data %>%
  select(
    sample_name,
    class_group,
    abundance
  ) %>%
  pivot_wider(
    names_from = class_group,
    values_from = abundance,
    values_fill = 0
  )

# Store sample information
sample_info <- alpha_data %>%
  distinct(
    sample_name,
    farm_id,
    corral_type
  )

# Check sample metadata duplicates
sample_info %>%
  count(sample_name) %>%
  filter(n > 1)

# Convert abundance table to matrix
alpha_matrix_values <- alpha_matrix %>%
  select(-sample_name) %>%
  as.matrix()

# Calculate observed richness
observed_richness <- specnumber(
  alpha_matrix_values
)

# Calculate Shannon diversity
shannon_index <- diversity(
  alpha_matrix_values,
  index = "shannon"
)

# Calculate inverse Simpson diversity
inverse_simpson <- diversity(
  alpha_matrix_values,
  index = "invsimpson"
)

# Create alpha diversity results table
alpha_results <- data.frame(
  sample_name = alpha_matrix$sample_name,
  richness = observed_richness,
  shannon = shannon_index,
  inverse_simpson = inverse_simpson
)

# Add sample metadata
alpha_results <- alpha_results %>%
  left_join(
    sample_info,
    by = "sample_name"
  )

# Save alpha diversity results
write.csv(
  alpha_results,
  file = file.path(
    data_dir,
    "alpha_diversity_results.csv"
  ),
  row.names = FALSE
)

# Check alpha diversity results
head(alpha_results)

# Check corral type counts
table(alpha_results$corral_type)

# Check missing values
colSums(is.na(alpha_results))

# Check alpha diversity summary
summary(alpha_results)

# Plot Shannon diversity by corral type
shannon_plot <- ggplot(
  alpha_results,
  aes(
    x = corral_type,
    y = shannon,
    fill = corral_type
  )
) +
  geom_boxplot(
    width = 0.4,
    alpha = 0.7
  ) +
  geom_jitter(
    width = 0.1,
    size = 2,
    alpha = 0.7
  ) +
  scale_fill_manual(
    values = c(
      "H" = "#E76F51",
      "S" = "#00A896"
    )
  ) +
  theme_bw() +
  labs(
    x = "Corral type",
    y = "Shannon diversity",
    fill = "Corral type"
  ) +
  theme(
    axis.text = element_text(size = 9),
    axis.title = element_text(size = 10),
    legend.position = "none"
  )

# Display plot
shannon_plot

# Save Shannon plot PDF
ggsave(
  filename = file.path(
    figures_dir,
    "shannon_plot.pdf"
  ),
  plot = shannon_plot,
  width = 6,
  height = 5
)

# Save Shannon plot PNG
ggsave(
  filename = file.path(
    figures_dir,
    "shannon_plot.png"
  ),
  plot = shannon_plot,
  width = 6,
  height = 5,
  dpi = 300
)

# Plot inverse Simpson diversity by corral type
inverse_simpson_plot <- ggplot(
  alpha_results,
  aes(
    x = corral_type,
    y = inverse_simpson,
    fill = corral_type
  )
) +
  geom_boxplot(
    width = 0.4,
    alpha = 0.7
  ) +
  geom_jitter(
    width = 0.1,
    size = 2,
    alpha = 0.7
  ) +
  scale_fill_manual(
    values = c(
      "H" = "#E76F51",
      "S" = "#00A896"
    )
  ) +
  theme_bw() +
  labs(
    x = "Corral type",
    y = "Inverse Simpson diversity",
    fill = "Corral type"
  ) +
  theme(
    axis.text = element_text(size = 9),
    axis.title = element_text(size = 10),
    legend.position = "none"
  )

# Display plot
inverse_simpson_plot

# Save inverse Simpson plot PDF
ggsave(
  filename = file.path(
    figures_dir,
    "inverse_simpson_plot.pdf"
  ),
  plot = inverse_simpson_plot,
  width = 6,
  height = 5
)

# Save inverse Simpson plot PNG
ggsave(
  filename = file.path(
    figures_dir,
    "inverse_simpson_plot.png"
  ),
  plot = inverse_simpson_plot,
  width = 6,
  height = 5,
  dpi = 300
)


# Compare Shannon diversity
wilcox.test(
  shannon ~ corral_type,
  data = alpha_results
)

# Compare inverse Simpson diversity
wilcox.test(
  inverse_simpson ~ corral_type,
  data = alpha_results
)

# Compare richness
wilcox.test(
  richness ~ corral_type,
  data = alpha_results
)
