# Linking-Different-Aspects-of-Neuroanatomy-to-Characterize-ASD
This repository contains all the scripts and data necessary to reproduce the results of my master's thesis in Psychology at the University of Zurich.

# Linking-Neuroanatomy-of-ASD
This repository contains all the scripts and data necessary to reproduce the results of my master's thesis in Psychology at the University of Zurich. 

### Data
- The datasets are available from the Autism Brain Imaging Data Exchange: [ABIDE](http://fcon_1000.projects.nitrc.org/indi/abide/)
- Excel files of the manual visual subject exclusions and of the data for the wordcloud are included. All the other data can be reproduced through the scripts. 

### Figures and tables
- Some of the final figures in the thesis were created manually with Affinity Designer, the rest are created with the scripts provided here.
- Final tables in the thesis were adapted manually (APA7 formatting) from the .csv  files, which are created through the scripts provided here.

### Required Toolboxes 
- [LICA](https://github.com/allera/Llera_elife_2019_1)
- [Imputation](https://github.com/allera/Imputation)
- [PLS](https://github.com/MLNL/cca_pls_toolkit/tree/v1.0.0)
- [CAT](https://neuro-jena.github.io/cat/#download) (the version 12.9, r2577 was used in this thesis) and [SPM](https://www.fil.ion.ucl.ac.uk/spm/docs/installation/) (the version 25.01.02 was used in this thesis)
- [Freesurfer](https://fsl.fmrib.ox.ac.uk/fsl/docs/install/index.html)


# To exactly reproduce the results, run the scripts in the following order:
## Preprocessing
Freesurfer: recon-all, was done by Jente Meier previously and I was able to use her output. Two datasets, which were missing, were run by myself.
1. RunCAT12ABIDE1.m, RunCAT12ABIDE2.m (requires CAT12 and SPM)
2. MNImask.txt
3. smooth8SPMABIDE.m (requires SPM)
4. fsaverage.sh (requires Freesurfer) 

## Quality Control and Sample Selection
5. coveragecheck90.sh
6. extractingIQRABIDE1.m, extractingIQRABIDE2.m
7. combine_asegtables.Rmd
8. exclusion_of_subs.Rmd -> gives us ABIDEu30_final_subs.txt

## LICA
9. VBM_preprocessing.sh, JD_preprocessing.sh, mri_concat.sh ("wholesample" section)
10. flica.sh (whole-sample run, requires FLICA toolbox)
11. subject_dominance.Rmd (and the Stanford exclusion)
-> Steps 10 and 11 again, using the "first filter" sections.
12. subject_dominance.Rmd (second round)
-> Steps 10 and 11 again, using the "second filter" sections. This gives the main analysis, plus the 140 and 160 runs.

## Phenotypic Data
13. characterization_sample.Rmd 
14. imputation.Rmd (preparation) → run_imputation.sh (requires Imputation toolbox) → imputation.Rmd (before/after comparison).

## Analyses
15. multimodal_IC_plot.Rmd: MMI and modality contributions.
16. robustness_of_model_order.Rmd
17. noise_analysis.Rmd
18. statistical_analysis.Rmd: ANCOVA and the symptom associations.
19. preparing_data_PLS.m → my_pls_analysis.m (requires PLS toolbox) → pls_holdout.m (requires PLS toolbox)
20. unimodal_flica.sh (requires FLICA toolbox) and unimodal_multimodal.Rmd 
21. thresholding_for_overlap.sh → HOA_overlap.sh and detrieux_overlap.sh → Spatialmaps.Rmd
22. SVM_threshold.py and SVM_nr_features.py
23. supplementary_analyses.Rmd: the IQ and TBV controls.
### Plots
- wordcloud.Rmd
- CorrelationMatrix.Rmd
