# Research Log

This log records the main stages of my dissertation project, including the analyses performed, important decisions, troubleshooting and interpretation of results. It is intended to provide a clear record of how the analysis developed throughout the project. It is organised by project stage rather than individual code changes.

## 2026-05-10 - Initial data organisation

### Objective
To organise the AMR abundance files and study metadata before starting the analysis.

### Work completed
I reviewed the available abundance tables and metadata, and created separate folders for data, docs, figures, scripts, results and references.

### Outcome
The project inputs and outputs were organised into a consistent folder structure. The next step was to understand the sample metadata and combine the individual abundance files.

## 2026-05-13 - Understanding the study metadata

### Objective
To understand the relationship between samples, farms and corrals.

### Problem
The meanings of `sample_name`, `farm_id`, `corral_id` and `corral_type` were initially unclear. Farm identifiers such as ARG03 were also easy to confuse with antimicrobial resistance gene identifiers.

### Resolution
I compared the study design spreadsheet with the abundance tables. I confirmed that C015-type identifiers were sample IDs, ARG03-type identifiers were farm IDs, and `corral_type` described whether samples came from healthy or sick corrals.

### Outcome
I produced an initial composition plot and found that the detailed resistance annotations needed to be grouped before the plot could be displayed clearly.

## 2026-05-19 - GitHub repository setup

### Objective
To set up a GitHub repository for version control and project organisation.

### Work completed
I created the GitHub repository, added `.gitignore` and `.gitattributes`, and organised the project into scripts, figures, data, results and docs.

### Problem
At this stage I was unsure which project files should be tracked in the GitHub repository. I later relised that the raw research data should not be included in a public repository without supervisor approval.

### Next step
Keep scripts and permitted outputs under version control, and confirm with my supervisor which processed or statistical result files may be shared publicly.

## 2026-05-25 to 2026-05-29 - Building the data merge pipeline

### Objective
To combine the individual AMR feature files and study metadata into one analysis-ready table.

### Approach
I created `01_merge_data.R` to import the sample-level CSV files, obtain sample identifiers, combine abundance records and join the study metadata. I added checks for sample names, missing metadata and duplicated records.

### Problem
Some fields contained several resistance annotations in one value. These needed to be separated before abundance could be summarised correctly.

### Resolution
I converted the data into long format, with each row representing one resistance feature in one sample. The processed table contained one resistance feature per row together with the corresponding sample metadata.

### Data management decision
The processed analysis table was stored locally for downstream analysis, while only scripts and project documentation were maintained in the GitHub repository. 

### Validation

Checked that:
- sample names matched the study metadata;
- no duplicated samples remained after merging;
- missing metadata entries were identified before downstream analyses.

## 2026-06-02 to 2026-06-03 - Resistance class grouping and exploratory analysis

### Question
How should the detailed resistance annotations be grouped so that the composition plot is still readable but biologically meaningful?