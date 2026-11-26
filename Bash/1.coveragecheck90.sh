### Coverage check ###

output_dir="/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer"

# Count 90% voxels in mask
count_WholeBrain=$(fslstats $output_dir/Data/MNImask/MNI_mask_resampled1p5.nii -V | awk '{print $1}') 
WholeBrain=$(bc -l <<< "scale=5; $count_WholeBrain * 0.9") 
echo $WholeBrain

# Coverage 90%
less_than=0;
more_than=0;
for i in $(cat "$output_dir/Input/ABIDE_all_subs.txt"); do
  for img in \
    $output_dir/Input/ABIDE_*/${i}/mri/mwp1anat.nii \
    $output_dir/Input/ABIDE_*/${i}/mri/mwp1mprage.nii
  do
    [ -e "$img" ] || continue
    # How many voxels inside the MNI mask are non-zero in this subject?
    count=$(fslstats "$img" -k "$output_dir/Data/MNImask/MNI_mask_resampled1p5.nii" -V | awk '{print $1}') 
    echo $count
    
    # Calculate percentage coverage: how close is participant to the 90% threshold
    perc=$(echo "scale=3; $count / $WholeBrain" | bc) 
    echo $perc
    
    # Compare floating-point values using bc
    if (( $(echo "$count >= $WholeBrain" | bc -l) )); then #more than 90% coverage
        echo "$i has more than 90% coverage"
        more_than=$((more_than + 1))	
    else
        echo "$i has less than 90% coverage" #less than 90% coverage
        less_than=$((less_than + 1))
    fi

 done
done > $output_dir/Data/VBM/coverage_all_90_WholeBrain.txt

echo "Subjects with less than 90% coverage are: $less_than" >> $output_dir/Data/VBM/coverage_all_90_WholeBrain.txt
echo "Subjects with more than 90% coverage are: $more_than" >> $output_dir/Data/VBM/coverage_all_90_WholeBrain.txt