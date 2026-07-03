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

### Investigation
I reviewed the detailed resistance categories and compared different grouping options. A plot using all 49 detailed categories was too fragmented and difficlut to interpret. I also considered whether low-abundance classes should br merged, and whether metal and biocide resistance should be kept separetely.

### Decision
I grouped the detailed annotations into 13 broader resistance class groups. Major antimicrobial classes were kept separately, and metal and biocide resistance were also retained as sepaarte groups because they may be relevant to environmental selection in the farm setting. Categories that did not fit the main groups were assigned to `Other`.

### Rationale
This grouping made the composition plot easier to interpret while retaining the main biological patterns. The same grouped classification could also be used consistently for composition plots, diversity analysis and MaAsLin2. The grouping approach was discussed with and accepted by the supervisor.

### Troubleshooting
I initially created a PCA script, but later changed to PCoA because the beta-diversity analysis was based on a dissimilarity matrix rather than the original variables.

### Outcome
The 13 resistance class groups were used as the main class-level input for the downstream analysis.

## 2026-06-05 - First resistance class composition figure

### Objective
To visualise how the mian resistance class groups contributed to the resistome profile of each farm sample.

### Approach
I summarised the abundance data by smaple and resistance class group, then converted the values to within-sample relative abundance. A stacked bar plot was produced to show the proportional contribution of the 13 resistance class groups across samples.

### Problem
The first version of the figure was difficult to interpret. The legend was crowded, some class labels were unclear, and the large number of samples made the axis text difficult to read. This made the plot unsuitable for dissertation presentation in its original form.

### Resolution
I revised the plotting code by improving the class labels, adjusting the colour palette, ordering the samples more clearly, and exporting the figure in both PDF and PNG formats. I kept the plot at the grouped resistance-class level rather than returning to the full detailed annotation level, because the grouped version was more readable and better matched the downstream analyses.

### Interpretation
The figure showed that resistome composition varied substantially between individual farm samples. Aminoglycoside-associated resistance and MLS resistance contributed strongly to many samples, while tetracycline, metal and biocide resistance showed more sample-specific patterns. This suggested that the main analysis should focus not only on individual high-abundance classes, but also on overall composition differences between samples and corral types.

## 2026-06-07 to 2026-06-09 - Sample selection and PCoA development

### Objective
To ensure that the analysed samples matched the research question and to visualise between-sample compositional differences.

### Data selection
After checking the processed dataset, I confirmed that it contained 33 farm samples and one pristine soil control. Since the project aimed to compare resistome composition between farm corrals rather than enviromental backgrounds, the pristine soil control was excluded from all downstream statistical analyses.

### Supervisor feedback
One disease-associated category (S1) contained only a single sample. I discussed with my supervisor whether it should remain as an independent group or be merged with the S group. We agreed to combine S1 with S because both represented sick corrals and analysing S1 separately would provide little statistical value.

### Approach
Relative abundance profiles of the 13 resistance class groups were used to calculate Bray-Curtis dissimilarities. Principal Coordinates Analysis (PCoA) was then performed to visualise differences in resistome composition among farm samples.

### Figure decision
The first version of the PCoA plot contained sample labels and farm labels, making the figure difficult to interpret. After discussing the figure with my supervisor, I simplified the visualisation by removing individual labels and representing corral type using colour only. The revised figure was much clearer and more suitable for inclusion in the dissertation.

### Reflection
Although the PCoA suggested some separation between healthy and sick corrals, visual inspection alone was insufficient. Formal statistical tests would be required to determine whether the observed differences were significant.

## 2026-06-09 - Initial alpha diversity analysis

### Objective
To compare within-sample resistance class diversity between healthy and sick corrals.

### Approach
I calculated Shannon diversity and inverse Simpson diversity for each sample and compared healthy and sick corrals using separate boxplots.

### Limitation
Although Shannon and inverse Simpson diversity captured different aspects of alpha diversity, the results were presented on differnet mathematical scales and were therefore less intuitive to compare and interpret.

### Supervisor feedback
After discussing the results with my supervisor, I decided to replace the traditional diversity indices with Hill number (q = 0, 1, and 2). Hill number express diversity as the effective number of resistance classes and provide a more interpretable framework for comparing alpha diversity.

### Reflection
This change required rewriting the alpha diversity analysis but produced figures that were easier to interpret and more consistent with current ecological diversity analysis.

## 2026-06-18 - Figure optimisation for exploratory analysis

### Objective
To improve the readability of the resistance composition and PCoA figures before proceeding to downstream statistical analyses.

### Problem
The initial figures were difficult to interpret because of crowded legends, overlapping labels and inconsistent formatting between different plots.

### Changes
I simplified the composition plot by separeting healthy and sick samples into facets, reducing unnecessary labels and improving axis formatting. The PCoA figure was also simplified by removing individual sample labels while retaining corral type as the main visual grouping.

### Outcome
The figures became easier to compare and more suitable for dissertation presentation. PDF versions were retained for insertion into the dissertation, with PNG versions used for checking and sharing.

### Reflection 
Improving the figures at this stage made subsequent interpretation much easier and helped identify which statistical analyses were still required.

## 2026-06-21 - PERMANOVA and PERMDISP

### Objective
To formally test whether overall resistome composition differed between healthy and sick corrals.

### Approach
PERMANOVA was applied to the Bray-Curtis distance matrix with corral type as the explanatory variable. PERMDISP was used to test whether any PERMANOVA result could be explained by unequal within-group dispersion.

### Results
PERMANOVA indicated that corral type explained approximately 13% of the variation in resistance class composition (R<sup>2</sup> = 0.130, p = 0.018). PERMDISP was not significant (p = 0.552), indicating that within-group dispersion did not differ between corral types.

### Reflection
The PERMDISP result increased my confidence that the PERMANOVA result reflected differences in resistome composition rather than differences in within-group variability. However, corral type explained only a reletively small proportion of the total variation (R<sup>2</sup> = 0.130), suggesting that farm-specific conditions, management practices or other environmental factors may also influence resistome composition.

## 2026-06-22 to 2026-06-23 - Hill number diversity analysis

### Objective
To compare resistance class richness, evenness and dominance between corral types.

### Approach
Following supervisor feedback, I replaced the original Shannon and inverse Simpson analysis with Hill numbers so that richness (q = 0), Shannon diversity (q = 1) and Simpson diversity (q = 2) could be interpreted within a single framework. Wilcoxon rank-sum tests were then used to compare healthy and sick corrals.

### Initial results
The median q = 0 value was similar between H and S, whereas q = 1 and q = 2 tended to be higher in S. Before multiple testing correction, q = 1 and q = 2 showed nominal significance, while q = 0 did not.

### Interpretation
Hill numbers provided a more intuitive way to compare diversity than reporting Shannon and inverse Simpson separately. Although q = 1 and q = 2 appeared higher in S before correction, these differences became less convincing after adjustment for multiple testing. This reinforced the decision to present Hill numbers as descriptive evidence rather than strong statistical findings.

## 2026-06-23 to 2026-06-24 - MaAsLin2 association analysis

### Objective
To test whether individual resistance class groups were associated with corral type while considering farm-level structure.

### Approach
I used MaAsLin2 with corral type as a fixed effect and farm ID as a random effect to account for the study design. H was used as the reference group so that coefficient represented changes relative to healthy corrals. A coefficient plot was created to visualise the direction and magnitude of the estimated effects.

### Results
After false discovery rate correction, no resistance class remained statistically significant. Before correction, tetracycline and metal resistance showed the strongest positive coefficients in S, whereas several other classes showed negative coefficients relative to H.

### Interpretation
The MaAsLin2 results suggested that the overall PERMANOVA signal was likely driven by modest changes across multiple resistance classes rather than a single dominant class. Although no individual association remained significant after multiple testing correction, the coefficient plot provided a useful summary of the direction and relative magnitude of the observed trends. The supervisor responded positively to this visualisation and agreed that it was suitable for inclusion in the dissertation.

## 2026-06-24 - Multiple-testing correction for Hill numbers

### Reason for additional check
Three related Hill number comparisons had been performed. Reporting only the unadjusted p-values could increase the risk of over-interpreting the results.

### Approach
I applied Benjamini-Hochberg correction across the q0, q1 and q2 Wilcoxon tests.

### Results
The adjusted p-value was 0.170 for q = 0 and 0.069 for both q = 1 and q = 2. Therefore, neither q = 1 nor q = 2 remained statistically significant after correction.

### Interpretation
Although S samples showed higher median q = 1 and q = 2 values, the evidence was not statistically significant after multiple-testing correction. I decided to report both the original and adjusted p-values so that the results could be interpreted transparently.

## 2026-06-24 - Supervisor feedback and CLR/Aitchison analysis decision

### Feedback
The supervisor said that the current figures looked good and particularly liked the MaAsLin2 coefficient plot. He recommended adding a CLR-based analysis because resistome read counts are compositional.

### Analytical issue
After reading about compositional data analysis, I realised that Bray-Curtis and CLR-based approaches emphasise different properties of the data. Because CLR transformation requires positive values, an additional zero-replacement step would also be needed before the analysis.

### Decision
I decided to keep the original Bray-Curtis workflow and build a separate CLR/Aitchison workflow instead of replacing the existing analysis. This would allow both approaches to be compared while keeping the original results unchanged.

### Next step
Develop and validate the CLR/Aitchison workflow before deciding whether it should replace or complement the existing Bray-Curtis analysis.
