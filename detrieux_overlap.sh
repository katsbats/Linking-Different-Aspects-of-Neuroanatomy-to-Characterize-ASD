#!/bin/bash

## For surface area, I want to use Destrieux atlas  

#### definition of directories ####
# Note: "PA"/"area" = FreeSurfer white-surface area, not pial area

export SUBJECTS_DIR="/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Data"
dir_pa=/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Output/Flica_Output/ABIDE/iterations1500/FSL_format/150ica_secondfilter/PA_R
dir_ct=/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Output/Flica_Output/ABIDE/iterations1500/FSL_format/150ica_secondfilter/CT_R

dir_atlas=/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Data/fsaverage/label

modalities=("ct" "pa")
IC=("0036")
values=("pos" "neg")

#### Binarize the thresholded maps and get statistics per atlas region  #####

for modality in ct pa; do
# choose the folder 
  if [ "$modality" == "ct" ]; then dir="${dir_ct}"; fi
  if [ "$modality" == "pa" ]; then dir="${dir_pa}"; fi

  for hemi in lh rh; do
    for val in pos neg; do
      # binarize: any non-zero value becomes 1
      mri_binarize \
        --i "${dir}/${hemi}_vol0036_${val}_thr95.mgh" \
        --min 0.0001 \
        --o "${dir}/${hemi}_vol0036_${val}_thr95_bin.mgh"

      # run segstats on the binary map -> This gives us a stats file (with things like min, max, mean). We still need to create the overlap file now
      mri_segstats \
        --annot fsaverage ${hemi} aparc.a2009s \
        --i "${dir}/${hemi}_vol0036_${val}_thr95_bin.mgh" \
        --sum "${dir}/${hemi}_vol0036_${val}_thr95_bin_destrieux_stats.txt"
    done
  done
done

### Compute overlap ###
# Overlap percentage = suprathreshold vertices in region j / all suprathreshold vertices of the IC map (both hemispheres) * 100

# Make sure we are starting with empty output files
rm -f "${dir_ct}/Overlap_percentages_bin_surface.txt"   
rm -f "${dir_pa}/Overlap_percentages_bin_surface.txt"   

for modality in ct pa; do
  if [ "$modality" == "ct" ]; then dir="${dir_ct}"; fi
  if [ "$modality" == "pa" ]; then dir="${dir_pa}"; fi

  for val in pos neg; do
    # Total number of suprathreshold vertices in the whole IC map: sum of NVertices x Mean over all regions, for each hemisphere, then added together
    lh_total=$(grep -v "^#" "${dir}/lh_vol0036_${val}_thr95_bin_destrieux_stats.txt" | awk 'NR>1 {s+=$3*$6} END {printf "%.0f", s}')
    rh_total=$(grep -v "^#" "${dir}/rh_vol0036_${val}_thr95_bin_destrieux_stats.txt" | awk 'NR>1 {s+=$3*$6} END {printf "%.0f", s}')
    whole_region=$((lh_total + rh_total)) 

    # For each region with any overlap ($6 > 0): percentage of the IC map that falls in this region
    for hemi in lh rh; do
      grep -v "^#" "${dir}/${hemi}_vol0036_${val}_thr95_bin_destrieux_stats.txt" | awk -v t="$whole_region" -v v="$val" -v m="$modality" -v h="$hemi" 'NR>1 && $6>0 {
        Overlap_with_atlas = $3 * $6 
        Overlap_percentage = Overlap_with_atlas / t * 100
        printf "%s = IC36 = %s = %s = %s = %.5f\n", $5, v, m, h, Overlap_percentage
      }' >> "${dir}/Overlap_percentages_bin_surface.txt" #the overlap_with_atlas is also done directly with fslstats, but we cant use that here. Therefore we must do $3 (NVertices) x $6 (Mean). The difference is here we do it for one single region. "how much of the IC map falls in that region"
    done
  done
done


#### for IC1 (same procedure) ##### 
#### Binarize the thresholded maps and get statistics per atlas region  #####

for modality in ct pa; do
  if [ "$modality" == "ct" ]; then dir="${dir_ct}"; fi
  if [ "$modality" == "pa" ]; then dir="${dir_pa}"; fi

  for hemi in lh rh; do
    for val in pos neg; do
      # Binarize: any non-zero value becomes 1
      mri_binarize \
        --i "${dir}/${hemi}_vol0000_${val}_thr95.mgh" \
        --min 0.0001 \
        --o "${dir}/${hemi}_vol0000_${val}_thr95_bin.mgh"

      # Run segstats on the binary map
      mri_segstats \
        --annot fsaverage ${hemi} aparc.a2009s \
        --i "${dir}/${hemi}_vol0000_${val}_thr95_bin.mgh" \
        --sum "${dir}/${hemi}_vol0000_${val}_thr95_bin_destrieux_stats.txt"
    done
  done
done

# Make sure we are starting with empty files
rm -f "${dir_ct}/Overlap_percentages_bin_surface01.txt"
rm -f "${dir_pa}/Overlap_percentages_bin_surface01.txt"

### Overlap percentage ###
for modality in ct pa; do
  if [ "$modality" == "ct" ]; then dir="${dir_ct}"; fi
  if [ "$modality" == "pa" ]; then dir="${dir_pa}"; fi

  for val in pos neg; do
    # Total number of suprathreshold vertices in the whole IC map: sum of NVertices x Mean over all regions, for each hemisphere, then added together
    lh_total=$(grep -v "^#" "${dir}/lh_vol0000_${val}_thr95_bin_destrieux_stats.txt" | awk 'NR>1 {s+=$3*$6} END {printf "%.0f", s}')
    rh_total=$(grep -v "^#" "${dir}/rh_vol0000_${val}_thr95_bin_destrieux_stats.txt" | awk 'NR>1 {s+=$3*$6} END {printf "%.0f", s}')
    whole_region=$((lh_total + rh_total))

    # For each region with any overlap ($6 > 0): percentage of the IC map that falls in this region
    for hemi in lh rh; do
      grep -v "^#" "${dir}/${hemi}_vol0000_${val}_thr95_bin_destrieux_stats.txt" | awk -v t="$whole_region" -v v="$val" -v m="$modality" -v h="$hemi" 'NR>1 && $6>0 {
        Overlap_with_atlas = $3 * $6
        Overlap_percentage = Overlap_with_atlas / t * 100
        printf "%s = IC1 = %s = %s = %s = %.5f\n", $5, v, m, h, Overlap_percentage
      }' >> "${dir}/Overlap_percentages_bin_surface01.txt"
    done
  done
done