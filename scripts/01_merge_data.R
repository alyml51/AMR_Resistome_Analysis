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
data_dir <- file.path(project_dir, "data")
figures_dir <- file.path(project_dir, "figures")

# List all AMR feature files
files <- list.files(
  path = data_dir,
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
  map(~ read_csv(.x, show_col_types = FALSE))

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
  file.path(data_dir, "Study Design Mengchan.xlsx")
  )

# Remove duplicated samples from metadata
metadata <- metadata %>%
  distinct(sample_name, .keep_all = TRUE)

# Join metadata
resistance_split <- resistance_split %>%
  left_join(metadata, by = "sample_name")

# Save processed table for later scripts
write.csv(
  resistance_split,
  file = file.path(data_dir, "resistance_split_processed.csv"),
  row.names = FALSE
)

# Check processed file was saved
file.exists(file.path(data_dir, "resistance_split_processed.csv"))

