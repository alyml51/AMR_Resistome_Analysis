# Research Log

This log records the development of my dissertation project from data organisation to final interpretation. It documents the main analyses, methodological decisions, troubleshooting, supervisor feedback and changes in interpretation. The purpose is to provide a concise and traceable record of how the project developed, including decisions that were later revised when the sampling structure or statistical assumptions were reassessed.

The log is organised by project stage rather than by individual code change. Scripts, figures and statistical outputs are maintained in the GitHub repository so that each major result can be traced to the corresponding analysis step.


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

### Code provenance

The analysis scripts were written and organised by me using established R packages, including `tidyverse`, `vegan` and `MaAsLin2`. Package functions were used for standard statistical procedures, while the data processing workflow, metadata integration, resistance class grouping, model specification and figure generation were developed for this project. External documentation and published methods were consulted where necessary and are referenced in the scripts or dissertation.


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


## 2026-07-04 - Farm-adjusted statistical analysis

### Objective

To evaluate whether the apparent differences between healthy and sick corrals remained after accounting for farm-level structure and sample non-independence.

### Review

Re-examined the beta-diversity analyses after considering the hierarchical sampling design. PERMANOVA was repeated using restricted permutations within farms, and sequential models were fitted to separate farm effects from corral-type effects. PERMDISP was also performed to determine whether any observed separation reflected differences in within-group dispersion rather than compositional structure.

### Outcome

The farm-adjusted analyses showed that farm explained most of the variation in resistome composition, whereas corral type contributed only a small additional proportion. The apparent separation between healthy and sick corrals observed in the unrestricted analysis was not supported after accounting for farm. The non-significant PERMDISP result indicated that differences in dispersion were unlikely to explain the observed ordination patterns.

### Next step

Update the Results and Discussion sections to reflect the revised statistical interpretation.


## 2026-07-05 - Revision of Results section

### Objective

To revise the Results section so that all statistical interpretations were consistent with the updated analyses.

### Review

I rewrote the beta-diversity, alpha-diversity and resistance class association sections using the farm-adjusted statistical results. Figures, statistical outputs and corresponding text were reviewed together to ensure that all reported interpretations were supported by the final analyses.

### Outcome

The Results section consistently reflected the revised statistical framework. Statements implying a robust corral-type effect were removed where they were no longer supported, and the descriptions of the statistical analyses were aligned with the final outputs.

### Next step

Revise the Discussion to ensure that the biological interpretation remained consistent with the updated Results.


## 2026-07-06 - Discussion development

### Objective

To develop a coherent Discussion based on the revised statistical analyses.

### Review

I reorganised the Discussion around the main research question of whether healthy and sick corrals represented different resistome environments. Each subsection was revised to distinguish relative abundance from absolute resistance burden, association from causation, and statistically supported findings from directional trends. Comparisons with previous livestock resistome studies were refined to explain similarities and differences without extending beyond the available evidence.

### Outcome

A complete revised Discussion was produced with a consistent interpretation across all analytical sections and clearer links between the Results and previous literature.

### Next step

Extend the analyses of clinically relevant low-abundance ARG families and integrate the findings into the dissertation.


## 2026-07-07 - Clinical ARG analysis

### Objective

To investigate clinically relevant low-abundance antimicrobial resistance gene families that were not apparent in the resistance class analyses.

### Review

I performed descriptive analyses of selected carbapenem-associated metallo-β-lactamase families and rifampin-associated resistance families. Detection frequencies and sample-level heatmaps were generated to summarise their distribution across healthy and sick corrals. ARG families requiring SNP confirmation were excluded from interpretation.

### Outcome

The clinically relevant ARG families were detected at low relative abundance in both healthy and sick corrals. These analyses provided descriptive evidence for surveillance purposes but did not indicate statistically supported differences between corral types.

### Next step

Integrate the clinical ARG analyses into the Results and Discussion sections.


## 2026-07-08 - Final dissertation revision

### Objective

To complete the final scientific revision of the dissertation following supervisor feedback.

### Review

I revised the statistical interpretation throughout the dissertation and refined the Discussion to improve consistency between the Results and previous literature. Terminology, figure captions and language were standardised, and repetitive or overly cautious wording was reduced while ensuring that all conclusions remained supported by the statistical evidence.

### Outcome

The dissertation reached a complete draft with consistent Methods, Results and Discussion sections. All figures, statistical analyses and written interpretations were aligned with the final analytical framework.

### Next step

Carry out final proofreading, formatting checks and prepare the dissertation for submission.


## 2026-07-09 to 2026-07-13 - Restructuring the Discussion using the literature

### Aim

To revise the Discussion so that the results were compared directly with relevant cattle AMR and resistome studies rather than discussed in isolation.

### Literature review

I revisited the papers recommended by the supervisor, with particular attention to how their Discussion sections were constructed. Garzon et al. (2025) was especially useful because it compared cattle pens with different health and management functions. Bedford et al. (2024) provided context for antimicrobial use and treatment decisions in Argentine beef production, while Ali et al. (2025) showed that cattle AMR patterns are influenced by several animal-, farm- and management-related factors.

### Revision strategy

The Discussion was reorganised so that each subsection addressed a specific part of the main question:

- whether overall resistome composition differed between corral types;
- whether any difference involved resistance class diversity;
- whether a single resistance class explained the pattern;
- what limitations prevented causal interpretation.

Literature was used to compare specific findings rather than only stating that the results were “consistent with” previous studies.

### Outcome

The revised Discussion developed a clearer argument. Healthy and sick corrals shared the same dominant resistance categories, while the initial analyses suggested possible differences in their proportional composition. Alpha diversity and class-level associations provided weaker evidence, which prevented a simple conclusion that sick corrals carried a greater AMR burden.

### Reflection

This revision changed my understanding of the purpose of a Discussion section. The main task was not to repeat the statistical results, but to explain how the different analyses contributed to one interpretation and where that interpretation remained uncertain.


## 2026-07-14 to 2026-07-16 - Reassessment of farm structure and sample independence

### Reason for reassessment

The samples were collected from 26 farms, but only seven farms contained both healthy and sick corral samples. This raised the possibility that the apparent corral-type separation in the original analysis was partly influenced by differences among farms.

The original Bray-Curtis PERMANOVA had treated corral type as the main explanatory variable without fully separating it from farm background. I therefore revisited the sampling design and the supervisor's earlier advice regarding non-independence among samples from the same sampling unit.

### Analytical changes

I fitted sequential PERMANOVA models in which farm was entered before corral type. This allowed the additional variation associated with corral type to be assessed after farm-level variation had been considered.

The same procedure was applied to both Bray-Curtis and CLR/Aitchison distances. PERMDISP was repeated for both distance measures to test whether differences in multivariate dispersion could explain the ordination patterns.

### Results

In the sequential models, farm accounted for 67.8% of the Bray-Curtis variation and 71.0% of the CLR/Aitchison variation before corral type was entered. These percentages depend on term order and were therefore treated as sequential model components rather than causal estimates.

After farm was included, corral type explained only a further 2.1% of the Bray-Curtis variation (R² = 0.021, F = 0.42, p = 0.859) and 2.8% of the CLR/Aitchison variation (R² = 0.028, F = 0.64, p = 0.719). Neither effect was statistically significant.

Multivariate dispersion also did not differ between corral types for either Bray-Curtis (F = 0.55, p = 0.688) or CLR/Aitchison distances (F = 0.23, p = 0.688).

### Interpretation

The visual separation in the unadjusted ordinations did not persist after farm was considered. The analyses therefore provided little evidence for a corral-type pattern that was reproduced independently across farms.

This required a substantial change to the original interpretation. The unrestricted PERMANOVA result could no longer be presented as evidence that corral type independently explained a significant proportion of resistome variation.

### Research decision

The Results and Discussion were revised so that farm-level heterogeneity became central to the interpretation. The conclusion was changed from a modest corral-type effect to an absence of a consistent farm-independent difference between healthy and sick corrals.


## 2026-07-15 to 2026-07-16 - Within-farm alpha-diversity comparisons

### Question

Were the higher Hill q = 1 and q = 2 values observed in the full sick-corral group reproduced when healthy and sick samples were compared within the same farms?

### Approach

The seven farms containing both healthy and sick corrals were analysed as paired observations. Paired comparisons were performed for Hill q = 0, q = 1 and q = 2, followed by multiple-testing correction.

### Results

None of the three Hill numbers differed significantly between paired healthy and sick samples. All adjusted p-values were at least 0.673, and the direction of the healthy-sick difference varied among farms.

### Interpretation

The higher q = 1 and q = 2 values observed in the full sick-corral group were not consistently reproduced within farms. This indicated that the initial directional pattern may have reflected the unbalanced farm composition of the two groups rather than a general corral-type effect.

### Outcome

The paired analysis was added as a sensitivity analysis. The Discussion was revised to state that alpha diversity did not differ consistently between healthy and sick corrals, either in the full analysis after correction or in the within-farm comparisons.


## 2026-07-16 to 2026-07-17 - Analysis of clinically relevant low-abundance ARG families

### Motivation

The main analysis grouped resistance features into 13 broad categories. This was appropriate for comparing overall resistome structure but could obscure individual low-abundance ARG families with clinical relevance.

### Selection of ARG families

I examined selected rifampin-associated families (RPH and ARR) and carbapenem-associated metallo-β-lactamase families (IMP, SPM and KHM). Features whose interpretation depended on SNP confirmation were excluded.

### Visualisation

Two complementary figures were produced:

- a sample-level heatmap showing the relative abundance of each selected ARG family;
- a detection-frequency plot showing the percentage of healthy and sick samples in which each family was detected.

The heatmap was used to show variation among individual samples, while the detection plot summarised the group-level distribution.

### Findings

RPH and IMP were the most widely distributed selected families and were detected in both healthy and sick corrals. ARR, SPM and KHM were detected less frequently, and some occurred only in healthy-corral samples.

The selected families were present at very low relative abundance. Their distribution was therefore interpreted descriptively and was not treated as evidence of a difference in prevalence between corral types, particularly because only eight sick-corral samples were available.

### Interpretation

These ARG families did not explain the broad class-level resistome patterns. Their value was instead related to surveillance, because low-abundance resistance determinants associated with rifampin or carbapenem resistance may remain clinically relevant even when they contribute little to total relative abundance.

The available feature-count data did not retain read- or contig-level genomic context. It was therefore not possible to determine bacterial host identity, physical linkage to mobile genetic elements or mobilisation potential.


## 2026-07-17 to 2026-07-18 - Revision of the Discussion after the corrected analyses

### Main change

The Discussion was rewritten to reflect the farm-adjusted beta-diversity results and the paired alpha-diversity analysis.

The revised interpretation distinguished consistently between:

- relative and absolute abundance;
- association and causation;
- directional coefficients and statistically significant associations;
- visual separation in an ordination and a farm-adjusted statistical effect.

### Structure

The Discussion was organised around the following argument:

1. Healthy and sick corrals shared a similar broad class-level resistome.
2. The unadjusted ordinations showed partial separation, but this did not persist after farm was included in the models.
3. Alpha diversity did not differ consistently between corral types.
4. No individual resistance category remained significantly associated with corral type after correction.
5. Clinically relevant low-abundance ARG families were present in both corral types but could not be interpreted as evidence of transmission or mobilisation.
6. The cross-sectional and unbalanced study design limited causal and farm-independent interpretation.

### Outcome

The revised Discussion no longer treated the original unrestricted PERMANOVA or directional class-level coefficients as confirmed corral-type effects. Farm-level heterogeneity and the limits of the available sampling design were incorporated throughout the interpretation.


## 2026-07-18 to 2026-07-19 - Supervisor review and final language revision

### Supervisor assessment

The supervisor considered the revised Discussion substantially improved. He specifically noted that the distinctions between relative and absolute abundance, association and causation, and directional and significant findings were applied consistently.

He also approved the explanation that the proportion of variation attributed to farm in the sequential PERMANOVA depended on term order and could not be interpreted causally. The inclusion of PERMDISP and the transparent reporting of multiple-testing correction were also identified as strengths.

### Remaining revisions

The remaining comments concerned writing and presentation rather than the analytical framework. These included:

- removing repeated hedging within the same sentence;
- standardising the use and hyphenation of terms relating to resistance classes;
- replacing vague ordination language such as “appeared to separate”;
- varying sentence openings when discussing previous studies;
- defining abbreviations at first use;
- standardising statistical formatting;
- splitting several long sentences.

### Changes made

I edited the Discussion to remove duplicated qualifications while retaining appropriate scientific caution. Terminology and hyphenation were reviewed across all sections, vague ordination descriptions were replaced with more direct language, and long statistical sentences were divided where necessary.

The first mentions of abbreviations and ARG-family names were checked for consistency. Statistical notation, including R², F, p and adjusted p-values, was also reviewed.

### Reflection

The supervisor feedback indicated that the scientific interpretation was now consistent and appropriately cautious. The final stage of revision therefore focused on improving readability and journal-style presentation rather than changing the conclusions.

### Current status

The Discussion has been revised in response to both the statistical reassessment and supervisor feedback. The next stage is to integrate the final Results figures, complete the remaining dissertation sections and carry out a full consistency and formatting check before submission.