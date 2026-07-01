# 06_clr_pcoa_analysis.R
# Purpose: Explore resistome composition using CLR transformation and Aitchison distance
# Input: data/resistance_split_processed.csv from 01_merge_data.R
# Output: CLR-based PCoA plot of resistome composition across farm samples

# This analysis follows compositional data analysis principles.
# Zero counts are replaced using multiplicative replacement.
# CLR transformation is then applied before calculating Euclidean distance.
# Euclidean distance after CLR transformation is equivalent to Aitchison distance.

# Load packages
library(tidyverse)
library(vegan)
library(zCompositions)
library(compositions)

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
clr_data <- farm_data %>%
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

# Convert long-format abundance data to a sample-by-class matrix
clr_matrix <- clr_data %>%
  pivot_wider(
    names_from = class_group,
    values_from = abundance,
    values_fill = 0
  )

# Replace zeros using multiplicative replacement
clr_matrix_replace <- clr_matrix

clr_matrix_replace[ , 5:ncol(clr_matrix_replace)] <-
  cmultRepl(
    clr_matrix_replace[ , 5:ncol(clr_matrix_replace)],
    method = "CZM"
  )

# Store sample metadata
clr_metadata <- clr_matrix %>%
  dplyr::select(
    sample_name,
    farm_id,
    corral_type
  )

# Convert abundance table to matrix
clr_abundance <- clr_matrix %>%
  dplyr::select(
    -sample_name,
    -farm_id,
    -corral_type
  ) %>%
  as.matrix()

# Check matrix dimensions
dim(clr_abundance)

# Check zero values before replacement
sum(clr_abundance == 0)

# Check sample total abundance before replacement
summary(rowSums(clr_abundance))

# Replace zeros using multiplicative replacement
clr_abundance_replace <- cmultRepl(
  clr_abundance,
  method = "CZM"
)

# Check zero values after replacement
sum(clr_abundance_replace == 0)

# Check sample total abundance after replacement
summary(rowSums(clr_abundance_replace))

# Apply centred log-ratio (CLR) transformation
clr_transformed <- clr(clr_abundance_replace)

# Check CLR matrix dimensions
dim(clr_transformed)

# Check for missing values
sum(is.na(clr_transformed))

# Check transformed value range
summary(clr_transformed)

# Calculate Euclidean distance on CLR-transformed data
clr_distance <- dist(
  clr_transformed,
  method = "euclidean"
)

# Check distance matrix
clr_distance

# Convert distance object to matrix for inspection
clr_distance_matrix <- as.matrix(clr_distance)

# Check matrix dimensions
dim(clr_distance_matrix)

# Perform Principal Coordinates Analysis (PCoA)
clr_pcoa <- cmdscale(
  clr_distance,
  eig = TRUE,
  k = 2
)

# Check PCoA coordinates
head(clr_pcoa$points)

# Check eigenvalues
head(clr_pcoa$eig)

# Calculate percentage of variance explained using positive eigenvalues
positive_eig <- clr_pcoa$eig[clr_pcoa$eig > 0]
variance_explained <- clr_pcoa$eig / sum(positive_eig) * 100

# Check variance explained
variance_explained[1:5]

# Store axis labels for plotting
axis1 <- paste0(
  "PCoA1 (",
  round(variance_explained[1], 1),
  "%)"
)

axis2 <- paste0(
  "PCoA2 (",
  round(variance_explained[2], 1),
  "%)"
)

# Check axis labels
axis1
axis2

# Convert PCoA coordinates to a data frame
clr_pcoa_df <- data.frame(
  sample_name = clr_metadata$sample_name,
  farm_id = clr_metadata$farm_id,
  corral_type = clr_metadata$corral_type,
  PCoA1 = clr_pcoa$points[, 1],
  PCoA2 = clr_pcoa$points[, 2]
)

# Check PCoA data frame
head(clr_pcoa_df)

# Check data frame dimensions
dim(clr_pcoa_df)

# Plot CLR-based PCoA results
clr_pcoa_plot <- ggplot(
  clr_pcoa_df,
  aes(
    x = PCoA1,
    y = PCoA2,
    colour = corral_type
  )
) +
  geom_point(
    size = 3.5
  ) +
  scale_colour_manual(
    values = c(
      "H" = "#00A896",
      "S" = "#E76F51"
    )
  ) +
  theme_bw() +
  labs(
    x = axis1,
    y = axis2,
    colour = "Corral type"
  ) +
  theme(
    axis.text = element_text(size = 9),
    axis.title = element_text(size = 10),
    legend.title = element_text(size = 10),
    legend.text = element_text(size = 9),
  )

# Display plot
clr_pcoa_plot

# Save CLR-based PCoA plot as PNG
ggsave(
  filename = file.path(
    figures_dir,
    "clr_aitchison_pcoa_plot.png"
  ),
  plot = clr_pcoa_plot,
  width = 7,
  height = 6,
  dpi = 300
)

# Save CLR-based PCoA plot as PDF
ggsave(
  filename = file.path(
    figures_dir,
    "clr_aitchison_pcoa_plot.pdf"
  ),
  plot = clr_pcoa_plot,
  width = 7,
  height = 6
)

# Check output figures
file.exists(
  file.path(
    figures_dir,
    "clr_aitchison_pcoa_plot.png"
  )
)

file.exists(
  file.path(
    figures_dir,
    "clr_aitchison_pcoa_plot.pdf"
  )
)

# Test resistome composition differences between corral types
clr_permanova <- adonis2(
  clr_distance ~ corral_type,
  data = clr_pcoa_df,
  permutations = 999
)

# View PERMANOVA result
clr_permanova

# Save PERMANOVA result
clr_permanova_table <- as.data.frame(clr_permanova)
clr_permanova_table$term <- row.names(clr_permanova_table)

write.csv(
  clr_permanova_table,
  file = file.path(
    data_dir,
    "clr_permanova_results.csv"
  ),
  row.names = FALSE
)

# Check output file
file.exists(
  file.path(
    data_dir,
    "clr_permanova_results.csv"
  )
)

# Test homogeneity of dispersion between corral types
clr_dispersion <- betadisper(
  clr_distance,
  clr_pcoa_df$corral_type
)

# View PERMDISP result
clr_permdisp <- anova(clr_dispersion)
clr_permdisp

# Save PERMDISP result
clr_permdisp_table <- as.data.frame(clr_permdisp)
clr_permdisp_table$term <- row.names(clr_permdisp_table)

write.csv(
  clr_permdisp_table,
  file = file.path(
    data_dir,
    "clr_permdisp_results.csv"
  ),
  row.names = FALSE
)

# Check output file
file.exists(
  file.path(
    data_dir,
    "clr_permdisp_results.csv"
  )
)