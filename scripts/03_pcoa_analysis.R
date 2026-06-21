# 03_pcoa_analysis.R
# Purpose: Explore resistome composition differences among farm samples using PCoA
# Input: data/resistance_split_processed.csv from 01_merge_data.R
# Output: PCoA plot of resistome composition across farm samples

# This analysis follows a microbiome ecology framework.
# Bray-Curtis dissimilarity is calculated from grouped resistance class abundances.
# PCoA is used to visualise differences in resistome composition among farm samples.

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

# Summarise abundance by sample and resistance class group
class_summary <- farm_data %>%
  group_by(
    sample_name,
    farm_id,
    corral_id,
    corral_type,
    class_group
  ) %>%
  summarise(
    abundance = sum(abundance, na.rm = TRUE),
    .groups = "drop"
  )

# Calculate relative abundance within each sample
pcoa_data <- class_summary %>%
  group_by(sample_name) %>%
  mutate(
    relative_abundance = abundance / sum(abundance)
  ) %>%
  ungroup()

# Check relative abundance sums to 1 for each sample
pcoa_data %>%
  group_by(sample_name) %>%
  summarise(total = sum(relative_abundance))

# Create sample by resistance class matrix
pcoa_matrix <- pcoa_data %>%
  select(
    sample_name,
    class_group,
    relative_abundance
  ) %>%
  pivot_wider(
    names_from = class_group,
    values_from = relative_abundance,
    values_fill = 0
  )

# Check matrix dimensions
dim(pcoa_matrix)

# View first few rows
head(pcoa_matrix)

# Store sample names
sample_names <- pcoa_matrix$sample_name

# Convert relative abundance table to matrix
pcoa_matrix_values <- pcoa_matrix %>%
  select(-sample_name) %>%
  as.matrix()

# Calculate Bray-Curtis dissimilarity
bray_dist <- vegdist(
  pcoa_matrix_values,
  method = "bray"
)

# Run PCoA
pcoa_result <- cmdscale(
  bray_dist,
  k = 2,
  eig = TRUE
)

# Calculate percentage variation explained by each PCoA axis
pcoa_var <- pcoa_result$eig /
  sum(pcoa_result$eig[pcoa_result$eig > 0]) * 100

# Create PCoA result table
pcoa_df <- data.frame(
  sample_name = sample_names,
  PCoA1 = pcoa_result$points[, 1],
  PCoA2 = pcoa_result$points[, 2]
)

# Check PCoA result
head(pcoa_df)

# Prepare metadata for plotting
metadata <- farm_data %>%
  distinct(
    sample_name,
    farm_id,
    corral_id,
    corral_type
  )

# Add metadata to PCoA results
pcoa_df <- pcoa_df %>%
  left_join(metadata, by = "sample_name")

# Combine S1 and S into a single corral type category
pcoa_df <- pcoa_df %>%
  mutate(
    corral_type = ifelse(corral_type == "S1", "S", corral_type)
  )

# Check PCoA table with metadata
head(pcoa_df)

# Plot PCoA results
# Coloured = corral type
p1 <- ggplot(
  pcoa_df,
  aes(
    x = PCoA1,
    y = PCoA2,
    colour = corral_type
  )
) +
  geom_point(size = 3.5) +
  scale_colour_manual(
    values = c(
      "H" = "#E76F51",
      "S" = "#00A896"
    )
  ) +
  theme_bw() +
  labs(
    x = paste0("PCoA1 (", round(pcoa_var[1], 1), "%)"),
    y = paste0("PCoA2 (", round(pcoa_var[2], 1), "%)"),
    colour = "Corral type"
  ) +
  theme(
    axis.text = element_text(size = 9),
    axis.title = element_text(size = 10),
    legend.title = element_text(size = 10),
    legend.text = element_text(size = 9),
    legend.position = "bottom"
  )

# Display plot
p1

# Save PDF
ggsave(
  filename = file.path(
    figures_dir,
    "pcoa_plot.pdf"
  ),
  plot = p1,
  width = 9,
  height = 6
)

# Save PNG
ggsave(
  filename = file.path(
    figures_dir,
    "pcoa_plot.png"
    ),
  plot = p1,
  width = 9,
  height = 6,
  dpi = 300
)

# Check output files
file.exists(
  file.path(
    figures_dir,
    "pcoa_plot.pdf"
  )
)

file.exists(
  file.path(
    figures_dir,
    "pcoa_plot.png"
  )
)

# Check corral type counts
table(pcoa_df$corral_type)

# Test resistome composition differences between corral types
permanova_result <- adonis2(
  bray_dist ~ corral_type,
  data = pcoa_df,
  permutations = 999
)

# View PERMANOVA result
permanova_result

# Save PERMANOVA result
permanova_table <- as.data.frame(permanova_result)
permanova_table$term <- row.names(permanova_table)

write.csv(
  permanova_table,
  file = file.path(
    data_dir,
    "permanova_results.csv"
  ),
  row.names = FALSE
)

# Test homogeneity of dispersion between corral types
dispersion <- betadisper(
  bray_dist,
  pcoa_df$corral_type
)

# View PERMDISP result
permdisp_result <- anova(dispersion)
permdisp_result

# Save PERMDISP result
permdisp_table <- as.data.frame(permdisp_result)
permdisp_table$term <- row.names(permdisp_table)

write.csv(
  permdisp_table,
  file = file.path(
    data_dir,
    "permdisp_results.csv"
  ),
  row.names = FALSE
)