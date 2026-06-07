# 03_pcoa_analysis.R
# Purpose: Explore resistome composition differences among farm samples using PCoA
# Input: data/resistance_split_processed.csv from 01_merge_data.R
# Output: PCoA plots for downstream beta diversity analysis

# This analysis follows a microbiome ecology framework.
# Bray-Curtis dissimilarity is calculated using relative abundance values of grouped
# Resistance classes to assess differences in resistome composition among farm samples
# PCoA is then used to visualise overall variation in resistome composition

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