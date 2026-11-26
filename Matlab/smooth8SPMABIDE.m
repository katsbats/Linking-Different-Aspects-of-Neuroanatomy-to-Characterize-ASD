s_cloud = 1;

 
if s_cloud == 1
    prefix = fullfile(filesep, 'mnt', 'methlab-drive','methlab');
    jobfile = fullfile(prefix, 'Students','Katharina_Bremer','Scripts','Matlab', ...
                       'SPM','smoothABIDEs8.mat');
else
    prefix = fullfile(filesep, 'Volumes','g_psyplafor_methlab$');
    jobfile = fullfile(prefix, 'Students','Katharina_Bremer','Scripts','Matlab', ...
                       'SPM','smoothABIDEs8.mat');
end

load(jobfile, 'matlabbatch');

addpath(fullfile(prefix, 'Students', 'Katharina_Bremer', 'Scripts', 'Matlab', 'matlab_installation', 'spm'));
spm('defaults','PET');
spm_jobman('initcfg');

T = dir(fullfile(prefix,'Students/Katharina_Bremer/Input/ABIDE_*/*/mri/mwp1*.nii'));
T1_files = fullfile({T.folder}, {T.name});
T1_files = strcat(T1_files, ',1');

matlabbatch{1}.spm.spatial.smooth.data = T1_files';

length(T1_files) 
T1_files(1:5)

%%
spm_jobman('run', matlabbatch);
