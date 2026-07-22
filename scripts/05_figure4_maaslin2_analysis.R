# 05_maaslin2_analysis.R
# Purpose: Test resistance class groups associated with corral type
# Input: data/resistance_split_processed.csv from 01_merge_data.R
# Output: MaAsLin2 results and coefficient plot

# MaAsLin2 is used to test which resistance class groups differ between healthy and sick corrals.

# Load packages
library(tidyverse)
library(Maaslin2)

# Set working directory
project_dir <- "E:/A-4137/AMR_Resistome_Analysis"

# Define project folders
data_dir <- file.path(project_dir, "data")
figures_dir <- file.path(project_dir, "figures")
results_dir <- file.path(project_dir, "results")

# Create MaAsLin2 output folder
maaslin_dir <- file.path(
  results_dir,
  "maaslin2_resistance_classes"
)

dir.create(
  maaslin_dir,
  recursive = TRUE,
  showWarnings = FALSE
)

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
class_data <- farm_data %>%
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
maaslin_input <- class_data %>%
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

# Store sample names as row names
maaslin_input <- maaslin_input %>%
  column_to_rownames("sample_name")

# Prepare metadata for MaAsLin2
maaslin_metadata <- class_data %>%
  distinct(
    sample_name,
    farm_id,
    corral_type
  ) %>%
  mutate(
    corral_type = factor(
      corral_type,
      levels = c("H", "S")
    )
  ) %>%
  column_to_rownames("sample_name")

# Check input matrix
dim(maaslin_input)
head(maaslin_input)

# Check metadata
head(maaslin_metadata)
table(maaslin_metadata$corral_type)

# Run MaAsLin2 with farm ID as a random effect
maaslin_fit <- Maaslin2(
  input_data = maaslin_input,
  input_metadata = maaslin_metadata,
  output = maaslin_dir,
  fixed_effects = c("corral_type"),
  random_effects = c("farm_id"),
  reference = c("corral_type,H"),
  normalization = "TSS",
  transform = "LOG",
  analysis_method = "LM",
  correction = "BH",
  standardize = FALSE
)

# Load MaAsLin2 results
maaslin_results <- read.delim(
  file.path(
    maaslin_dir,
    "all_results.tsv"
  )
)

# Check MaAsLin2 results
head(maaslin_results)

# Keep corral type results only
corral_results <- maaslin_results %>%
  filter(metadata == "corral_type")

# Check corral type results
head(corral_results)

# Format resistance class names for plotting
corral_results <- corral_results %>%
  mutate(
    feature = recode(
      feature,
      "Metal.resistance" = "Metal resistance",
      "Biocide.resistance" = "Biocide resistance",
      "Multi.drug.resistance" = "Multi-drug resistance",
      "Beta.lactams" = "Beta-lactams",
      "Sulfonamides.Trimethoprim" = "Sulfonamides/Trimethoprim"
    )
  )

# Save corral type results
write.csv(
  corral_results,
  file = file.path(
    data_dir,
    "maaslin2_corral_type_results.csv"
  ),
  row.names = FALSE
)

# Check output file
file.exists(
  file.path(
    data_dir,
    "maaslin2_corral_type_results.csv"
  )
)

# Plot MaAsLin2 coefficients
maaslin_plot <- ggplot(
  corral_results,
  aes(
    x = reorder(feature, coef),
    y = coef,
    fill = coef > 0
  )
) +
  geom_col(width = 0.7) +
  coord_flip() +
  scale_fill_manual(
    values = c(
      "FALSE" ="#00A896",
      "TRUE" = "#E76F51"
    ),
    labels = c(
      "Higher in H",
      "Higher in S"
    )
  ) +
  theme_bw() +
  labs(
    x = "Resistance class group",
    y = "MaAsLin2 coefficient",
    fill = "Direction"
  ) +
  theme(
    axis.text = element_text(size = 9),
    axis.title = element_text(size = 10),
    legend.title = element_text(size = 10),
    legend.text = element_text(size = 9)
  )

# Display plot
maaslin_plot

# Save MaAsLin2 coefficient plot PDF
ggsave(
  filename = file.path(
    figures_dir,
    "figure4_maaslin2_coefficient_plot.pdf"
  ),
  plot = maaslin_plot,
  width = 7,
  height = 5
)

# Save MaAsLin2 coefficient plot PNG
ggsave(
  filename = file.path(
    figures_dir,
    "figure4_maaslin2_coefficient_plot.png"
  ),
  plot = maaslin_plot,
  width = 7,
  height = 5,
  dpi = 300
)

# Check output files
file.exists(
  file.path(
    figures_dir,
    "figure4_maaslin2_coefficient_plot.pdf"
  )
)

file.exists(
  file.path(
    figures_dir,
    "figure4_maaslin2_coefficient_plot.png"
  )
)