# AMR Resistome Analysis

## Project overview

This repository contains the R scripts and supporting documentation developed for the MSc Bioinformatics dissertation:

**Resistome composition and clinically relevant low-abundance antimicrobial resistance gene families in Argentine beef cattle corrals using target-enriched long-read sequencing**

The study compared the relative composition of resistance classes between Manga (healthy; H) and Enfermeria (sick; S) corrals in Argentine beef cattle production systems. The analysis included 33 farm samples from 26 farms, comprising 25 healthy-corral samples and eight sick-corral samples. Seven farms were represented by both corral types. A pristine-soil sample was included during initial data processing but excluded from comparisons between corral types.

## Data origin

The dataset and study metadata were provided by Dr Adam Blanchard for this dissertation.

Sample collection, DNA extraction, RNA bait capture, Oxford Nanopore long-read sequencing based on the TELSeq approach, and initial TELCoMB processing were completed by the project team before this analysis.

The starting inputs to this R workflow were sample-level TELCoMB AMR feature reports rather than raw sequencing FASTQ files. Therefore, `data/raw` refers to the original inputs supplied for this analysis, not to raw sequencing reads.

## Input files

The complete analysis used the following restricted input files:

| Input | File type | Number of files | Approximate scale | Description |
|---|---:|---:|---:|---|
| Sample-level TELCoMB AMR feature reports | CSV | 34 | Approximately 2 MB in total; individual files ranged from a few kilobytes to approximately 90 KB | One feature report for each of the 33 farm samples and one pristine-soil control |
| Study metadata | XLSX | 1 | Approximately 10 KB | Metadata linking each sample to its study, farm, corral and corral type |

The TELCoMB feature reports followed this naming pattern:

```text
<sample_id>_deduplicated.fastq_amr_features.csv
```

The metadata file used by the workflow was:

```text
Study Design Mengchan.xlsx
```

The metadata workbook contained 37 records representing 34 unique sample IDs. Repeated sample-name records were reduced to one metadata record per sample before the metadata were joined to the AMR feature tables.

After parsing and merging, the local processed table contained approximately 17,900 retained AMR annotation records. This processed sample-level table is also treated as restricted data.

When authorised input files are available, the expected local directory is:

```text
data/raw/
```

## Data availability

The TELCoMB feature reports, study metadata and derived sample-level data are not included in this public repository.

These materials form part of an unpublished project dataset and have not been approved by the project team for public release. Following the supervisor's instruction, the AMR feature reports, metadata workbook and merged processed data are not made publicly available through GitHub.

To run the workflow, authorised input files should be placed in `data/raw/` using the filenames described above.

## Repository structure

The public repository has the following structure:

```text
AMR_Resistome_Analysis/
├── README.md
├── docs/
│   └── research_log.md
├── figures/
├── scripts/
├── .gitattributes
└── .gitignore
```

## Software environment

All analyses were conducted using R version 4.5.1.

| Software or package | Version used |
|---|---:|
| R | 4.5.1 |
| tidyverse | 2.0.0 |
| readxl | 1.4.5 |
| vegan | 2.7-2 |
| permute | 0.9-10 |
| zCompositions | 1.6.2 |
| compositions | 2.0-9 |
| MaAsLin2 | 1.24.1 |
| patchwork | 1.3.2 |

## Package installation

The required CRAN packages can be installed using:

```r
install.packages(
  c(
    "tidyverse",
    "readxl",
    "vegan",
    "permute",
    "zCompositions",
    "compositions",
    "patchwork"
  )
)
```

MaAsLin2 can be installed through Bioconductor:

```r
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}

BiocManager::install("Maaslin2")
```

The commands above install the required packages. The versions used for the dissertation are reported in the software table.

## Running the analysis

The repository root must be used as the R working directory because the scripts use project-relative paths.

For example:

```r
setwd("path/to/AMR_Resistome_Analysis")
```

The scripts should be run in numerical order.

### 1. Data processing

```text
scripts/01_merge_data.R
```

This script imports the TELCoMB feature reports and study metadata, extracts the AMR annotations and feature-level read counts, groups the original resistance classes into 13 broader categories, and generates the processed table used by the remaining scripts.

### 2. Resistance class composition

```text
scripts/02_figure1_resistance_class_plots.R
```

This script calculates the relative abundance of each resistance class group within each sample and produces the stacked bar plot used for Figure 1.

### 3. Bray-Curtis analysis

```text
scripts/03_pcoa_analysis.R
```

This script calculates Bray-Curtis dissimilarities from class-level relative abundances, performs PCoA, and runs the unadjusted, within-farm restricted and sequential PERMANOVA analyses. It also performs the Bray-Curtis PERMDISP analysis.

### 4. Alpha diversity

```text
scripts/04_alpha_diversity.R
```

This script calculates Hill numbers q = 0, q = 1 and q = 2. It performs full-dataset Wilcoxon rank-sum tests and paired Wilcoxon signed-rank tests for the seven farms represented by both corral types.

### 5. Class-level association analysis

```text
scripts/05_figure4_maaslin2_analysis.R
```

This script runs MaAsLin2 with corral type as a fixed effect and farm as a random effect. It generates the class-level association results and the coefficient plot used for Figure 4.

### 6. CLR/Aitchison analysis

```text
scripts/06_clr_pcoa_analysis.R
```

This script applies count zero multiplicative replacement and centred log-ratio transformation, calculates Aitchison distances, performs PCoA, and runs the corresponding PERMANOVA and PERMDISP analyses.

### 7. Combined PCoA figure

```text
scripts/07_figure2_pcoa_combination.R
```

This script combines the Bray-Curtis and CLR/Aitchison PCoA plots into Figure 2. It sources scripts 03 and 06 and therefore reruns the component analyses.

### 8. Combined Hill-number figure

```text
scripts/08_figure3_hill_combination.R
```

This script combines the three Hill-number plots into Figure 3. It sources script 04 and therefore reruns the alpha-diversity analysis.

### 9. Clinically relevant low-abundance ARG analysis

```text
scripts/09_clinical_arg_analysis.R
```

This script performs the descriptive analysis of the selected RPH, ARR, IMP, SPM and KHM ARG families. Annotations requiring SNP confirmation are excluded from this analysis. The script produces the detection summary and sample-level relative-abundance heatmap used for Figure 5.

## Expected outputs

The workflow generates:

- the processed AMR annotation table for local downstream analysis;
- the resistance class composition plot;
- Bray-Curtis and CLR/Aitchison PCoA plots;
- PERMANOVA and PERMDISP result tables;
- Hill-number results and statistical comparisons;
- MaAsLin2 result tables and coefficient plot;
- descriptive detection and relative-abundance summaries for the selected ARG families; and
- the five figures presented in the dissertation.

The main statistical findings are reported in the dissertation. Restricted input files and sample-level processed data are not included in the public repository.

## Reproducibility

A random seed of 123 was set before permutation-based analyses and plotting operations involving random jitter.

The expected input filenames, directory structure, software versions and order of analysis are documented in this README. The development of the analysis, troubleshooting steps, statistical decisions and changes in interpretation are recorded in:

```text
docs/research_log.md
```

## Code provenance

I developed the project-specific R scripts for this dissertation using documented functions from the R packages listed above. Dr Adam Blanchard provided guidance on the analytical framework and recommended the following online resources:

- [phyloseq documentation](https://joey711.github.io/phyloseq/)
- [vegan documentation](https://vegandevs.github.io/vegan/)
- [Alpha-diversity metrics](https://biostatsquid.com/alpha-diversity-metrics/)
- [Hill numbers](https://biostatsquid.com/hill-numbers/)

These resources informed my understanding and selection of microbiome ecological methods, including alpha-diversity analysis, Hill numbers, ordination and PERMANOVA. Dr Blanchard also recommended compositional analysis and MaAsLin2 for class-level association testing. The package functions used are identified in the scripts, and the relevant software packages are cited in the dissertation.

## Use of generative AI

OpenAI ChatGPT was used as a supplementary tool for code troubleshooting and refinement, and for checking grammar, wording and clarity in the written dissertation. I ran and checked all scripts, reviewed the analysis outputs, made the analytical and interpretive decisions, and take responsibility for the final analysis and interpretation.