# 01_merge_data.R
# Purpose: Import TELCoMB AMR feature files and study metadata
# Input: data/*_amr_features.csv and data/Study Design Mengchan.xlsx
# Output: data/resistance_split_processed.csv for downstream analysis

# Load packages
library(tidyverse)
library(readxl)

# Set project directory
project_dir <- "E:/A-4137/AMR_Resistome_Analysis"

# Define project folders
raw_data_dir <- "E:/A-4137/Mengchan/Data"
data_dir <- file.path(project_dir, "data")
figures_dir <- file.path(project_dir, "figures")

# List all AMR feature files
files <- list.files(
  path = raw_data_dir,
  pattern = "_amr_features\\.csv$",
  full.names = TRUE
)

# Check number of input files
length(files)

# Get sample names from file names
sample_names <- basename(files) %>%
  str_remove("_deduplicated\\.fastq_amr_features\\.csv$")

# Check number of sample names
length(sample_names)

# Read all AMR feature files and keep sample names
amr_list <- files %>%
  set_names(sample_names) %>%
  map(~ read_csv(
    .x, 
    show_col_types = FALSE,
    col_types = cols(
      .default = col_character()
      )
    ))

# Clean all AMR tables
cleaned_list <- amr_list %>%
  imap(~ separate(.x, Statistics,
                  into = c("feature", "value"),
                  sep = ",", 
                  extra = "merge", 
                  fill = "right") %>%
         mutate(sample_name = .y))

# Merge all cleaned tables
amr_clean <- bind_rows(cleaned_list)

# Keep rows that contain resistance annotation information
resistance_data <- amr_clean %>%
  filter(grepl("\\|", feature))

# Split feature column to extract resistance class
resistance_split <- separate(
  resistance_data,
  feature,
  into = c("gene_id", "type", "class", "description"),
  sep = "\\|",
  extra = "merge",
  fill = "right"
)

# Extract numeric abundance from value column
resistance_split <- resistance_split %>%
  mutate(abundance = as.numeric(str_extract(value, "^[0-9.]+")))

# Check abundance extraction
sum(is.na(resistance_split$abundance))

# Check number of resistance classes
length(unique(resistance_split$class))

# Add sample type information
resistance_split$sample_type <- ifelse(
  resistance_split$sample_name == "Pristine_Soil",
  "control",
  "farm_sample"
)

# Check sample type assignment
table(resistance_split$sample_type)

# Read and join study metadata
metadata <- read_excel(
  file.path(raw_data_dir, "Study Design Mengchan.xlsx")
  )

# Remove duplicated samples from metadata
metadata <- metadata %>%
  distinct(sample_name, .keep_all = TRUE)

# Join metadata
resistance_split <- resistance_split %>%
  left_join(metadata, by = "sample_name")

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

# Save processed table for later scripts
write.csv(
  resistance_split,
  file = file.path(data_dir, "resistance_split_processed.csv"),
  row.names = FALSE
)

# Check processed file was saved
file.exists(file.path(data_dir, "resistance_split_processed.csv"))

