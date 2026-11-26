#### FLICA for unimodal decompositions ###

# CT
~/miniconda3/envs/flica_env/bin/python /mnt/methlab-drive/methlab/Students/Katharina_Bremer/flica/flica.py \
  -nICAs 100 -maxits 1500 -lambda_dims R \
  -output_dir /mnt/methlab-drive/methlab/Students/Katharina_Bremer/Output/Unimodal/CT \
  -fs_path /home/ubuntu/freesurfer \
  /mnt/methlab-drive/methlab/Students/Katharina_Bremer/Data/brain_data_FSL/unimodal_second_filter_CT 


# PA (surface area)
~/miniconda3/envs/flica_env/bin/python /mnt/methlab-drive/methlab/Students/Katharina_Bremer/flica/flica.py \
  -nICAs 100 -maxits 1500 -lambda_dims R \
  -output_dir /mnt/methlab-drive/methlab/Students/Katharina_Bremer/Output/Unimodal/PA \
  -fs_path /home/ubuntu/freesurfer \
  /mnt/methlab-drive/methlab/Students/Katharina_Bremer/Data/brain_data_FSL/unimodal_second_filter_PA 


# JD
~/miniconda3/envs/flica_env/bin/python /mnt/methlab-drive/methlab/Students/Katharina_Bremer/flica/flica.py \
  -nICAs 100 -maxits 1500 -lambda_dims R \
  -output_dir /mnt/methlab-drive/methlab/Students/Katharina_Bremer/Output/Unimodal/JD \
  -fs_path /home/ubuntu/freesurfer \
  /mnt/methlab-drive/methlab/Students/Katharina_Bremer/Data/brain_data_FSL/unimodal_second_filter_JD 


# VBM
~/miniconda3/envs/flica_env/bin/python /mnt/methlab-drive/methlab/Students/Katharina_Bremer/flica/flica.py \
  -nICAs 100 -maxits 1500 -lambda_dims R \
  -output_dir /mnt/methlab-drive/methlab/Students/Katharina_Bremer/Output/Unimodal/VBM \
  -fs_path /home/ubuntu/freesurfer \
  /mnt/methlab-drive/methlab/Students/Katharina_Bremer/Data/brain_data_FSL/unimodal_second_filter_VBM
   
