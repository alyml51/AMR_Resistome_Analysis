# 06_clr_pcoa_analysis.R
# Purpose: Explore resistome composition using CLR transformation and Aitchison distance
# Input: data/resistance_split_processed.csv from 01_merge_data.R
# Output: CLR-based PCoA plot of resistome composition across farm samples

# This analysis follows compositional data analysis principles.
# Zero counts are replaced using multiplicative replacement.
# CLR transformation is then applied before calculating Euclidean distance.
# Euclidean distance after CLR transformation is equivalent to Aitchison distance.

# Load packages
library(tidyverse)
library(vegan)
library(zCompositions)
library(compositions)

# Set working directory
project_dir <- "E:/A-4137/AMR_Rsistome_Analtsis"

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