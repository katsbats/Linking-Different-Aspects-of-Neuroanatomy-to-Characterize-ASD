#!/opt/homebrew/bin/bash

# requires FSL and AFNI
#### Definition of directories #####
dir_vbm=/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Output/Flica_Output/ABIDE/iterations1500/FSL_format/150ica_secondfilter/VBM_R
dir_jd="/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Output/Flica_Output/ABIDE/iterations1500/FSL_format/150ica_secondfilter/JD_R"
dir_pa=/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Output/Flica_Output/ABIDE/iterations1500/FSL_format/150ica_secondfilter
dir_ct=/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Output/Flica_Output/ABIDE/iterations1500/FSL_format/150ica_secondfilter

dir_hoa=/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/HOA

dir_vbm="/Volumes/g_psyplafor_methlab\$/Students/Katharina_Bremer/Output/Flica_Output/ABIDE/iterations1500/FSL_format/150ica_secondfilter/VBM_R"
dir_hoa="/Volumes/g_psyplafor_methlab\$/Students/Katharina_Bremer/HOA"

#### Resample HOA atlas ####
export PATH=$PATH:/Users/katharinabremer/abin

dir_vbm="/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Output/Flica_Output/ABIDE/iterations1500/FSL_format/150ica_secondfilter/VBM_R"
dir_jd="/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Output/Flica_Output/ABIDE/iterations1500/FSL_format/150ica_secondfilter/JD_R"
dir_hoa="/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/HOA"

# Resample HOA cortical to match IC maps (4mm)
3dresample -master "${dir_vbm}/vol0036_pos_thr95.nii.gz" \
           -prefix "${dir_hoa}/HarvardOxford-cort-maxprob-thr25_4mm_YCG.nii.gz" \
           -inset "${dir_hoa}/HarvardOxford-cort-maxprob-thr25-2mm_YCG.nii"

3dresample -master "${dir_vbm}/vol0036_pos_thr95.nii.gz" \
           -prefix "${dir_hoa}/HarvardOxford-sub-maxprob-thr25_4mm_YCG.nii.gz" \
           -inset "${dir_hoa}/HarvardOxford-sub-maxprob-thr25-2mm_YCG.nii"


#### Get subregions of atlases #### 
# HOA atlas
# Defining cortical YCG indices
cort_indices=(10 11 20 21 30 31 40 41 50 51 60 61 70 71 80 81 90 91 100 101 110 111 120 121 130 131 140 141 150 151 160 161 170 171 180 181 190 191 200 201 210 211 220 221 230 231 240 241 250 251 260 261 270 271 280 281 290 291 300 301 310 311 320 321 330 331 340 341 350 351 360 361 370 371 380 381 390 391 400 401 410 411 420 421 430 431 440 441 450 451 460 461 470 471 480 481)

# Defining subcortical YCG indices
sub_indices=(1016 1116 2010 2049 3011 3050 4012 4051 5013 5052 6017 6053 7018 7054 8026 8058)

# Extract cortical subregions 
# For each cortical region, keep only voxels whose label equals i and create binary values = binary mask per region 
for i in "${cort_indices[@]}"; do 
    fslmaths ${dir_hoa}/HarvardOxford-cort-maxprob-thr25_4mm_YCG.nii.gz \
             -thr $i -uthr $i -bin \
             ${dir_hoa}/HOC_region_${i}.nii.gz
done

# Extract subcortical subregions
# For each subcortical region, keep only voxels whose label equals i and create binary values = binary mask per region 
for i in "${sub_indices[@]}"; do
    fslmaths ${dir_hoa}/HarvardOxford-sub-maxprob-thr25_4mm_YCG.nii.gz \
             -thr $i -uthr $i -bin \
             ${dir_hoa}/HOS_region_${i}.nii.gz
done


#### Compute overlap between HOA and spatial maps ####
export PATH=$PATH:/Users/katharinabremer/abin   

dir_vbm="/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Output/Flica_Output/ABIDE/iterations1500/FSL_format/150ica_secondfilter/VBM_R"
dir_jd="/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Output/Flica_Output/ABIDE/iterations1500/FSL_format/150ica_secondfilter/JD_R"
dir_hoa="/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/HOA"

cort_indices=(10 11 20 21 30 31 40 41 50 51 60 61 70 71 80 81 90 91 100 101 110 111 120 121 130 131 140 141 150 151 160 161 170 171 180 181 190 191 200 201 210 211 220 221 230 231 240 241 250 251 260 261 270 271 280 281 290 291 300 301 310 311 320 321 330 331 340 341 350 351 360 361 370 371 380 381 390 391 400 401 410 411 420 421 430 431 440 441 450 451 460 461 470 471 480 481)
sub_indices=(1016 1116 2010 2049 3011 3050 4012 4051 5013 5052 6017 6053 7018 7054 8026 8058)

modalities=("jd" "vbm")
ICs=("36") #because it start with 0 so IC36 is our IC37
values=("pos" "neg")


for modality in "${modalities[@]}"; do
# Choose the folder 
  if [ "$modality" == "vbm" ]; then
    dir="${dir_vbm}"
  elif [ "$modality" == "jd" ]; then
    dir="${dir_jd}"
  fi

# multiply threshold IC maps with atlas mask -> keeps regions within that mask
  for ic in "${ICs[@]}"; do
    for val in "${values[@]}"; do
    #cortical
      for i in "${cort_indices[@]}"; do
        fslmaths "${dir}/vol00${ic}_${val}_thr95.nii.gz" \
                 -mul "${dir_hoa}/HOC_region_${i}.nii.gz" \
                 "${dir}/vol00${ic}_${val}_HOC_${i}_thr95.nii.gz"
      done
      #subcortical
      for i in "${sub_indices[@]}"; do
        fslmaths "${dir}/vol00${ic}_${val}_thr95.nii.gz" \
                 -mul "${dir_hoa}/HOS_region_${i}.nii.gz" \
                 "${dir}/vol00${ic}_${val}_HOS_${i}_thr95.nii.gz"
      done
    done
  done
done

# Make sure we are starting with empty output files 
rm -f "${dir_vbm}/Overlap_percentages.txt" "${dir_jd}/Overlap_percentages.txt"

##### compute percentage overlap IC37 ####
# Overlap (%) = voxels of the IC map inside region j / all voxels of the IC map * 100

# Assign regions
declare -A regions
regions=(
  ["R_HOC"]="11 21 31 41 51 61 71 81 91 101 111 121 131 141 151 161 171 181 191 201 211 221 231 241 251 261 271 281 291 301 311 321 331 341 351 361 371 381 391 401 411 421 431 441 451 461 471 481"
  ["L_HOC"]="10 20 30 40 50 60 70 80 90 100 110 120 130 140 150 160 170 180 190 200 210 220 230 240 250 260 270 280 290 300 310 320 330 340 350 360 370 380 390 400 410 420 430 440 450 460 470 480"
  ["R_HOS"]="1116 2049 3050 4051 5052 6053 7054 8058"
  ["L_HOS"]="1016 2010 3011 4012 5013 6017 7018 8026"
)


for modality in "${modalities[@]}"; do
# Choose folder
  if [ "$modality" == "vbm" ]; then
    dir=${dir_vbm}
  elif [ "$modality" == "jd" ]; then
    dir=${dir_jd}
  fi

# For all IC voxels within region j (from the previous step)
  for ic in "${ICs[@]}"; do
    for val in "${values[@]}"; do

# Cortical 
      for hemisphere in R L; do
        for j in ${regions["${hemisphere}_HOC"]}; do
        # Binary map from before
          file=${dir}/vol00${ic}_${val}_HOC_${j}_thr95.nii.gz 
          if [ ! -e "${file}" ]; then
            echo "${j} ${modality} IC${ic} ${val} HOC File does not exist"
          else
            # Number of non-zero voxels of the IC map inside region j
            Overlap_with_atlas=$(fslstats ${file} -V | awk '{print $1}')
            # Number of non-zero voxels in the whole thresholded IC map (so that we can calclate percentage)
            whole_region=$(fslstats ${dir}/vol00${ic}_${val}_thr95.nii.gz -V | awk '{print $1}')
            # Percentage of the IC map that falls within region j
            Overlap_percentage=$(bc -l <<< "scale=5; $Overlap_with_atlas / $whole_region * 100")
            echo "${j} = IC${ic} = ${val} = ${modality} = ${hemisphere} = HOC = $Overlap_percentage" >> ${dir}/Overlap_percentages.txt
          fi
        done

# Subcortical
        for j in ${regions["${hemisphere}_HOS"]}; do
          file=${dir}/vol00${ic}_${val}_HOS_${j}_thr95.nii.gz
          if [ ! -e "${file}" ]; then
            echo "${j} ${modality} IC${ic} ${val} HOS File does not exist"
          else
            Overlap_with_atlas=$(fslstats ${file} -V | awk '{print $1}')
            whole_region=$(fslstats ${dir}/vol00${ic}_${val}_thr95.nii.gz -V | awk '{print $1}')
            Overlap_percentage=$(bc -l <<< "scale=5; $Overlap_with_atlas / $whole_region * 100")
            echo "${j} = IC${ic} = ${val} = ${modality} = ${hemisphere} = HOS = $Overlap_percentage" >> ${dir}/Overlap_percentages.txt
          fi
        done
      done

    done
  done
done

# The question that we are asking ourselves is: "Of the entire IC map, what percentage falls in this region?"



##### Now for IC1 #####
# The resampled atlas and the region masks (HOC_region_*, HOS_region_*) from the IC37 section are reused

modalities=("jd" "vbm")
ICs=("00")      # because it starts with 0, so IC00 is our IC1
values=("pos")  # only positive loadings (IC1 has almost no negative volumetric loadings)

for modality in "${modalities[@]}"; do
# Choose the folder
  if [ "$modality" == "vbm" ]; then
    dir="${dir_vbm}"
  elif [ "$modality" == "jd" ]; then
    dir="${dir_jd}"
  fi

# Multiply threshold IC maps with atlas mask -> keeps regions within that mask
  for ic in "${ICs[@]}"; do
    for val in "${values[@]}"; do
    # Cortical
      for i in "${cort_indices[@]}"; do
        fslmaths "${dir}/vol00${ic}_${val}_thr95.nii.gz" \
                 -mul "${dir_hoa}/HOC_region_${i}.nii.gz" \
                 "${dir}/vol00${ic}_${val}_HOC_${i}_thr95.nii.gz"
      done
      # Subcortical
      for i in "${sub_indices[@]}"; do
        fslmaths "${dir}/vol00${ic}_${val}_thr95.nii.gz" \
                 -mul "${dir_hoa}/HOS_region_${i}.nii.gz" \
                 "${dir}/vol00${ic}_${val}_HOS_${i}_thr95.nii.gz"
      done
    done
  done
done

# Make sure we are starting with empty output files
rm -f "${dir_vbm}/Overlap_percentages_IC1.txt" "${dir_jd}/Overlap_percentages_IC1.txt"

##### compute percentage overlap IC1 ####
# Overlap (%) = voxels of the IC map inside region j / all voxels of the IC map * 100

for modality in "${modalities[@]}"; do
# Choose folder
  if [ "$modality" == "vbm" ]; then
    dir=${dir_vbm}
  elif [ "$modality" == "jd" ]; then
    dir=${dir_jd}
  fi

# For all IC voxels within region j (from the previous step)
  for ic in "${ICs[@]}"; do
    for val in "${values[@]}"; do

# Cortical
      for hemisphere in R L; do
      # Regions were defined for IC37
        for j in ${regions["${hemisphere}_HOC"]}; do
        # Binary map from before
          file=${dir}/vol00${ic}_${val}_HOC_${j}_thr95.nii.gz
          if [ ! -e "${file}" ]; then
            echo "${j} ${modality} IC${ic} ${val} HOC File does not exist"
          else
            # Number of non-zero voxels of the IC map inside region j
            Overlap_with_atlas=$(fslstats ${file} -V | awk '{print $1}')
            # Number of non-zero voxels in the whole thresholded IC map (so that we can calculate percentage)
            whole_region=$(fslstats ${dir}/vol00${ic}_${val}_thr95.nii.gz -V | awk '{print $1}')
            # Percentage of the IC map that falls within region j
            Overlap_percentage=$(bc -l <<< "scale=5; $Overlap_with_atlas / $whole_region * 100")
            echo "${j} = IC${ic} = ${val} = ${modality} = ${hemisphere} = HOC = $Overlap_percentage" >> ${dir}/Overlap_percentages_IC1.txt
          fi
        done

# Subcortical
        for j in ${regions["${hemisphere}_HOS"]}; do
          file=${dir}/vol00${ic}_${val}_HOS_${j}_thr95.nii.gz
          if [ ! -e "${file}" ]; then
            echo "${j} ${modality} IC${ic} ${val} HOS File does not exist"
          else
            Overlap_with_atlas=$(fslstats ${file} -V | awk '{print $1}')
            whole_region=$(fslstats ${dir}/vol00${ic}_${val}_thr95.nii.gz -V | awk '{print $1}')
            Overlap_percentage=$(bc -l <<< "scale=5; $Overlap_with_atlas / $whole_region * 100")
            echo "${j} = IC${ic} = ${val} = ${modality} = ${hemisphere} = HOS = $Overlap_percentage" >> ${dir}/Overlap_percentages_IC1.txt
          fi
        done
      done

    done
  done
done
