#!/usr/bin/env python3

# SVM classification of autism vs. NAI from the most multimodal and most unimodal ICs, for 1 to 75 features
# this script needs to be run over the server
#
# CHANGE (permutation test): instead of permuting the diagnostic labels, the cross-validated
# scores of the multimodal and unimodal classifiers are pooled, shuffled and reassigned to the
# two classifiers (approach of Floris et al., 2025). This tests whether multimodal components
# classify better than unimodal ones, rather than whether the classifiers beat chance.

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

from sklearn.svm import SVC
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.metrics import roc_auc_score
from sklearn.model_selection import StratifiedKFold, cross_val_predict

# paths
PHENO_CSV = '/mnt/methlab-drive/methlab/Students/Katharina_Bremer/Scripts/R Studio/data/data_final/FSL_pheno_second_filter_cleaned.csv'
SUBJECT_COURSES_TXT = '/mnt/methlab-drive/methlab/Students/Katharina_Bremer/Output/Flica_Output/ABIDE/iterations1500/FSL_Format/150ica_secondfilter/subjectCoursesOut.txt'
MODALITY_CONTRIB_TXT = '/mnt/methlab-drive/methlab/Students/Katharina_Bremer/Output/Flica_Output/ABIDE/iterations1500/FSL_Format/150ica_secondfilter/Modality_contributions.txt'
OUT_CSV = '/mnt/methlab-drive/methlab/Students/Katharina_Bremer/Output/Plots/SVM_AUC_number_of_features_results_100scoreperm.csv'
OUT_PNG = '/mnt/methlab-drive/methlab/Students/Katharina_Bremer/Output/Plots/SVM_AUC_number_of_features_plot_100scoreperm.png'

N_SPLITS = 10
N_REPEATS = 100
N_PERM = 1000          # cheap now: no refitting inside the permutation loop
C_PARAM = 1.0
N_MODALITIES = 4
SEED_REF = 42
SEED_REPEATS = 0
SEED_PERM = 1

# labels
pheno = pd.read_csv(PHENO_CSV, encoding='latin-1')
pheno['SUB_ID'] = pheno['SUB_ID'].astype(int).astype(str)
pheno.set_index('SUB_ID', inplace=True)

y_raw = pheno['DX_GROUP'].to_numpy()
le = LabelEncoder()
y = le.fit_transform(y_raw)
print("Label encoding (0 -> {}, 1 -> {}); 1 is the positive class for AUC."
      .format(le.classes_[0], le.classes_[1]))
print(pd.Series(y).value_counts())

# subject courses
subject_courses = pd.read_csv(SUBJECT_COURSES_TXT, header=None, sep=' ').transpose().to_numpy()

assert subject_courses.shape[0] == len(y), (
    "Row-count mismatch between subject courses ({}) and phenotype ({})."
    .format(subject_courses.shape[0], len(y))
)

# modality contributions -> multimodality index
modality = pd.read_csv(MODALITY_CONTRIB_TXT, header=None, sep=' ').transpose().to_numpy()

assert modality.shape[1] == N_MODALITIES, (
    f"Expected {N_MODALITIES} modality columns, got {modality.shape[1]}. "
    "Check Modality_contributions.txt layout."
)

max_modality = modality.max(axis=1)
mmi = 1.0 - (N_MODALITIES / (N_MODALITIES - 1.0)) * (max_modality - 1.0 / N_MODALITIES)
order_mm = np.argsort(-mmi)   # most multimodal (evenly spread) first
order_uni = np.argsort(mmi)   # most unimodal (single-modality-dominated) first
n_components = len(mmi)

MAX_FEATURES = n_components // 2   # highest i where MM and Uni sets stay disjoint
print(f"Total components: {n_components} -> testing i = 1 to {MAX_FEATURES}")


def paired_pooled_scores(X_mm, X_uni, labels, seed):
    """Cross-validated decision scores for both feature sets on the same fold partition."""
    skf = StratifiedKFold(n_splits=N_SPLITS, shuffle=True, random_state=seed)
    pipe = make_pipeline(StandardScaler(), SVC(kernel='linear', C=C_PARAM))
    s_mm = cross_val_predict(pipe, X_mm, labels, cv=skf, method='decision_function')
    s_uni = cross_val_predict(pipe, X_uni, labels, cv=skf, method='decision_function')
    return s_mm, s_uni


def zscore(s):
    """Put both classifiers' scores on the same scale before pooling (AUC itself is unchanged)."""
    return (s - s.mean()) / s.std()


# main feature count analysis
results = []
perm_rng = np.random.RandomState(SEED_PERM)

for i in range(1, MAX_FEATURES + 1):
    mm_idx = order_mm[:i]
    uni_idx = order_uni[:i]
    print(f"----- {i} features -----")

    X_mm = subject_courses[:, mm_idx]
    X_uni = subject_courses[:, uni_idx]

    # AUCs across repeated fold partitions (means and percentile intervals)
    mm_aucs = np.empty(N_REPEATS)
    uni_aucs = np.empty(N_REPEATS)
    for r in range(N_REPEATS):
        s_mm_r, s_uni_r = paired_pooled_scores(X_mm, X_uni, y, SEED_REPEATS + r)
        mm_aucs[r] = roc_auc_score(y, s_mm_r)
        uni_aucs[r] = roc_auc_score(y, s_uni_r)
    diffs = mm_aucs - uni_aucs

    mm_mean, uni_mean = mm_aucs.mean(), uni_aucs.mean()
    mm_lo, mm_hi = np.percentile(mm_aucs, [2.5, 97.5])
    uni_lo, uni_hi = np.percentile(uni_aucs, [2.5, 97.5])
    diff_mean = diffs.mean()
    diff_lo, diff_hi = np.percentile(diffs, [2.5, 97.5])
    frac_mm_wins = float(np.mean(diffs > 0))

    # observed difference on the fixed reference partition
    s_mm, s_uni = paired_pooled_scores(X_mm, X_uni, y, SEED_REF)
    s_mm, s_uni = zscore(s_mm), zscore(s_uni)
    obs_mm, obs_uni = roc_auc_score(y, s_mm), roc_auc_score(y, s_uni)
    obs_diff = obs_mm - obs_uni

    # permutation test (Floris et al., 2025): pool both classifiers' scores,
    # shuffle, and reassign them to the two classifiers
    all_scores = np.concatenate((s_mm, s_uni))
    n = len(y)
    null_diffs = np.empty(N_PERM)
    for p in range(N_PERM):
        shuffled = perm_rng.permutation(all_scores)
        null_diffs[p] = roc_auc_score(y, shuffled[:n]) - roc_auc_score(y, shuffled[n:])
    p_value = (np.sum(null_diffs >= obs_diff) + 1) / (N_PERM + 1)   # one-sided: MM > Uni

    print(f"  MM AUC {mm_mean:.3f} [{mm_lo:.3f}, {mm_hi:.3f}] | "
          f"Uni AUC {uni_mean:.3f} [{uni_lo:.3f}, {uni_hi:.3f}]")
    print(f"  paired diff {diff_mean:.3f} [{diff_lo:.3f}, {diff_hi:.3f}] | "
          f"frac partitions MM>Uni {frac_mm_wins:.2f} | perm p {p_value:.4f}")

    results.append({
        'Number_of_features': i,
        'AUC_Multimodal': mm_mean,
        'AUC_Unimodal': uni_mean,
        'AUC_Multi_Lower': mm_lo, 'AUC_Multi_Upper': mm_hi,
        'AUC_Uni_Lower': uni_lo, 'AUC_Uni_Upper': uni_hi,
        'Diff_mean': diff_mean, 'Diff_Lower': diff_lo, 'Diff_Upper': diff_hi,
        'Frac_MM_wins': frac_mm_wins,
        'Observed_diff_refseed': obs_diff,
        'Perm_p_value': p_value,
    })

results_df = pd.DataFrame(results)
results_df.to_csv(OUT_CSV, index=False)
print(f"\nSaved results to {OUT_CSV}")

y_ticks = np.arange(0.30, 0.75 + 0.05, 0.05)
plt.figure(figsize=(8, 6))
plt.plot(results_df['Number_of_features'], results_df['AUC_Multimodal'], label='AUC Multimodal', marker='o')
plt.plot(results_df['Number_of_features'], results_df['AUC_Unimodal'], label='AUC Unimodal', marker='o')
plt.fill_between(results_df['Number_of_features'], results_df['AUC_Multi_Lower'], results_df['AUC_Multi_Upper'],
                 alpha=0.2, color='blue', label='CI Multimodal (across partitions)')
plt.fill_between(results_df['Number_of_features'], results_df['AUC_Uni_Lower'], results_df['AUC_Uni_Upper'],
                 alpha=0.2, color='orange', label='CI Unimodal (across partitions)')
plt.xlabel('Number of features (ranked by degree of modality dominance)', fontsize=13, fontweight='bold')
plt.ylabel('AUC', fontsize=16, fontweight='bold')
plt.xticks(fontsize=14, fontweight='bold')
plt.yticks(y_ticks, fontsize=14, fontweight='bold')
plt.legend(loc='upper center', bbox_to_anchor=(0.5, -0.15), fancybox=True, shadow=True, ncol=2, fontsize=12)
plt.grid(True)
plt.tight_layout()
plt.savefig(OUT_PNG, bbox_inches='tight')
plt.show()
plt.close()
print(f"Saved plot to {OUT_PNG}")