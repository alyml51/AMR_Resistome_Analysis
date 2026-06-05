# 02_resistance_class_plots.R
# Purpose: Group resistance classes into broad categories and plot resistome composition
# Input: data/resistance_split_processed.csv from 01_merge_data.R
# Output: resistance class composition plots for downstream analysis

# The main analysis focuses on major antibiotic resistance classes.
# Metal and biocide resistance are kept as separate broader categories.
# Low-abundance or environmentally-specific classes are grouped as Other.

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

# Create broader resistance class groups
resistance_split$class_group <- case_when(
  
  # Major antibiotic resistance classes
  resistance_split$class == "betalactams" ~ "Beta-lactams",
  resistance_split$class == "Aminoglycosides" ~ "Aminoglycosides",
  resistance_split$class == "Tetracyclines" ~ "Tetracyclines",
  resistance_split$class == "MLS" ~ "MLS",
  resistance_split$class %in% c("Sulfonamides", "Trimethoprim") ~ "Sulfonamides/Trimethoprim",
  resistance_split$class == "Fluoroquinolones" ~ "Fluoroquinolones",
  resistance_split$class == "Phenicol" ~ "Phenicol",
  resistance_split$class == "Glycopeptides" ~ "Glycopeptides",
  resistance_split$class == "Rifampin" ~ "Rifampin",
  resistance_split$class == "Multi-drug_resistance" ~ "Multi-drug resistance",

  # Metal resistance
  resistance_split$class %in% c(
    "Copper_resistance", "Zinc_resistance", "Mercury_resistance",
    "Nickel_resistance", "Chromium_resistance", "Aluminum_resistance",
    "Iron_resistance", "Tellurium_resistance", "Multi-metal_resistance"
  ) ~ "Metal resistance",
  
  # Biocide/disinfectant resistance
   resistance_split$class %in% c(
    "Biguanide_resistance",
    "Biocide_and_metal_resistance",
    "Drug_and_biocide_resistance",
    "Drug_and_biocide_and_metal_resistance",
    "Multi-biocide_resistance",
    "Peroxide_resistance",
    "Phenolic_compound_resistance",
    "Quaternary_Ammonium_Compounds_(QACs)_resistance"
  ) ~ "Biocide resistance",
  
  # Other Low-abundance or environmental classes
  TRUE ~ "Other"
)

# Check the new class groups
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

