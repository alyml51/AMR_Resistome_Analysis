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


## 2026-06-25 to 2026-06-27 - CLR/Aitchison workflow implementation

### Objective

To implement the CLR-based compositional workflow recommended by the supervisor and compare it with the existing Bray-Curtis analysis.

### Analytical issue

CLR transformation cannot be applied directly when zero values are present. I therefore reviewed approaches for handling zeros in compositional data before performing the transformation.

### Approach

Zero values were replaced using multiplicative replacement before applying the centred log-ratio transformation. Euclidean distances were then calculated on the CLR-transformed data to generate an Aitchison distance matrix, followed by PCoA.

### Troubleshooting

During implementation, some functions produced unexpected errors because of namespace conflicts between R packages. Explicitly calling `dplyr::select()` resolved the problem and improved the reproducibility of the script.

### Outcome
The CLR/Aitchison workflow was completed successfully and produced a second beta-diversity analysis that could be compared directly with the original Bray-Curtis results.


## 2026-06-28 to 2026-06-29 - CLR-based beta diversity analysis

### Objective

To evaluate whether the CLR/Aitchison workflow produced similar conclusions to the original Bray-Curtis analysis.

### Approach

After generating the Aitchison distance matrix and CLR-based PCoA, I applied PERMANOVA using corral type as the explanatory variable. I also performed PERMDISP to verify that any observed differences were not caused by unequal within-group dispersion.

### Results

The CLR-based PERMANOVA was not statistically significant (R<sup>2</sup> = 0.049, p = 0.151). PERMDISP was also not significant (p = 0.769), indicating that dispersion did not differ between healthy and sick corrals.

### Interpretation

Compared with the original Bray-Curtis analysis, the CLR-based workflow showed weaker evidence for differences between corral types. This suggested that the statistical conclusion depended partly on the choice of distance metric, highlighting the importance of reporting both analyses rather than relying on a single method.


## 2026-06-29 to 2026-07-01 - Figure standardisation

### Objective

To standardise all dissertation figures before writing the Results section.

### Changes

I reviewed every figure produced during the analysis and applied a consistent visual style across the dissertation. Colours representing healthy (H) and sick (S) corrals were standardised, figure fonts and axis formatting were made consistent, and legends were simplified where necessary. Several figures were also rearranged to improve readability and ensure a consistent layout throughout the Results section. All figures were regenerated and exported in both PNG and PDF formats.

### Rationale

Although the statistical results did not change, presenting figures in a consistent format improves readability and makes comparisons between different analyses easier for the reader.

### Outcome

The resistance composition plots, Hill number plots, MaAsLin2 coefficient plot, Bray-Curtis PCoA and CLR/Aitchison PCoA all followed the same visual style and were ready for inclusion in the dissertation.


## 2026-07-01 - Preparing the final analysis set

### Objective

To review all completed analyses and decide which figures and statistical results would be included in the dissertation.

### Review

I compared the outputs from the Bray-Curtis and CLR/Aitchison workflows together with the Hill number and MaAsLin2 analyses. The aim was to ensure that each figure addressed a different research question and that the overall analysis remained coherent.

### Decision

The Bray-Curtis analysis was retained as the primary beta-diversity analysis because it was consistent with the original analysis plan and showed a significant association between corral type and resistome composition. The CLR analysis was retained as a complementary analysis to demonstrate that an alternative compositional approach had also been evaluated.

### Outcome

At this stage, all planned statistical analyses and dissertation figures had been completed. The project was ready to move from analysis to writing.


## 2026-07-02 - Final reproducibility check

### Objective

To verify that the complete analysis pipeline could be reproduced from a clean R session before writing the dissertation.

### Procedure

I cleared the R environment and reran the complete workflow from the raw processed data, including diversity analyses, beta-diversity analyses, statistical tests and figure generation.

### Troubleshooting

During the rerun, `select()` produced an unexpected error because another loaded package masked the dplyr function. I resolved the issue by explicitly using `dplyr::select()` throughout the script to remove the namespace conflict.

### Validation

After correcting the function calls, all analyses completed successfully. The statistical outputs, figures, PDF files and exported CSV tables were regenerated without manual intervention and matched the previous results.

### Outcome

The complete workflow was confirmed to be reproducible from a fresh R session. This also improved the robustness and portability of the analysis scripts before dissertation writing.


## 2026-07-03 - Transition to dissertation writing

### Objective

To prepare the completed analysis outputs for writing the dissertation Results section.

### Review

I reviewed the final figures, statistical outputs and research log to ensure that the analysis workflow was complete and that each result could be traced back to the corresponding script and output file.

### Outcome

All planned analyses had been completed, including resistance class composition, alpha diversity, Bray-Curtis PCoA, CLR/Aitchison PCoA, PERMANOVA, PERMDISP and MaAsLin2. The project was ready to move from analysis to interpretation, literature review and dissertation writing.

### Next step

Begin drafting the Results section and identify supporting literature for the Methods and Discussion sections.