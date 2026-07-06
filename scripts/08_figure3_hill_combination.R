# 08_figure3_hill_combination.R
# Purpose: Combine Hill number plots into a single figure for dissertation Figure 3.
# Input: Hill number plots from 04_alpha_diversity.R
# Output: Combined Figure 3 in PDF and PNG formats

# Load packages
library(ggplot2)
library(patchwork)

# Set working directory
project_dir <- "E:/A-4137/AMR_Resistome_Analysis"

# Define project folders
figures_dir <- file.path(project_dir, "figures")
scripts_dir <- file.path(project_dir, "scripts")

# Run Hill number analysis
source(
  file.path(
    scripts_dir,
    "04_alpha_diversity.R"
  )
)

# Load Hill number plots
source(
  file.path(
    scripts_dir,
    "04_alpha_diversity.R"
  )
)

# Remove repeated x-axis titles
hill_q0_plot_clean <- hill_q0_plot +
  labs(x = NULL)

hill_q1_plot_clean <- hill_q1_plot +
  labs(x = NULL)

hill_q2_plot_clean <- hill_q2_plot +
  labs(x = NULL)

# Combine Hill number plots into Figure 3
figure3_hill <-
  hill_q0_plot_clean +
  hill_q1_plot_clean +
  hill_q2_plot_clean +
  plot_layout(
    ncol = 3
  ) +
  plot_annotation(
    tag_levels = "A"
  )

# Display Figure 3
figure3_hill

# Save Figure 3 as PDF
ggsave(
  filename = file.path(
    figures_dir,
    "figure3_hill_combined.pdf"
  ),
  plot = figure3_hill,
  width = 15,
  height = 5
)

# Save Figure 3 as PNG
ggsave(
  filename = file.path(
    figures_dir,
    "figure3_hill_combined.png"
  ),
  plot = figure3_hill,
  width = 15,
  height = 5,
  dpi = 300
)

# Check output figures
file.exists(
  file.path(
    figures_dir,
    "figure3_hill_combined.pdf"
  )
)

file.exists(
  file.path(
    figures_dir,
    "figure3_hill_combined.png"
  )
)