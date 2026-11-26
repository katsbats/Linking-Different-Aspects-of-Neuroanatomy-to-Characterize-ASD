#!/bin/bash

### Threshold spatial maps VBM, JD of IC37 and IC1 ###

FLICA_DIR='/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Output/Flica_Output/ABIDE/iterations1500/FSL_format/150ica_secondfilter'
VBM_DIR="${FLICA_DIR}/VBM_R"
JD_DIR="${FLICA_DIR}/JD_R"
MNI_REF='/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Data/MNImask/MNI152_T1_0.5mm.nii.gz'
GM='/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Data/Groupmask/final_002/group_mask_VBM_MNI_masked_GM_s8_4mm02.nii.gz'

# Split 4D FLICA output into one 3D map per IC (niftiOut_mi1 = JD, niftiOut_mi2 = VBM)
mkdir -p "${VBM_DIR}" "${JD_DIR}"
cp "${FLICA_DIR}/niftiOut_mi2.nii.gz" "${VBM_DIR}/"
cp "${FLICA_DIR}/niftiOut_mi1.nii.gz" "${JD_DIR}/"
cd "${VBM_DIR}" && fslsplit niftiOut_mi2.nii.gz
cd "${JD_DIR}"  && fslsplit niftiOut_mi1.nii.gz


# Thresholding for the atlas overlap 
# Positive and negative loadings are thresholded separately at the 95th percentile of their non-zero voxels, at the original resolution (4 mm)
for DIR in "${VBM_DIR}" "${JD_DIR}"; do
    cd "${DIR}"
    for j in 00 36; do                     # IC1, IC37
        fslmaths vol00${j}.nii.gz -thr 0          vol00${j}_pos
        fslmaths vol00${j}.nii.gz -uthr 0 -mul -1 vol00${j}_neg

        for t in pos neg; do
            thresh_it=$(fslstats vol00${j}_${t}.nii.gz -P 95)
            echo "${DIR##*/} | IC vol00${j} | ${t}: threshold = ${thresh_it}"
            fslmaths vol00${j}_${t}.nii.gz -thr ${thresh_it} vol00${j}_${t}_thr95.nii.gz
        done
    done
done


#### Maps for visualisation only #####
# Within the grey-matter mask, each split is z-scored, resampled to 0.5 mm and then thresholded at the 95th percentile
for DIR in "${VBM_DIR}" "${JD_DIR}"; do
    cd "${DIR}"
    for j in 36; do
        for t in pos neg; do
            # z-score within the GM mask
            fslmaths vol00${j}_${t}.nii.gz -mas ${GM} -bin vol00${j}_${t}_mask.nii.gz
            mean_val=$(fslstats vol00${j}_${t}.nii.gz -k vol00${j}_${t}_mask.nii.gz -M)
            std_val=$(fslstats vol00${j}_${t}.nii.gz -k vol00${j}_${t}_mask.nii.gz -S)
            fslmaths vol00${j}_${t}.nii.gz -sub ${mean_val} -div ${std_val} \
                     -mas vol00${j}_${t}_mask.nii.gz vol00${j}_z_${t}.nii.gz

            # resample to 0.5 mm, then threshold at the 95th percentile
            flirt -applyisoxfm 0.5 -in vol00${j}_z_${t}.nii.gz -ref ${MNI_REF} \
                  -out vol00${j}_z_${t}_0.5mm.nii.gz
            thresh_it=$(fslstats vol00${j}_z_${t}_0.5mm.nii.gz -P 95)
            fslmaths vol00${j}_z_${t}_0.5mm.nii.gz -thr ${thresh_it} vol00${j}_z_${t}_0.5mm_thr95.nii.gz
        done
    done
done

# View
#fsleyes ${MNI_REF} ${VBM_DIR}/vol0036_z_pos_0.5mm_thr95.nii.gz ${VBM_DIR}/vol0036_z_neg_0.5mm_thr95.nii.gz
#fsleyes ${MNI_REF} ${JD_DIR}/vol0036_z_pos_0.5mm_thr95.nii.gz  ${JD_DIR}/vol0036_z_neg_0.5mm_thr95.nii.gz



### Threshold spatial maps CT, SA of IC37 and IC1 ###
# As FSL tools cannot read .mgh, mri_convert, python and fscalc are used instead

CT_DIR="${FLICA_DIR}/CT_R"
PA_DIR="${FLICA_DIR}/PA_R"

# Copy FLICA output (niftiOut_mi3 = CT, niftiOut_mi4 = surface area)
mkdir -p "${CT_DIR}" "${PA_DIR}"
for hemi in lh rh; do
    cp "${FLICA_DIR}/${hemi}_niftiOut_mi3.mgh" "${CT_DIR}/${hemi}_niftiOut.mgh"
    cp "${FLICA_DIR}/${hemi}_niftiOut_mi4.mgh" "${PA_DIR}/${hemi}_niftiOut.mgh"
done

for DIR in "${CT_DIR}" "${PA_DIR}"; do
    cd "${DIR}"

    # Split: get IC1 (frame 0) and IC37 (frame 36)
    for hemi in lh rh; do
        mri_convert ${hemi}_niftiOut.mgh --frame 0  ${hemi}_vol0000.mgh
        mri_convert ${hemi}_niftiOut.mgh --frame 36 ${hemi}_vol0036.mgh
    done

    # Separate positive and negative
    for hemi in lh rh; do
        for j in 0000 0036; do
            python3 -c " # have to use python here
import nibabel as nib
import numpy as np
img = nib.load('${hemi}_vol${j}.mgh')
d = img.get_fdata()
nib.save(nib.MGHImage(np.where(d > 0,  d, 0).astype(np.float32), img.affine, img.header), '${hemi}_vol${j}_pos.mgh') #keeps only pos
nib.save(nib.MGHImage(np.where(d < 0, -d, 0).astype(np.float32), img.affine, img.header), '${hemi}_vol${j}_neg.mgh') #keeps only neg
"
        done
    done

    # Threshold
    for hemi in lh rh; do
        for j in 0000 0036; do
            for t in pos neg; do
                ## calculate 95th percentile of the non-zero vertices (per hemisphere), stores the python code in the bash label thresh_it
                thresh_it=$(python3 -c " 
import nibabel as nib
import numpy as np
d = nib.load('${hemi}_vol${j}_${t}.mgh').get_fdata().flatten() #load pos and neg data
print(np.percentile(d[d > 0], 95))
")
                echo "${DIR##*/} ${hemi} ${j} ${t}: threshold = ${thresh_it}"
                ## threshold image (keep values >= threshold), if value is greater than threshhold -> keep, multiply with original mask
                ## we get thresholded values and everything else is 0
                fscalc ${hemi}_vol${j}_${t}.mgh gte ${thresh_it} mul ${hemi}_vol${j}_${t}.mgh \
                       --o ${hemi}_vol${j}_${t}_thr95.mgh
            done
        done
    done
done