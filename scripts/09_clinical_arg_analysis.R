# 09_clinical_arg_analysis.R
# Purpose: Describe clinically relevant low-abundance ARGs across farm samples
# Input: data/resistance_split_processed.csv from 01_merge_data.R
# Output: Clinical ARG summary files, detection plot and sample-level heatmap

# This analysis focuses on selected rifampin-associated resistance genes
# and carbapenem-associated metallo-beta-lactamase families.
# Results requiring SNP confirmation are excluded.

# Load packages
library(tidyverse)

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
  filter(
    sample_type == "farm_sample"
  ) %>%
  mutate(
    corral_type = ifelse(
      corral_type == "S1",
      "S",
      corral_type
    ),
    corral_type = factor(
      corral_type,
      levels = c("H", "S")
    )
  )

# Prepare sample metadata
metadata <- farm_data %>%
  distinct(
    sample_name,
    farm_id,
    corral_type
  )

# Check sample counts
table(metadata$corral_type)

# Define clinically relevant ARG families
clinical_reference <- data.frame(
  arg_family = c(
    "RPH",
    "ARR",
    "IMP",
    "SPM",
    "KHM"
  ),
  clinical_group = c(
    "Rifampin-associated resistance",
    "Rifampin-associated resistance",
    "Carbapenem-associated metallo-beta-lactamase",
    "Carbapenem-associated metallo-beta-lactamase",
    "Carbapenem-associated metallo-beta-lactamase"
  )
)

# Check selected ARG families
clinical_reference

# Extract ARG family names from the MEGARes description
clinical_data <- farm_data %>%
  mutate(
    arg_family = str_split_fixed(
      description,
      "\\|",
      3
    )[ , 2]
  ) %>%
  filter(
    !str_detect(
      description,
      "RequiresSNPConfirmation"
    )
  ) %>%
  inner_join(
    clinical_reference,
    by = "arg_family"
  )

# Check clinically relevant ARG records
head(clinical_data)
table(clinical_data$arg_family)

# Calculate total AMR abundance within each sample
sample_totals <- farm_data %>%
  group_by(sample_name) %>%
  summarise(
    total_amr_abundance = sum(
      abundance,
      na.rm = TRUE
    ),
    .groups = "drop"
  )

# Summarise each clinical ARG family within each sample
clinical_sample_data <- clinical_data %>%
  group_by(
    sample_name,
    farm_id,
    corral_type,
    clinical_group,
    arg_family
  ) %>%
  summarise(
    abundance = sum(
      abundance,
      na.rm = TRUE
    ),
    .groups = "drop"
  ) %>%
  left_join(
    sample_totals,
    by = "sample_name"
  ) %>%
  mutate(
    relative_abundance =
      abundance /
      total_amr_abundance *
      100
  )

# Check sample-level clinical ARG data
head(clinical_sample_data)
dim(clinical_sample_data)

# Save sample-level clinical ARG data
write.csv(
  clinical_sample_data,
  file = file.path(
    data_dir,
    "clinical_arg_sample_data.csv"
  ),
  row.names = FALSE
)

# Store total numbers of healthy and sick samples
n_H_samples <- metadata %>%
  filter(
    corral_type == "H"
  ) %>%
  nrow()

n_S_samples <- metadata %>%
  filter(
    corral_type == "S"
  ) %>%
  nrow()
# Create clinical ARG summary
clinical_summary <- clinical_sample_data %>%
  group_by(
    clinical_group,
    arg_family
  ) %>%
  summarise(
    n_samples_detected = n_distinct(
      sample_name
    ),
    n_H_detected = n_distinct(
      sample_name[
        corral_type == "H"
      ]
    ),
    n_S_detected = n_distinct(
      sample_name[
        corral_type == "S"
      ]
    ),
    n_farms_detected = n_distinct(
      farm_id
    ),
    total_abundance = sum(
      abundance,
      na.rm = TRUE
    ),
    median_relative_abundance = median(
      relative_abundance,
      na.rm = TRUE
    ),
    maximum_relative_abundance = max(
      relative_abundance,
      na.rm = TRUE
    ),
    .groups = "drop"
  ) %>%
  mutate(
    H_detection_percent =
      n_H_detected /
      n_H_samples *
      100,
    S_detection_percent =
      n_S_detected /
      n_S_samples *
      100
  )

# View clinical ARG summary
clinical_summary

# Save clinical ARG summary
write.csv(
  clinical_summary,
  file = file.path(
    data_dir,
    "clinical_arg_summary.csv"
  ),
  row.names = FALSE
)

# Create complete sample by ARG family data
clinical_heatmap_data <- metadata %>%
  crossing(
    clinical_reference
  ) %>%
  left_join(
    clinical_sample_data,
    by = c(
      "sample_name",
      "farm_id",
      "corral_type",
      "clinical_group",
      "arg_family"
    )
  ) %>%
  mutate(
    abundance = replace_na(
      abundance,
      0
    ),
    relative_abundance = replace_na(
      relative_abundance,
      0
    )
  )

# Set sample order by corral type and farm
sample_order <- metadata %>%
  arrange(
    corral_type,
    farm_id,
    sample_name
  ) %>%
  pull(sample_name)

# Set ARG family order
arg_order <- c(
  "RPH",
  "ARR",
  "IMP",
  "SPM",
  "KHM"
)

clinical_heatmap_data <- clinical_heatmap_data %>%
  mutate(
    sample_name = factor(
      sample_name,
      levels = sample_order
    ),
    arg_family = factor(
      arg_family,
      levels = rev(arg_order)
    )
  )

# Calculate detection percentages by corral type
clinical_detection <- clinical_heatmap_data %>%
  group_by(
    clinical_group,
    arg_family,
    corral_type
  ) %>%
  summarise(
    n_samples_detected = sum(
      abundance > 0
    ),
    n_samples = n_distinct(
      sample_name
    ),
    detection_percent =
      n_samples_detected /
      n_samples *
      100,
    .groups = "drop"
  )

# Check detection percentages
clinical_detection

# Save detection results
write.csv(
  clinical_detection,
  file = file.path(
    data_dir,
    "clinical_arg_detection.csv"
  ),
  row.names = FALSE
)

# Plot clinical ARG detection percentages
clinical_detection_plot <- ggplot(
  clinical_detection,
  aes(
    x = arg_family,
    y = detection_percent,
    fill = corral_type
  )
) +
  geom_col(
    position = position_dodge(
      width = 0.7
    ),
    width = 0.6
  ) +
  scale_fill_manual(
    values = c(
      "H" = "#00A896",
      "S" = "#E76F51"
    )
  ) +
  theme_bw() +
  labs(
    x = "Clinically relevant ARG family",
    y = "Samples detected (%)",
    fill = "Corral type"
  ) +
  theme(
    axis.text = element_text(size = 9),
    axis.title = element_text(size = 10),
    legend.title = element_text(size = 10),
    legend.text = element_text(size = 9)
  )

# Display detection plot
clinical_detection_plot

# Save detection plot as PNG
ggsave(
  filename = file.path(
    figures_dir,
    "clinical_arg_detection_plot.png"
  ),
  plot = clinical_detection_plot,
  width = 7,
  height = 5,
  dpi = 300
)

# Save detection plot as PDF
ggsave(
  filename = file.path(
    figures_dir,
    "clinical_arg_detection_plot.pdf"
  ),
  plot = clinical_detection_plot,
  width = 7,
  height = 5
)

# Plot clinical ARG relative abundance heatmap
clinical_heatmap <- ggplot(
  clinical_heatmap_data,
  aes(
    x = sample_name,
    y = arg_family,
    fill = relative_abundance
  )
) +
  geom_tile(
    colour = "white"
  ) +
  facet_grid(
    . ~ corral_type,
    scales = "free_x",
    space = "free_x"
  ) +
  scale_fill_gradient(
    low = "white",
    high = "#E76F51",
    trans = "sqrt"
  ) +
  theme_bw() +
  labs(
    x = "Sample ID",
    y = "Clinically relevant ARG family",
    fill = "Relative\nabundance (%)"
  ) +
  theme(
    axis.text.x = element_text(
      angle = 90,
      hjust = 1,
      vjust = 0.5,
      size = 7
    ),
    axis.text.y = element_text(size = 9),
    axis.title = element_text(size = 10),
    legend.title = element_text(size = 9),
    legend.text = element_text(size = 8),
    strip.text = element_text(size = 10)
  )

# Display heatmap
clinical_heatmap

# Save heatmap as PNG
ggsave(
  filename = file.path(
    figures_dir,
    "clinical_arg_heatmap.png"
  ),
  plot = clinical_heatmap,
  width = 10,
  height = 5,
  dpi = 300
)

# Save heatmap as PDF
ggsave(
  filename = file.path(
    figures_dir,
    "clinical_arg_heatmap.pdf"
  ),
  plot = clinical_heatmap,
  width = 10,
  height = 5
)

# Check output files
file.exists(
  file.path(
    data_dir,
    "clinical_arg_summary.csv"
  )
)

file.exists(
  file.path(
    figures_dir,
    "clinical_arg_detection_plot.png"
  )
)

file.exists(
  file.path(
    figures_dir,
    "clinical_arg_heatmap.png"
  )
)

