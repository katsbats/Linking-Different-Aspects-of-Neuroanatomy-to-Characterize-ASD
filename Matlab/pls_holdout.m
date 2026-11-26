%%% Uses PLS toolkit (See README)
% this script performs the holdout test. X.mat and Y.mat were copied from
% the pls_analysis data folder.
% Add toolkit to path
toolkit_dir = '/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Scripts/Matlab/RCCA/cca_pls_toolkit-master/';
cd(toolkit_dir); addpath(toolkit_dir); set_path;

% Project folder (contains the data/ subfolder with X.mat, Y.mat)
cfg.dir.project = '/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Scripts/Matlab/RCCA/cca_pls_toolkit-master/pls_holdout_two';

% Standard PLS correlation
cfg.machine.name = 'pls';

% Predictive framework (train/test split)
cfg.frwork.name = 'holdout';
cfg.frwork.split.nout = 10;
cfg.frwork.split.propout = 0.2;
cfg.frwork.split.nin = 50;

% Statistical inference
cfg.stat.nperm = 1000;

% Environment
cfg.env.comp = 'local';

% Update cfg with defaults
cfg = cfg_defaults(cfg);
%%
% Run analysis
main(cfg);

% Results of the analysis are saved in the toolbox 
