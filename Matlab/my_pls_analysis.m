%%% Uses PLS toolkit (See README)
%%this script should be in a folder called "pls_analysis"
%%%in this folder you also need to create a folder called  "data" with X -> behavioral var and Y -> brain var (created by preparing_data_PLS.m)

%%%%%
% Add toolkit to path
toolkit_dir = '/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Scripts/Matlab/RCCA/cca_pls_toolkit-master/';
cd(toolkit_dir);
addpath(toolkit_dir);
set_path;

% Project folder (contains the data/ subfolder with X.mat, Y.mat)
cfg.dir.project = '/Volumes/g_psyplafor_methlab$/Students/Katharina_Bremer/Scripts/Matlab/RCCA/cca_pls_toolkit-master/pls_analysis';

% Standard PLS correlation
cfg.machine.name = 'pls';

% Descriptive framework (fit to all subjects)
cfg.frwork.name = 'permutation';
cfg.frwork.split.nout = 1;

% Statistical inference
cfg.stat.nperm = 1000;

% Environment
cfg.env.comp = 'local';

% Update cfg with defaults
cfg = cfg_defaults(cfg);
%%
% Run analysis
main(cfg);

%% Load data and PLS weights 
res_folder = fullfile(cfg.dir.project, 'framework/pls_permutation/res/level1');

load(fullfile(cfg.dir.project, 'data', 'X.mat'), 'X');   % 405 x 8 clinical
load(fullfile(cfg.dir.project, 'data', 'Y.mat'), 'Y');   % 405 x 150 brain
load(fullfile(res_folder, 'model_1.mat'), 'wX', 'wY');   % saliences from the toolkit
wX = wX(:);  wY = wY(:);

X_labels = {'ADOS2_severity','ADI_R_SOCIAL_A','ADOS2_rrb','ADOS2_total_gotham','ADOS2_socaff','ADI_R_VERBAL_BV','ADI_RRB','ADI_R_NONVERBAL_BV'};

Xz = zscore(X);
Yz = zscore(Y);
u = Xz*wX(:);  v = Yz*wY(:);

%% Creating Haufe loadings 
a_X = corr(Xz, u, 'rows','pairwise');
a_Y = corr(Yz, v, 'rows','pairwise');


%% Bootstrap 
n_boot = 1000;
n_subj = size(Xz,1);
boot_wX = zeros(n_boot, size(Xz,2)); % create empty tables
boot_wY = zeros(n_boot, size(Yz,2));

rng(1); % seed is fixed 
for b = 1:n_boot
    idx = randi(n_subj, n_subj, 1); % draws sample with replacement
    Xb = zscore(X(idx,:));          % re-standardize within the resample
    Yb = zscore(Y(idx,:));

    C = Xb' * Yb;               % cross covariance matrix
    [U,~,V] = svd(C,'econ');    % PLS
    wXb = U(:,1);
    wYb = V(:,1);

    if wYb' * wY(:) < 0
        wXb = -wXb;  wYb = -wYb;
    end

    boot_wX(b,:) = wXb;
    boot_wY(b,:) = wYb;
end

%% Bootstrap ratio (BSR) 
bsr_X = wX ./ std(boot_wX)'; % original weight / how much it varied during the bootstrapping
bsr_Y = wY ./ std(boot_wY)';

fprintf('\nreliable clinical: %d of %d\n', sum(abs(bsr_X)>2), numel(bsr_X));
fprintf('reliable brain ICs: %d of %d  (chance ~7)\n', sum(abs(bsr_Y)>2), numel(bsr_Y));

%% Running the bootstrapping over different seeds (seeds 1:5)
n_boot = 1000;
n_subj = size(X,1);

for s = 1:5
    rng(s);
    boot_wX = zeros(n_boot, size(X,2)); % create empty tables 
    boot_wY = zeros(n_boot, size(Y,2));

    for b = 1:n_boot
        idx = randi(n_subj, n_subj, 1); % draw random samples with replacement
        Xb = zscore(X(idx,:));          % re-standardize within sample
        Yb = zscore(Y(idx,:));
        [U,~,V] = svd(Xb'*Yb, 'econ');  % PLS
        wXb = U(:,1);
        wYb = V(:,1);
        if wYb' * wY < 0                % signs of saliences are arbitrary -> we want all saliences to point the same way as the original
            wXb = -wXb;  wYb = -wYb;
        end
        boot_wX(b,:) = wXb;
        boot_wY(b,:) = wYb;
    end

    bsr_X_s = wX ./ std(boot_wX)';    % original weight / how much it varied during the bootstrapping
    bsr_Y_s = wY ./ std(boot_wY)';

    fprintf('seed %d: %d clinical, %d brain, max|BSR_Y| = %.4f\n', s, sum(abs(bsr_X_s)>2), sum(abs(bsr_Y_s)>2), max(abs(bsr_Y_s)));
end

%% Saving the results
T_clin = table(X_labels', wX, a_X, bsr_X, ...
    'VariableNames',{'Variable','Salience','HaufeLoading','BSR'});
writetable(T_clin, fullfile(res_folder,'bootstrap_clinical_final.csv'));

[~,si] = sort(abs(bsr_Y),'descend');
T_brain = table(arrayfun(@(x)sprintf('IC%03d',x), si, 'UniformOutput',false), wY(si), a_Y(si), bsr_Y(si), 'VariableNames',{'IC','Salience','HaufeLoading','BSR'});
writetable(T_brain, fullfile(res_folder,'bootstrap_brain_ICs_final.csv'));
