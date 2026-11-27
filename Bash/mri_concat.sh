### Convert SA and CT into 3d surface files ###
# requires FreeSurfer
output_dir="/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer"

# Extract all files: lh area 
mkdir -p $output_dir/Data/OutputFreeSurfer/mergedFS/under30
for i in `cat $output_dir/Input/ABIDEu30_final_subs.txt`; do 
ls  $output_dir/Data/OutputFreeSurfer/fsaverageABIDE*/${i}/lh.area.fwhm10.fsaverage.mgh 
done > $output_dir/Data/OutputFreeSurfer/mergedFS/under30/lh_area.txt 

wc -l "$output_dir/Data/OutputFreeSurfer/mergedFS/under30/lh_area.txt"

# Extract all files: rh area
for i in `cat $output_dir/Input/ABIDEu30_final_subs.txt`; do 
ls  $output_dir/Data/OutputFreeSurfer/fsaverageABIDE*/${i}/rh.area.fwhm10.fsaverage.mgh 
done > $output_dir/Data/OutputFreeSurfer/mergedFS/under30/rh_area.txt 

wc -l "$output_dir/Data/OutputFreeSurfer/mergedFS/under30/rh_area.txt"

# Extract all files: lh thickness
for i in `cat $output_dir/Input/ABIDEu30_final_subs.txt`; do 
ls  $output_dir/Data/OutputFreeSurfer/fsaverageABIDE*/${i}/lh.thickness.fwhm10.fsaverage.mgh
done > $output_dir/Data/OutputFreeSurfer/mergedFS/under30/lh_thickness.txt 

wc -l "$output_dir/Data/OutputFreeSurfer/mergedFS/under30/lh_thickness.txt"

# Extract all files: rh thickness
for i in `cat $output_dir/Input/ABIDEu30_final_subs.txt`; do 
ls  $output_dir/Data/OutputFreeSurfer/fsaverageABIDE*/${i}/rh.thickness.fwhm10.fsaverage.mgh
done > $output_dir/Data/OutputFreeSurfer/mergedFS/under30/rh_thickness.txt 

wc -l "$output_dir/Data/OutputFreeSurfer/mergedFS/under30/rh_thickness.txt"

# Actually merging them
mri_concat --f $output_dir/Data/OutputFreeSurfer/mergedFS/under30/lh_area.txt --o $output_dir/Data/OutputFreeSurfer/mergedFS/under30/lh_area_all.mgh
wc -l "$output_dir/Data/OutputFreeSurfer/mergedFS/under30/lh_area.txt"

mri_concat --f $output_dir/Data/OutputFreeSurfer/mergedFS/under30/rh_area.txt --o $output_dir/Data/OutputFreeSurfer/mergedFS/under30/rh_area_all.mgh
wc -l "$output_dir/Data/OutputFreeSurfer/mergedFS/under30/rh_area.txt"

mri_concat --f $output_dir/Data/OutputFreeSurfer/mergedFS/under30/lh_thickness.txt --o $output_dir/Data/OutputFreeSurfer/mergedFS/under30/lh_thickness_all.mgh
wc -l "$output_dir/Data/OutputFreeSurfer/mergedFS/under30/lh_thickness.txt"

mri_concat --f $output_dir/Data/OutputFreeSurfer/mergedFS/under30/rh_thickness.txt --o $output_dir/Data/OutputFreeSurfer/mergedFS/under30/rh_thickness_all.mgh
wc -l "$output_dir/Data/OutputFreeSurfer/mergedFS/under30/rh_thickness.txt"


### after first filter ###
output_dir="/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer"


# Extract all files: lh area
mkdir -p $output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo
for i in `cat $output_dir/Input/FSL_first_filter.txt`; do 
ls  $output_dir/Data/OutputFreeSurfer/fsaverageABIDE*/${i}/lh.area.fwhm10.fsaverage.mgh 
done > $output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/lh_area.txt 

wc -l "$output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/lh_area.txt"

# Extract all files: rh area
for i in `cat $output_dir/Input/FSL_first_filter.txt`; do 
ls  $output_dir/Data/OutputFreeSurfer/fsaverageABIDE*/${i}/rh.area.fwhm10.fsaverage.mgh 
done > $output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/rh_area.txt 

wc -l "$output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/rh_area.txt"

# Extract all files: lh thickness
for i in `cat $output_dir/Input/FSL_first_filter.txt`; do 
ls  $output_dir/Data/OutputFreeSurfer/fsaverageABIDE*/${i}/lh.thickness.fwhm10.fsaverage.mgh
done > $output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/lh_thickness.txt 

wc -l "$output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/lh_thickness.txt"

# Extract all files: rh thickness
for i in `cat $output_dir/Input/FSL_first_filter.txt`; do 
ls  $output_dir/Data/OutputFreeSurfer/fsaverageABIDE*/${i}/rh.thickness.fwhm10.fsaverage.mgh
done > $output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/rh_thickness.txt 

wc -l "$output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/rh_thickness.txt"

# Actually merging them
mri_concat --f $output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/lh_area.txt --o $output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/lh_area_all.mgh
wc -l "$output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/lh_area.txt"

mri_concat --f $output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/rh_area.txt --o $output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/rh_area_all.mgh
wc -l "$output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/rh_area.txt"

mri_concat --f $output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/lh_thickness.txt --o $output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/lh_thickness_all.mgh
wc -l "$output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/lh_thickness.txt"

mri_concat --f $output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/rh_thickness.txt --o $output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/rh_thickness_all.mgh
wc -l "$output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/rh_thickness.txt"



### after second filter ###
# Used for main analyses

output_dir="/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer"


# Extract all files: lh area
mkdir -p $output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/second_filter
for i in `cat $output_dir/Input/FSL_second_filter.txt`; do 
ls  $output_dir/Data/OutputFreeSurfer/fsaverageABIDE*/${i}/lh.area.fwhm10.fsaverage.mgh 
done > $output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/second_filter/lh_area.txt 

wc -l "$output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/second_filter/lh_area.txt"

# Extract all files: rh area
for i in `cat $output_dir/Input/FSL_second_filter.txt`; do 
ls  $output_dir/Data/OutputFreeSurfer/fsaverageABIDE*/${i}/rh.area.fwhm10.fsaverage.mgh 
done > $output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/second_filter/rh_area.txt 

wc -l "$output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/second_filter/rh_area.txt"

# Extract all files: lh thickness
for i in `cat $output_dir/Input/FSL_second_filter.txt`; do 
ls  $output_dir/Data/OutputFreeSurfer/fsaverageABIDE*/${i}/lh.thickness.fwhm10.fsaverage.mgh
done > $output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/second_filter/lh_thickness.txt 

wc -l "$output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/second_filter/lh_thickness.txt"

# Extract all files: rh thickness
for i in `cat $output_dir/Input/FSL_second_filter.txt`; do 
ls  $output_dir/Data/OutputFreeSurfer/fsaverageABIDE*/${i}/rh.thickness.fwhm10.fsaverage.mgh
done > $output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/second_filter/rh_thickness.txt 

wc -l "$output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/second_filter/rh_thickness.txt"

# Actually merging them
mri_concat --f $output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/second_filter/lh_area.txt --o $output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/second_filter/lh_area_all.mgh
wc -l "$output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/second_filter/lh_area.txt"

mri_concat --f $output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/second_filter/rh_area.txt --o $output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/second_filter/rh_area_all.mgh
wc -l "$output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/second_filter/rh_area.txt"

mri_concat --f $output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/second_filter/lh_thickness.txt --o $output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/second_filter/lh_thickness_all.mgh
wc -l "$output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/second_filter/lh_thickness.txt"

mri_concat --f $output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/second_filter/rh_thickness.txt --o $output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/second_filter/rh_thickness_all.mgh
wc -l "$output_dir/Data/OutputFreeSurfer/mergedFS/FSL_redo/second_filter/rh_thickness.txt"
