# 01_merge_data.R
# Purpose: Import TELCoMB AMR feature files and study metadata
# Input: data/*_amr_features.csv and data/Study Design Mengchan.xlsx
# Output: processed abundance tables for downstream analysis

# Load packages
library(tidyverse)
library(readxl)

# Set working directory
project_dir <- "E:/A-4137/AMR_Resistome_Analysis"

# List all AMR feature files
files <- list.files(
  path = file.path(project_dir, '/data'),
  pattern = "_amr_features\\.csv$",
  full.names = TRUE
)

# Check file names
files

# Get sample names from file names
sample_names <- basename(files) %>%
  str_remove("_deduplicated\\.fastq_amr_features\\.csv$")

# Check sample names
sample_names
length(sample_names)

# Read all AMR feature files and keep sample names
amr_list <- files %>%
  set_names(sample_names) %>%
  map(read_csv)

# Check the first sample table
names(amr_list)
head(amr_list[[1]])

# Inspect the first 10 rows of the first sample
amr_list[[1]][1:10, ]

# Split the Statistics column into feature and value columns
test_sample <- separate(
  
  amr_list[[1]],
  
  Statistics,
  
  into = c("feature", "value"),
  
  sep = ","
)

# Check cleaned sample table
head(test_sample, 20)

# Clean all AMR tables
cleaned_list <- list()

for (i in 1:length(amr_list)) {
  
  temp_table <- separate(
    
    amr_list[[i]],
    
    Statistics,
    
    into = c("feature", "value"),
    
    sep = ",",
    
    extra = "merge",
    
    fill = "right"
    
  )
  
  temp_table$sample_name <- names(amr_list)[i]
  
  cleaned_list[[i]] <- temp_table
}

# Merge all cleaned tables
amr_clean <- bind_rows(cleaned_list)

# Check merged table
head(amr_clean)

dim(amr_clean)

# Keep rows that contain resistance information
resistance_data <- amr_clean %>%
  
  filter(
    grepl("\\|", feature)
  )

# Check resistance data
head(resistance_data)

dim(resistance_data)

# Split feature column to extract resistance class
resistance_split <- separate(
  
  resistance_data,
  
  feature,
  
  into = c("gene_id", "type", "class", "description"),
  
  sep = "\\|",
  
  extra = "merge",
  
  fill = "right"
)

# Check extracted resistance classes
head(resistance_split)

table(resistance_split$class)

# Add sample type information
resistance_split$sample_type <- ifelse(
  
  resistance_split$sample_name == "Pristine_Soil",
  
  "control",
  
  "farm_sample"
)

# Check sample type
table(resistance_split$sample_type)

# Check updated table
head(resistance_split)