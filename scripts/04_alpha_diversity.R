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
  dplyr::select(
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
  dplyr::select(-sample_name) %>%
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

# Set farm and corral type as factors
alpha_results <- alpha_results %>%
  mutate(
    farm_id = factor(farm_id),
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
  dplyr::select(
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
      "H" = "#00A896",
      "S" = "#E76F51"
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
      "H" = "#00A896",
      "S" = "#E76F51"
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
      "H" = "#00A896",
      "S" = "#E76F51"
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

# Compare Hill numbers using all samples
hill_q0_test <- wilcox.test(
  hill_q0 ~ corral_type,
  data = alpha_results,
  exact = FALSE
)

hill_q1_test <- wilcox.test(
  hill_q1 ~ corral_type,
  data = alpha_results,
  exact = FALSE
)

hill_q2_test <- wilcox.test(
  hill_q2 ~ corral_type,
  data = alpha_results,
  exact = FALSE
)

# Create results table for all samples
all_sample_stats <- data.frame(
  analysis = "All samples",
  metric = c(
    "Hill q0",
    "Hill q1",
    "Hill q2"
  ),
  p_value = c(
    hill_q0_test$p.value,
    hill_q1_test$p.value,
    hill_q2_test$p.value
  )
)

# Identify farms containing both healthy and sick samples
paired_farms <- alpha_results %>%
  distinct(
    farm_id,
    corral_type
  ) %>%
  count(farm_id) %>%
  filter(n == 2) %>%
  pull(farm_id)

# Check paired farms
paired_farms
length(paired_farms)

# Prepare paired Hill number data
paired_alpha <- alpha_results %>%
  filter(farm_id %in% paired_farms) %>%
  dplyr::select(
    farm_id,
    corral_type,
    hill_q0,
    hill_q1,
    hill_q2
  ) %>%
  pivot_wider(
    names_from = corral_type,
    values_from = c(
      hill_q0,
      hill_q1,
      hill_q2
    )
  )

# Confirm that seven paired farms are included
stopifnot(nrow(paired_alpha) == 7)

# Compare Hill numbers within paired farms
paired_q0_test <- wilcox.test(
  paired_alpha$hill_q0_H,
  paired_alpha$hill_q0_S,
  paired = TRUE,
  exact = FALSE
)

paired_q1_test <- wilcox.test(
  paired_alpha$hill_q1_H,
  paired_alpha$hill_q1_S,
  paired = TRUE,
  exact = FALSE
)

paired_q2_test <- wilcox.test(
  paired_alpha$hill_q2_H,
  paired_alpha$hill_q2_S,
  paired = TRUE,
  exact = FALSE
)

# Create results table for paired farms
paired_farm_stats <- data.frame(
  analysis = "Paired farms",
  metric = c(
    "Hill q0",
    "Hill q1",
    "Hill q2"
  ),
  p_value = c(
    paired_q0_test$p.value,
    paired_q1_test$p.value,
    paired_q2_test$p.value
  )
)

# Combine statistical results
hill_stats <- bind_rows(
  all_sample_stats,
  paired_farm_stats
) %>%
  group_by(analysis) %>%
  mutate(
    p_adjusted = p.adjust(
      p_value,
      method = "BH"
    )
  ) %>%
  ungroup()

# View statistical results
hill_stats

# Save Hill number statistics
write.csv(
  hill_stats,
  file = file.path(
    data_dir,
    "hill_number_statistics.csv"
  ),
  row.names = FALSE
)

# Save paired farm data
write.csv(
  paired_alpha,
  file = file.path(
    data_dir,
    "hill_number_paired_farms.csv"
  ),
  row.names = FALSE
)

# Check output files
file.exists(
  file.path(
    data_dir,
    "hill_number_statistics.csv"
  )
)

file.exists(
  file.path(
    data_dir,
    "hill_number_paired_farms.csv"
  )
)