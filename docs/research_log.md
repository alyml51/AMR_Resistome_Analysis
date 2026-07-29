# Research Log

This research log records the main work I completed during the project, including data organisation, analysis, troubleshooting, supervisor feedback and preparation of the GitHub repository. I organised the entries by date and project stage. The scripts, figures and documentation that can be shared are available in the repository, while the unpublished data and metadata are not included.

## 2026-05-10 - Initial data organisation

### Objective

To organise the AMR feature reports and study metadata before starting the analysis.

### Work completed

I reviewed the available files and created a project structure for scripts, data, figures, results, references and documentation. The input consisted of one TELCoMB AMR feature report per sample and a study-design workbook containing sample, farm and corral information.

### Outcome

The project inputs and outputs were separated into consistent folders. The next step was to understand the study metadata and determine how the individual feature reports should be combined.

## 2026-05-13 - Understanding the study metadata

### Objective

To understand the relationship between samples, farms and corrals.

### Problem

The meanings of `sample_name`, `farm_id`, `corral_id` and `corral_type` were initially unclear. Farm identifiers such as ARG03 were also easy to confuse with antimicrobial resistance gene identifiers.

### Resolution

I compared the study-design workbook with the sample feature reports. I confirmed that C015-type identifiers were sample IDs, ARG03-type identifiers were farm IDs, and `corral_type` described whether a sample came from a healthy or sick corral.

### Outcome

I confirmed that the study contained repeated sampling units at the farm level and that this structure would need to be considered in later statistical analyses.

## 2026-05-19 - GitHub repository setup and analytical guidance

### Objective

To establish version control and document the sources used to develop the analytical workflow.

### Work completed

I created the GitHub repository and added folders for scripts, figures and project documentation, together with `.gitignore` and `.gitattributes`.

### Data-management issue

I initially needed to confirm which project materials could be stored publicly. The TELCoMB feature reports and study metadata form part of an unpublished project dataset and were therefore kept outside the public repository.

### Supervisor guidance

Dr Adam Blanchard recommended using a microbiome ecology framework and provided links to the `phyloseq` and `vegan` documentation and to resources explaining alpha-diversity metrics and Hill numbers. He also recommended considering Bray-Curtis dissimilarity, CLR/Aitchison analysis, PCoA, PERMANOVA and MaAsLin2.

### Code provenance

I developed the project-specific R workflow for this dissertation using documented functions from the recommended resources and the R packages cited in the dissertation. I used the recommended methods as a starting point, then developed and adjusted the data-processing, metadata, class-grouping, modelling and plotting steps for this dataset.

### Outcome

The repository was established as a record of the analysis code and permitted documentation. Restricted input data were retained locally.

## 2026-05-25 to 2026-05-29 - Building the data-merge pipeline

### Objective

To combine the individual TELCoMB AMR feature reports and study metadata into one analysis-ready table.

### Approach

I created `01_merge_data.R` to:

- identify all sample-level AMR feature reports;
- derive sample names from the filenames;
- separate the `Statistics` field into feature and value fields;
- separate resistance annotations into gene ID, type, class and description;
- extract the feature-level read count;
- combine the individual sample tables;
- join the study metadata by sample name.

### Problems

The input format contained several annotation components within one pipe-delimited field. The metadata workbook also contained repeated rows for some sample names.

### Resolution

I converted the feature reports into long format, with each row representing one resistance annotation within one sample. Before joining the metadata, I retained one metadata record per sample name so that repeated metadata rows did not duplicate AMR observations.

### Validation

I checked:

- the number and names of the imported sample files;
- whether abundance extraction introduced missing values;
- whether farm and corral metadata joined correctly;
- whether any sample lacked the required metadata;
- whether the final processed table contained the expected farm samples and pristine-soil control.

### Outcome

The merged table was saved locally as `data/resistance_split_processed.csv` for use by the downstream scripts.

## 2026-06-02 to 2026-06-03 - Resistance-class grouping and exploratory analysis

### Question

How should the detailed resistance annotations be grouped so that the composition analysis remained readable and biologically interpretable?

### Investigation

The original feature reports contained 49 detailed resistance classes. A composition plot using all detailed classes was fragmented and difficult to interpret. I compared alternative grouping schemes and considered whether metal and biocide resistance should be combined or retained separately.

### Decision

I grouped the detailed annotations into 13 broader resistance-class groups:

- Aminoglycosides;
- Beta-lactams;
- Biocide resistance;
- Fluoroquinolones;
- Glycopeptides;
- Metal resistance;
- macrolide-lincosamide-streptogramin resistance (MLS);
- Multi-drug resistance;
- Other;
- Phenicol;
- Rifampin;
- Sulfonamides/Trimethoprim;
- Tetracyclines.

Major antimicrobial classes were retained separately. Metal and biocide resistance were also retained as separate groups. Remaining low-abundance or heterogeneous categories were assigned to `Other`.

### Rationale

Grouping the original 49 classes into 13 made the composition plot easier to read while retaining the main resistance categories. I then used the same 13 groups in the later analyses so that the results were directly comparable.

### Initial ordination decision

I first explored PCA, but changed to PCoA when the main beta-diversity analysis was defined using a dissimilarity matrix. This matched the ecological framework recommended by the supervisor.

### Outcome

The 13 resistance-class groups became the main class-level input for all downstream analyses.

## 2026-06-05 - First resistance-class composition figure

### Objective

To visualise the relative composition of resistance classes in individual farm samples.

### Approach

Feature-level read counts were summed by sample and resistance-class group. The grouped counts were divided by the within-sample total to obtain relative abundance, and a stacked bar plot was produced.

### Problem

The first version had a crowded legend, unclear labels and difficult-to-read sample names.

### Resolution

I improved the class labels and colour palette, ordered samples by farm and corral type, separated healthy and sick samples into facets, and exported the figure in PDF and PNG formats.

### Initial observation

The relative composition of resistance classes varied among samples. MLS, aminoglycoside and tetracycline resistance contributed substantially to many profiles, while several lower-abundance groups showed more sample-specific patterns.

### Outcome

The revised stacked bar plot became the basis of dissertation Figure 1.

## 2026-06-07 to 2026-06-09 - Sample selection and Bray-Curtis PCoA development

### Objective

To define the analysis set and visualise between-sample differences in the relative composition of resistance classes.

### Data selection

The processed dataset contained 33 farm samples and one pristine-soil control. Because the research question concerned differences between farm corrals, the pristine-soil control was excluded from comparisons between corral types.

### Corral-type decision

One sick-corral label was recorded as S1. After discussion with the supervisor, S1 was combined with S because both represented sick corrals and a one-sample category would not support a separate comparison.

### Approach

Bray-Curtis dissimilarities were calculated from sample-level relative abundances of the 13 resistance-class groups. PCoA was then used to visualise the relationships among the 33 farm samples.

### Figure decision

The first PCoA included sample and farm labels and was visually crowded. Following supervisor feedback, I removed the individual labels and used colour to distinguish healthy and sick corrals.

### Reflection

The unadjusted ordination showed partial separation between corral types, but visual separation alone could not establish a statistically supported group effect.

## 2026-06-09 - Initial alpha-diversity analysis

### Objective

To compare within-sample resistance-class diversity between healthy and sick corrals.

### Initial approach

I calculated Shannon and inverse Simpson diversity and displayed them in separate boxplots.

### Limitation

The indices were expressed on different mathematical scales and were less intuitive to compare directly.

### Supervisor guidance

Dr Adam Blanchard recommended using Hill numbers because q = 0, q = 1 and q = 2 can be interpreted as effective numbers of resistance classes within one framework.

### Decision

I replaced the original presentation with Hill numbers:

- q = 0 for observed class richness;
- q = 1 for exponential Shannon diversity;
- q = 2 for inverse Simpson diversity.

### Outcome

The alpha-diversity workflow was revised to use Hill numbers consistently.

## 2026-06-18 - Figure optimisation

### Objective

To improve the clarity and consistency of the exploratory figures before formal statistical testing.

### Changes

I:

- separated healthy and sick samples in the composition plot;
- removed unnecessary labels from the PCoA;
- standardised the healthy and sick colour scheme;
- improved axis text, legend text and figure dimensions;
- retained PDF outputs for the dissertation and PNG outputs for checking and sharing.

### Outcome

The figures were clearer and provided a consistent basis for the subsequent Results section.

## 2026-06-21 - Initial Bray-Curtis PERMANOVA and PERMDISP

### Objective

To test whether the relative composition of resistance classes differed between healthy and sick corrals in the full sample set.

### Approach

I applied an unrestricted PERMANOVA to the Bray-Curtis distance matrix with corral type as the explanatory variable. I also used PERMDISP to examine whether group dispersion differed.

### Initial result

The unrestricted model suggested an association between corral type and Bray-Curtis composition. At this stage, the model had not yet accounted fully for the farm-level sampling structure.

### Interpretation at this stage

Because this model had not accounted for farm, I treated the result as preliminary and checked it again using restricted and farm-adjusted analyses. Farm identity was a possible source of confounding because only seven farms contained both healthy and sick samples.

### Outcome

The unrestricted analysis was retained as a description of the overall sample pattern, with farm-adjusted checks planned before final interpretation.

## 2026-06-22 to 2026-06-23 - Hill-number analysis and multiple-testing correction

### Objective

To compare resistance-class richness and effective diversity between corral types.

### Approach

Hill q = 0, q = 1 and q = 2 were calculated from the sample-by-class abundance matrix. Healthy and sick samples were compared using two-sided Wilcoxon rank-sum tests. Benjamini-Hochberg correction was applied across the three tests.

### Results

The median q = 0 value was 13 in both groups. The unadjusted p-values were 0.170 for q = 0, 0.046 for q = 1 and 0.025 for q = 2. After Benjamini-Hochberg correction, the adjusted p-values were 0.170, 0.069 and 0.069, respectively.

### Interpretation

Effective diversity was directionally higher in the sick-corral group for q = 1 and q = 2, but none of the three comparisons remained statistically significant after correction.

### Outcome

Both unadjusted and adjusted p-values were retained for transparent reporting, with the adjusted results used for the final statistical conclusion.

## 2026-06-23 to 2026-06-24 - MaAsLin2 class-level association analysis

### Objective

To test whether individual resistance-class groups were associated with corral type while considering farm-level structure.

### Approach

I used MaAsLin2 with corral type as a fixed effect, farm ID as a random effect and healthy corrals as the reference category. Total-sum scaling and log transformation were applied within MaAsLin2. The resulting coefficients were displayed in a coefficient plot.

### Results

No resistance-class group remained statistically significant after Benjamini-Hochberg correction. Metal and tetracycline resistance had the largest positive coefficients, while aminoglycoside and MLS resistance had negative coefficients.

### Interpretation

The coefficients described the direction of the fitted associations but did not provide evidence of statistically supported differences between corral types.

### Supervisor feedback

The supervisor considered the coefficient plot clear and suitable for the dissertation.

### Outcome

The coefficient plot became dissertation Figure 4.

## 2026-06-24 - Decision to add CLR/Aitchison analysis

### Supervisor guidance

The supervisor recommended adding a CLR-based analysis because the resistance-class counts were compositional.

### Analytical issue

CLR transformation cannot be applied directly to a matrix containing zeros. A zero-replacement step was therefore required before transformation.

### Decision

I retained the Bray-Curtis workflow and developed a separate CLR/Aitchison workflow. I kept both approaches because they represent the compositional data differently. I wanted to check whether they led to the same conclusion.

## 2026-06-25 to 2026-06-27 - CLR/Aitchison workflow implementation

### Objective

To implement a compositional beta-diversity analysis.

### Approach

I:

- created a sample-by-class count matrix;
- replaced zeros using the count zero multiplicative method;
- applied the centred log-ratio transformation;
- calculated Euclidean distances from the CLR-transformed matrix;
- treated these as Aitchison distances;
- performed PCoA.

### Troubleshooting

Some package functions had overlapping names. Explicit calls such as `dplyr::select()` were added to avoid namespace conflicts.

### Outcome

The CLR/Aitchison workflow ran successfully and produced an ordination that could be compared with the Bray-Curtis PCoA.

## 2026-06-28 to 2026-06-29 - Initial CLR/Aitchison statistical analysis

### Objective

To assess whether the unadjusted CLR/Aitchison analysis supported the same corral-type pattern as the Bray-Curtis analysis.

### Approach

An unrestricted PERMANOVA and a dispersion check were applied to the Aitchison distance matrix.

### Initial result

The unadjusted CLR/Aitchison PERMANOVA did not support a statistically significant corral-type effect. This differed from the initial unrestricted Bray-Curtis result.

### Interpretation

Because Bray-Curtis and CLR/Aitchison gave different unadjusted results, I did not treat the Bray-Curtis result as final. I kept both analyses and checked whether the pattern remained after accounting for farm.

## 2026-06-29 to 2026-07-01 - Figure standardisation and combination

### Objective

To standardise the dissertation figures and reduce the number of separate figures.

### Changes

I applied consistent colours, fonts, axis formatting and legends across all plots. The Bray-Curtis and CLR/Aitchison PCoA plots were combined as Figure 2, and the three Hill-number plots were combined as Figure 3 using `patchwork`.

### Outcome

The main analysis was represented by four figures at this stage:

1. resistance-class composition;
2. Bray-Curtis and CLR/Aitchison PCoA;
3. Hill-number alpha diversity;
4. MaAsLin2 coefficients.

## 2026-07-02 - Reproducibility check before writing

### Objective

To rerun the analysis workflow from a clean R session before drafting the dissertation.

### Procedure

I cleared the R environment and reran the scripts in order. I checked the processed table, sample counts, figures and exported statistical tables.

### Troubleshooting

Namespace conflicts involving `select()` were resolved by using `dplyr::select()` explicitly.

### Outcome

The workflow reproduced the figures and statistical outputs from the locally available restricted inputs. I used the outputs from this rerun for the first dissertation draft.

## 2026-07-03 to 2026-07-08 - First complete Results and Discussion draft

### Objective

To convert the completed analyses into a coherent dissertation draft.

### Work completed

I drafted the Methods and Results for:

- resistance-class processing and relative abundance;
- Bray-Curtis and CLR/Aitchison PCoA;
- PERMANOVA and PERMDISP;
- Hill-number alpha diversity;
- MaAsLin2 class-level associations.

I then drafted the Discussion around the question of whether healthy and sick corrals represented different resistome environments.

### Statistical cross-check

While reviewing the draft, I recognised that the unrestricted comparisons did not fully resolve the non-independence of samples from the same farm. The initial Results and Discussion therefore remained provisional.

### Preliminary clinical ARG exploration

I also began identifying clinically relevant low-abundance ARG families that were not visible in the broad resistance-class summaries. This exploratory step informed the later targeted analysis but was not yet treated as a final result.

### Outcome

I completed the first full draft, but it still needed revision after the farm-adjusted and targeted ARG analyses were finalised.

## 2026-07-09 to 2026-07-13 - Restructuring the Discussion using the literature

### Aim

To compare the findings directly with relevant cattle AMR and resistome studies rather than discuss each result in isolation.

### Literature review

I revisited the papers recommended by the supervisor. Garzon et al. (2025) provided a comparison with cattle pens of different functions. Bedford et al. (2024) provided context for antimicrobial use and management in Argentine beef production. Ali et al. (2025) showed that cattle AMR patterns can reflect multiple animal, farm and management factors.

### Revision strategy

The Discussion was reorganised around four questions:

1. Did overall resistome composition differ between corral types?
2. Did resistance-class diversity differ?
3. Did any individual resistance class explain the pattern?
4. What aspects of the study design limited interpretation?

### Outcome

The revised draft distinguished relative composition from absolute AMR burden and avoided interpreting directional estimates as confirmed group differences.

### Reflection

I realised that the Discussion needed to connect the different analyses instead of repeating the Results section by section.

## 2026-07-14 to 2026-07-15 - Reassessment of farm structure and sample independence

### Reason for reassessment

The 33 farm samples came from 26 farms, and only seven farms contained both healthy and sick corrals. The original unrestricted comparison could therefore reflect differences among farms as well as differences between corral types.

### Analytical changes

For the Bray-Curtis analysis, I:

- retained the unrestricted corral-type PERMANOVA;
- repeated the corral-type test with permutations restricted within farm;
- fitted a sequential PERMANOVA with farm entered before corral type.

For both Bray-Curtis and CLR/Aitchison distances, I fitted sequential farm-first models and repeated PERMDISP with permutations restricted within farm.

### Final beta-diversity results

In the unrestricted Bray-Curtis model, corral type explained 13.0% of the variation (R² = 0.130, F = 4.63, p = 0.012). With permutations restricted within farm, the p-value was 0.336.

In the unrestricted CLR/Aitchison model, corral type explained 4.9% of the variation (R² = 0.049, F = 1.58, p = 0.145).

In the sequential models, farm accounted for 67.8% of the Bray-Curtis variation and 71.0% of the CLR/Aitchison variation before corral type was entered. These percentages depend on term order and were treated as sequential model components rather than causal estimates.

After farm was entered, corral type explained a further 2.1% of the Bray-Curtis variation (R² = 0.021, F = 0.42, p = 0.859) and 2.8% of the CLR/Aitchison variation (R² = 0.028, F = 0.64, p = 0.719).

PERMDISP was not significant for either Bray-Curtis (F = 0.55, p = 0.688) or CLR/Aitchison distances (F = 0.23, p = 0.688).

### Interpretation

The unadjusted ordinations showed partial separation, but this did not persist as a statistically supported corral-type effect after farm-level structure was considered. After farm adjustment, both methods led to the same conclusion, so the result was not specific to one distance measure.

### Research decision

I revised the Results and Discussion to make the effect of farm-level variation clearer. The unrestricted Bray-Curtis result was retained as an unadjusted sample-level pattern and was not presented as evidence of an independent corral-type effect.

## 2026-07-15 to 2026-07-16 - Within-farm alpha-diversity comparisons

### Question

Were the higher q = 1 and q = 2 values in the full sick-corral group reproduced when healthy and sick samples were compared within the same farms?

### Approach

The seven farms represented by both corral types were analysed as paired observations. Two-sided Wilcoxon signed-rank tests were performed for q = 0, q = 1 and q = 2, followed by Benjamini-Hochberg correction.

### Results

The unadjusted paired p-values were 0.423, 0.673 and 0.673 for q = 0, q = 1 and q = 2. The adjusted p-value was 0.673 for all three Hill numbers. The direction of the healthy-sick difference was not consistent among the seven farms.

### Interpretation

The directional q = 1 and q = 2 pattern observed in the full dataset was not reproduced consistently within farms.

### Outcome

The paired analysis was added as a sensitivity analysis, and the final conclusion stated that alpha diversity did not differ consistently between corral types.

## 2026-07-16 to 2026-07-17 - Targeted analysis of clinically relevant low-abundance ARG families

### Motivation

The 13 resistance-class groups were suitable for overall composition analysis but could obscure individual low-abundance ARG families of clinical relevance.

### Selection and processing

I examined:

- the rifampin-associated families RPH and ARR;
- the carbapenem-associated metallo-β-lactamase families IMP, SPM and KHM.

ARG assignments marked as requiring SNP confirmation were excluded from this targeted analysis. Feature-level counts were summed by sample and ARG family, divided by the within-sample total AMR feature count and multiplied by 100.

### Visualisation

I created:

- a detection plot showing the percentage and number of samples with each family;
- a sample-level heatmap of relative abundance using a square-root-transformed colour scale.

These panels were combined as dissertation Figure 5.

### Results

RPH was detected in 18 samples across 16 farms, including 15 of 25 healthy-corral samples and three of eight sick-corral samples. IMP was detected in 17 samples across 17 farms, including 14 healthy and three sick samples. SPM was detected in five healthy and two sick samples. KHM was detected in seven healthy samples and ARR in two healthy samples; neither was detected in the eight sick samples.

Across positive detections, relative abundance ranged from 0.0004% to 0.1308% of total AMR abundance. No selected family exceeded 0.14% in any sample.

### Interpretation

The unequal group sizes meant that healthy-only detections were treated descriptively and were not interpreted as evidence of different prevalence. The selected families contributed very little to total AMR abundance. I therefore reported them as low-abundance detections rather than as major components of the resistome or confirmed differences between corral types.

### Limitation

Individual low-abundance assignments were not independently validated at read level in this secondary analysis. The available analysis also did not establish gene expression, bacterial host identity or horizontal-transfer potential.

## 2026-07-17 to 2026-07-18 - Revision after the corrected analyses

### Main change

The Results and Discussion were rewritten to reflect the farm-adjusted beta-diversity results, paired alpha-diversity analysis and targeted clinical ARG analysis.

### Revised argument

The final Discussion was organised around the following interpretation:

1. Healthy and sick corrals shared the main resistance-class background.
2. The unadjusted ordinations showed partial separation that did not persist after farm was considered.
3. Alpha diversity did not differ consistently between corral types.
4. No individual resistance class remained significantly associated with corral type after correction.
5. Selected clinically relevant ARG families occurred at low relative abundance and were not confined to sick corrals.
6. The cross-sectional, unbalanced sampling design limited causal and farm-independent interpretation.

### Outcome

I removed wording that treated the results as confirmed differences between corral types. The revised text separated directional patterns from statistically significant results and clearly identified the unadjusted analyses.

## 2026-07-18 to 2026-07-19 - Supervisor review and final Discussion revision

### Supervisor assessment

The supervisor considered the revised Discussion substantially improved. He noted that the distinctions between relative and absolute abundance, association and causation, and directional and statistically significant findings were applied consistently.

He specifically noted that the caveat about term order in the sequential PERMANOVA was appropriate and that the farm percentage should not be interpreted causally.

### Remaining revisions

The remaining comments concerned writing and presentation:

- remove repeated hedging within the same sentence;
- standardise resistance-class terminology and hyphenation;
- replace vague ordination wording with direct descriptions;
- vary sentence openings when comparing previous studies;
- define MLS and the TELSeq relationship at first use;
- standardise ARG-family names and statistical notation;
- divide several long statistical sentences.

### Changes made

I removed repeated hedging but kept the limitations that were necessary for interpreting the results. Terminology, hyphenation, abbreviation definitions and statistical formatting were checked across the manuscript. Vague ordination wording was replaced with direct descriptions of what was shown and whether the pattern persisted after farm adjustment.

### Outcome

After I addressed the remaining comments, the main conclusion did not change. The remaining work focused mainly on wording, formatting and submission preparation.

## 2026-07-20 to 2026-07-22 - Completion of Methods, Results, abstract and references

### Objective

To align every dissertation section with the final scripts and statistical outputs.

### Methods and Results checks

I checked that:

- the sample numbers were reported consistently as 33 samples from 26 farms;
- healthy and sick group sizes were reported as 25 and eight;
- the seven paired farms were described correctly;
- Bray-Curtis and CLR/Aitchison models were distinguished;
- unrestricted, restricted and sequential PERMANOVA results were not mixed;
- the final Hill-number p-values matched the exported tables;
- all MaAsLin2 findings were described as non-significant after correction;
- the targeted ARG analysis stated that SNP-confirmation-dependent assignments were excluded.

### Abstract

I revised the abstract to report the study design, the main adjusted results and the low-abundance ARG finding. I left out most secondary statistical values so that the main conclusion remained clear. The conclusion emphasised farm-level heterogeneity rather than a consistent healthy-sick corral effect.

### Title and keywords

The title was revised to use "antimicrobial resistance gene families" because RPH, ARR, IMP, SPM and KHM were analysed as families. The keyword list was shortened to retain only terms central to the study.

### References

I checked that every in-text citation appeared in the reference list and standardised the reference formatting. Package references for `vegan`, `zCompositions`, `compositions`, MaAsLin2, `patchwork`, `tidyverse` and R were retained where the corresponding methods were used.

### Outcome

After this check, the Methods, Results, abstract and references matched the final scripts and exported results.

## 2026-07-23 to 2026-07-26 - Submission-format and documentation checks

### Objective

To prepare the dissertation document for submission and check it against the course requirements.

### Work completed

I:

- added the required dissertation cover page;
- added the student declaration;
- checked the abstract and main-text word counts;
- confirmed that the five dissertation figures were within the maximum allowance of six figures;
- added page numbers;
- inserted the final GitHub repository URL in the reproducibility section;
- finalised the acknowledgements;
- checked heading, figure-caption and reference formatting.

### Data and supervision wording

The acknowledgements were revised to state that Dr Adam Blanchard provided the dataset and study metadata and gave guidance on the research question, analytical approach, interpretation, figures and Discussion. The contributions of the project team to sample collection, DNA extraction, target-enriched long-read sequencing and initial TELCoMB processing were also acknowledged.

### Outcome

The cover page, declaration and main dissertation sections were prepared for the final PDF export.

## 2026-07-27 - Making the scripts portable

### Objective

To remove computer-specific paths so that the scripts could be run from the repository root.

### Changes

Across scripts `01` to `09`, I:

- replaced the local absolute project path with `project_dir <- getwd()`;
- defined `data/`, `data/raw/`, `figures/`, `results/` and `scripts/` using relative paths;
- added directory creation where scripts generated figures or results;
- corrected output descriptions and filenames;
- removed a duplicated `source()` call from the Hill-number figure-combination script;
- removed an early duplicate zero-replacement call from the CLR script;
- checked that the scripts were intended to run in numerical order from the repository root.

### Troubleshooting

When the scripts were run while the R working directory was a general Documents folder, R searched for `data/` beneath that folder and reported that input or output paths did not exist. This was a working-directory and local folder-structure issue introduced during the portability check, not a change to the analytical methods or previously generated results.

Running the workflow requires the repository root to be the working directory and the authorised input files to be placed in `data/raw/`. Because those inputs are restricted, a fresh public clone cannot reproduce the numerical outputs without access from the project team.

### Outcome

The scripts now use the same relative folder structure and no longer contain the original `E:/` path. 

## 2026-07-28 - README, repository review and final status

### Objective

To finish the README and document the workflow without uploading the restricted project data.

### README contents

I added a root `README.md` describing:

- the research question and analysis overview;
- the required input file types and expected filenames;
- the 34 TELCoMB feature reports representing 33 farm samples and one pristine-soil control;
- the study-design metadata workbook;
- the restriction on public release of the input data and metadata;
- the repository structure;
- R and package versions;
- package installation requirements;
- the numerical order and purpose of scripts `01` to `09`;
- the expected figures and statistical outputs;
- the code provenance and supervisor-recommended methodological resources.

### Public data decision

Following the supervisor's instruction, the TELCoMB feature reports, metadata workbook and derived processed data were not uploaded to GitHub. The repository explains that authorised users must place the required inputs in `data/raw/` before running the workflow.

### Repository check

I checked that:

- no restricted raw data or metadata were staged for public upload;
- no local absolute paths remained in the analysis scripts;
- the README and research log matched the final workflow;
- the figure and script names used in the documentation matched the repository;
- the final analytical conclusions matched the dissertation.

### Final status

The analysis, figures, statistical results, README and research log are complete. I still need to commit and push the latest documentation changes, check that the README displays correctly on GitHub, and export the dissertation as a PDF. I will then check the final PDF for formatting problems, including the cover page, declaration, page numbers, figures, references and repository link.