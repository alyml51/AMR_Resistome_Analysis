# 02_resistance_class_plots.R
# Purpose: Group resistance classes into broad categories and plot resistome composition
# Input: processed abundance table from 01_merge_data.R
# Output: resistance class composition plots for downstream analysis

# The main analysis focuses on major antibiotic resistance classes.
# Metal and biocide resistance are kept as separate broader categories because they may be relevant to co-selection.
# Low-abundance or environmentally-specific classes are grouped as "Other".

# Load packages
library(dplyr)
library(ggplot2)

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
    abundance = sum(as.numeric(value), na.rm = TRUE),
    .groups = "drop"
  )

# Check summary table
head(class_summary)
dim(class_summary)

# Check value column type
class(resistance_split$value)

# Count non-numeric values
sum(is.na(suppressWarnings(as.numeric(resistance_split$value))))

# Show examples
resistance_split %>%
  filter(is.na(suppressWarnings(as.numeric(value)))) %>%
  select(value) %>%
  distinct() %>%
  head(20)
