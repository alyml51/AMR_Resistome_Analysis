# 02_resistance_class_plots.R
# Purpose: Plot resistance class composition across farm samples
# Input: data/resistance_split_processed.csv from 01_merge_data.R
# Output: stacked bar plots of grouped resistance class composition

# The processed data already contains grouped resistance class information.
# created in 01_merge_data.R. This script uses those groups to visualise.
# relative abundance patterns across farm samples.

# Load packages
library(dplyr)
library(ggplot2)

# Set project directory
project_dir <- "E:/A-4137/AMR_Resistome_Analysis"

# Define project folders
data_dir <- file.path(project_dir, "data")
figures_dir <- file.path(project_dir, "figures")

# Load processed table from 01_merge_data.R
resistance_split <- read.csv(
  file.path(data_dir, "resistance_split_processed.csv")
)

# Check input colums
colnames(resistance_split)


# Check grouped resistance classes
sort(unique(resistance_split$class_group))
table(resistance_split$class_group)
sum(is.na(resistance_split$class_group))

# Summarise abundance by sample and resistance class group
class_summary <- resistance_split %>%
  group_by(
    sample_name,
    sample_type,
    farm_id,
    corral_id,
    corral_type,
    class_group
  ) %>%
  summarise(
    abundance = sum(abundance, na.rm = TRUE),
    .groups = "drop"
  )

# Check summary table
head(class_summary)
dim(class_summary)

# Calculate relative abundance within each sample
plot_data <- class_summary %>%
  group_by(sample_name) %>%
  mutate(
    relative_abundance = abundance / sum(abundance)
  ) %>%
  ungroup()

# Check relative abundance sums to 1 per sample
plot_data %>%
  group_by(sample_name) %>%
  summarise(total = sum(relative_abundance))

# Keep farm samples only for the main plot
plot_data_farm <- plot_data %>%
  filter(sample_type == "farm_sample")

# Order samples by farm for plotting
plot_data_farm$sample_name <- factor(
  plot_data_farm$sample_name,
  levels = plot_data_farm %>%
    arrange(farm_id, corral_type, sample_name) %>%
    distinct(sample_name) %>%
    pull(sample_name)
)

# Define colours for resistance class groups
class_colours <- c(
  "Aminoglycosides" = "#E76F51",
  "Beta-lactams" = "#F4A261",
  "Biocide resistance" = "#B8A100",
  "Fluoroquinolones" = "#7CB342",
  "Glycopeptides" = "#2A9D8F",
  "Metal resistance" = "#006D77",
  "MLS" = "#118AB2",
  "Multi-drug resistance" = "#4CC9F0",
  "Other" = "grey70",
  "Phenicol" = "#8E7DBE",
  "Rifampin" = "#B565D9",
  "Sulfonamides/Trimethoprim" = "#D95F8D",
  "Tetracyclines" = "#F72585"
)

# Create stacked bar plot of resistance class composition
p1 <- ggplot(
  plot_data_farm,
  aes(
    x = sample_name,
    y = relative_abundance,
    fill = class_group
  )
) +
  geom_bar(
    stat = "identity",
    width = 0.9
  ) +
  scale_fill_manual(values = class_colours) +
  labs(
    x = "Sample",
    y = "Relative abundance within each sample",
    fill = "Resistance class"
  ) +
  theme_bw() +
  theme(
    axis.text.x = element_text(
      angle = 45,
      hjust = 1,
      size = 8
    )
  )

# Save PDF
ggsave(
  filename = file.path(
    figures_dir,
    "resistance_class_composition.pdf"
  ),
  plot = p1,
  width = 12,
  height = 6
)

# Save PNG
ggsave(
  file.path(figures_dir,
            "resistance_class_composition.png"),
  p1,
  width = 12,
  height = 6,
  dpi = 300
)

# Check output figures
file.exists(
  file.path(
    figures_dir,
    "resistance_class_composition.pdf"
  )
)

file.exists(
  file.path(
    figures_dir,
    "resistance_class_composition.png"
  )
)