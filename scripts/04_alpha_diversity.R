# 04_alpha_diversity.R
# Purpose: Compare resistome alpha diversity across corral types
# Input: data/resistance_split_processed.csv from 01_merge_data.R
# Output: Hill number summary tables and alpha diversity plots

# Hill numbers (q0, q1, q2) are calculated to compare resistome alpha diversity between corral types.

# Load packages
library(tidyverse)
library(vegan)

# Set seed for reproducible jitter positions
set.seed(123)

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

# Summarise abundance by sample and resistance class group
alpha_data <- farm_data %>%
  group_by(
    sample_name,
    farm_id,
    corral_type,
    class_group
  ) %>%
  summarise(
    abundance = sum(abundance, na.rm = TRUE),
    .groups = "drop"
  )

# Create sample by resistance class group matrix
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

# Check zero abundance samples
rowSums(alpha_matrix_values) == 0

# Calculate Hill number q0 (observed richness)
observed_richness <- specnumber(
  alpha_matrix_values
)

# Calculate Shannon index for Hill number q1
shannon_index <- diversity(
  alpha_matrix_values,
  index = "shannon"
)

# Calculate Hill number q2 (inverse Simpson)
inverse_simpson <- diversity(
  alpha_matrix_values,
  index = "invsimpson"
)

# Create Hill number results table
alpha_results <- data.frame(
  sample_name = alpha_matrix$sample_name,
  hill_q0 = observed_richness,
  hill_q1 = exp(shannon_index),
  hill_q2 = inverse_simpson
)

# Add sample metadata
alpha_results <- alpha_results %>%
  left_join(
    sample_info,
    by = "sample_name"
  )

# Set corral type order
alpha_results <- alpha_results %>%
  mutate(
    corral_type = factor(
      corral_type,
      levels = c("H", "S")
    )
  )

# Save Hill number results
write.csv(
  alpha_results,
  file = file.path(
    data_dir,
    "hill_number_results.csv"
  ),
  row.names = FALSE
)

# Check output file
file.exists(
  file.path(
    data_dir,
    "hill_number_results.csv"
  )
)

# Check Hill number results
head(alpha_results)

# Check corral type counts
table(alpha_results$corral_type)

# Check missing values
colSums(is.na(alpha_results))

# Check Hill number summary
summary(alpha_results)

# Convert Hill number results to long format
hill_long <- alpha_results %>%
  select(
    sample_name,
    farm_id,
    corral_type,
    hill_q0,
    hill_q1,
    hill_q2
  ) %>%
  pivot_longer(
    cols = starts_with("hill_q"),
    names_to = "hill_order",
    values_to = "hill_number"
  ) %>%
  mutate(
    hill_order = factor(
      hill_order,
      levels = c("hill_q0", "hill_q1", "hill_q2"),
      labels = c(
        "Hill number q = 0",
        "Hill number q = 1",
        "Hill number q = 2"
      )
    )
  )

# Check Hill number table
head(hill_long)
dim(hill_long)

# Plot Hill number q0 by corral type
hill_q0_plot <- ggplot(
  alpha_results,
  aes(
    x = corral_type,
    y = hill_q0,
    fill = corral_type
  )
) +
  geom_boxplot(
    width = 0.4,
    alpha = 0.7
  ) +
  geom_jitter(
    width = 0.1,
    size = 1.5,
    alpha = 0.6
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
    y = "Hill number q = 0"
  ) +
  theme(
    axis.text = element_text(size = 9),
    axis.title = element_text(size = 10),
    legend.position = "none"
  )

# Display plot
hill_q0_plot

# Plot Hill number q1 by corral type
hill_q1_plot <- ggplot(
  alpha_results,
  aes(
    x = corral_type,
    y = hill_q1,
    fill = corral_type
  )
) +
  geom_boxplot(
    width = 0.4,
    alpha = 0.7
  ) +
  geom_jitter(
    width = 0.1,
    size = 1.5,
    alpha = 0.6
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
    y = "Hill number q = 1"
  ) +
  theme(
    axis.text = element_text(size = 9),
    axis.title = element_text(size = 10),
    legend.position = "none"
  )

# Display plot
hill_q1_plot

# Plot Hill number q2 by corral type
hill_q2_plot <- ggplot(
  alpha_results,
  aes(
    x = corral_type,
    y = hill_q2,
    fill = corral_type
  )
) +
  geom_boxplot(
    width = 0.4,
    alpha = 0.7
  ) +
  geom_jitter(
    width = 0.1,
    size = 1.5,
    alpha = 0.6
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
    y = "Hill number q = 2"
  ) +
  theme(
    axis.text = element_text(size = 9),
    axis.title = element_text(size = 10),
    legend.position = "none"
  )

# Display plot
hill_q2_plot

# Save Hill number q0 plot PDF
ggsave(
  filename = file.path(
    figures_dir,
    "hill_number_q0_plot.pdf"
  ),
  plot = hill_q0_plot,
  width = 5,
  height = 5
)

# Save Hill number q0 plot PNG
ggsave(
  filename = file.path(
    figures_dir,
    "hill_number_q0_plot.png"
  ),
  plot = hill_q0_plot,
  width = 5,
  height = 5,
  dpi = 300
)

# Save Hill number q1 plot PDF
ggsave(
  filename = file.path(
    figures_dir,
    "hill_number_q1_plot.pdf"
  ),
  plot = hill_q1_plot,
  width = 5,
  height = 5
)

# Save Hill number q1 plot PNG
ggsave(
  filename = file.path(
    figures_dir,
    "hill_number_q1_plot.png"
  ),
  plot = hill_q1_plot,
  width = 5,
  height = 5,
  dpi = 300
)

# Save Hill number q2 plot PDF
ggsave(
  filename = file.path(
    figures_dir,
    "hill_number_q2_plot.pdf"
  ),
  plot = hill_q2_plot,
  width = 5,
  height = 5
)

# Save Hill number q2 plot PNG
ggsave(
  filename = file.path(
    figures_dir,
    "hill_number_q2_plot.png"
  ),
  plot = hill_q2_plot,
  width = 5,
  height = 5,
  dpi = 300
)

# Check output files
file.exists(
  file.path(
    figures_dir,
    "hill_number_q0_plot.pdf"
  )
)

file.exists(
  file.path(
    figures_dir,
    "hill_number_q0_plot.png"
  )
)

file.exists(
  file.path(
    figures_dir,
    "hill_number_q1_plot.pdf"
  )
)

file.exists(
  file.path(
    figures_dir,
    "hill_number_q1_plot.png"
  )
)

file.exists(
  file.path(
    figures_dir,
    "hill_number_q2_plot.pdf"
  )
)

file.exists(
  file.path(
    figures_dir,
    "hill_number_q2_plot.png"
  )
)

# Compare Hill number q0
wilcox.test(
  hill_q0 ~ corral_type,
  data = alpha_results,
  exact = FALSE
)

# Compare Hill number q1
wilcox.test(
  hill_q1 ~ corral_type,
  data = alpha_results,
  exact = FALSE
)

# Compare Hill number q2
wilcox.test(
  hill_q2 ~ corral_type,
  data = alpha_results,
  exact = FALSE
)

# Create Hill number test results table
hill_stats <- data.frame(
  metric = c(
    "Hill q0",
    "Hill q1",
    "Hill q2"
  ),
  p_value = c(
    0.1704,
    0.0460,
    0.0246
  )
)

# Apply Benjamini-Hochberg correction
hill_stats$p_adjusted <- p.adjust(
  hill_stats$p_value,
  method = "BH"
)

# Check results
hill_stats

write.csv(
  hill_stats,
  file = file.path(
    data_dir,
    "hill_number_statistics.csv"
  ),
  row.names = FALSE
)

