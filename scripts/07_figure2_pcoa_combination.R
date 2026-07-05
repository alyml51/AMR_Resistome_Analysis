# 07_figure2_pcoa_combination.R
# Purpose: Combine Bray-Curtis and CLR/Aitchison PCoA plots into a single Figure 2 for the dissertation.
# Input: Bray-Curtis PCoA from 03_pcoa_analysis.R and CLR/Aitchison PCoA from 06_clr_pcoa_analysis.R
# Output: Combined Figure 2 in PDE and PNG formats

# Load packages
library(ggplot2)
library(patchwork)

# Set working directory
project_dir <- "E:/A-4137/AMR_Resistome_Analysis"

# Define project folders
figures_dir <- file.path(project_dir, "figures")
scripts_dir <- file.path(project_dir, "scripts")

# Run Bray-Curtis PCoA analysis
source(
  file.path(
    scripts_dir,
    "03_pcoa_analysis.R"
  )
)

# Run CLR/Aitchison PCoA analysis
source(
  file.path(
    scripts_dir,
    "06_clr_pcoa_analysis.R"
  )
)

# Add panel labels
p1_labelled <- p1 +
  labs(
    title = "A"
  ) +
  theme(
    plot.title = element_text(
      size = 14,
      face = "bold",
      hjust = 0
    )
  )

clr_pcoa_plot_labelled <- clr_pcoa_plot +
  labs(
    title = "B"
  ) +
  theme(
    plot.title = element_text(
      size = 14,
      face = "bold",
      hjust = 0
    )
  )

# Combine PCoA plots
figure2_pcoa <- p1_labelled + clr_pcoa_plot_labelled +
  plot_layout(
    guides = "collect",
    widths = c(1, 1)
  ) &
  theme(
    legend.position = "right"
  )

# Display combined figure
figure2_pcoa

# Save Figure 2 as PDF
ggsave(
  filename = file.path(
    figures_dir,
    "figure2_pcoa_combined.pdf"
  ),
  plot = figure2_pcoa,
  width = 14,
  height = 6
)

# Save Figure 2 as PNG
ggsave(
  filename = file.path(
    figures_dir,
    "figure2_pcoa_combined.png"
  ),
  plot = figure2_pcoa,
  width = 14,
  height = 6,
  dpi = 300
)

# Check output files
file.exists(
  file.path(
    figures_dir,
    "figure2_pcoa_combined.pdf"
  )
)

file.exists(
  file.path(
    figures_dir,
    "figure2_pcoa_combined.png"
  )
)