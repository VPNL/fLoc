function fLocAnalysis(session, clip, contrasts)
% Automated analysis of fMRI data from fLoc funcional localizer experiment 
% implemented with vistasoft (https://github.com/vistalab/vistasoft). 
% 
% INPUTS
% sessions: name of session in ~fLoc/fMRI/ to analyze (string)
% clip: number of TRs to clip from the beginning of each run (int)
% contrasts (optional): custom user-defined contrasts (struct)
%   contrasts(N).active  -- active condition numbers for Nth contrast
%   contrasts(N).control -- control condition numbers for Nth contrast
%
% OUTPUTS
% By default the code generates voxel-wise parameters maps of GLM betas, 
% model residual error, variance explained, and contrast maps comparing
% betas for each condition vs. all other conditions (t-values). 
% Parameter maps are saved as .mat files in ~/fLoc/fMRI/*/GLMs/ and can be 
% viewed by calling 'mrVista' function in the fully processed session directory. 
% 
% AS 7/2018


%% Check and validate inputs and path to vistasoft

% check for missing or empty inputs
if nargin < 1 || isempty(session)
    error('Specify a session directory in ~/fLoc/fMRI to analyze.');
end
if nargin < 2 || isempty(clip)
    error('Specify how many TRs to clip from beginning of each run.')
end
if nargin < 3 || isempty(contrasts)
    contrasts = [];
end
if isempty(which('mrVista'))
    vista_path = 'https://github.com/vistalab/vistasoft';
    error(['Add vistasoft to your matlab path: ' vista_path]);
end

% standardize and validate session argument
data_dir = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'fMRI');
dd = dir(data_dir); all_sessions = {dd([dd.isdir]).name};
if length(all_sessions) < 3
    error('No valid session data directories found in ~/fLoc/fMRI/.');
else
    all_sessions = all_sessions(3:end);
end
if sum(strcmp(session, all_sessions)) ~= 1
    error(['Session ' session{ss} ' not found in ~/fLoc/fMRI/.']);
end

% look for parfiles corresponding to each run of fMRI data
session_dir = fullfile(data_dir, session); rcnt = 0;
while exist(fullfile(session_dir, ['Run' num2str(rcnt + 1) '.nii.gz']), 'file') == 2
    rcnt = rcnt + 1;
end
run_names = cellfun(@(X) ['Run' num2str(X) '.nii.gz'], num2cell(1:rcnt), 'uni', false);
run_paths = cellfun(@(X) fullfile(session_dir, X), run_names, 'uni', false);
cd(session_dir); fns = dir(session_dir); fn = {fns.name};
pfs = fn(contains(fn, '.par')); parfiles = cell(1, rcnt); 
for rr = 1:rcnt
    rp = find(contains(pfs, ['run' num2str(rr) '.par']));
    if length(rp) ~= 1
        error(['No .par file found for ' session ', run ' num2str(rr) '.']);
    else
        parfiles{rr} = pfs{rp};
    end
end
parfiles = cellfun(@(X) fullfile(session_dir, X), parfiles, 'uni', false);

% standardize and validate clip argument
if sum(~isint(clip)) > 1
    error('Values in clip argument must be integers.');
end
if length(clip) == 1
    clip = repmat(clip, 1, rcnt);
elseif length(clip) ~= length(session)
    error('Length of clip argument is inconsistent with number of runs.');
end
keep_frames = [clip(:) repmat(-1, length(clip), 1)];


%% Initialize session and preprocess fMRI data

% setup analysis parameters for GLM
params = mrInitDefaultParams;
params.doAnalParams = 1;
params.doSkipFrames = 1;
params.doPreprocessing = 1;
params.functionals = run_paths;    % paths to runs of fMRI data
params.subject = session;          % name of session directory
params.keepFrames = keep_frames;   % TRs to model (after clipping)
params.parfile = parfiles;         % paths to parfiles
params.scanGroups = {1:rcnt};      % group all runs of localizer
params.motionComp = 0;             % disable motion correction for now
params.motionCompRefFrame = 8;     % reference TR for motion correction
params.motionCompSmoothFrames = 3; % smoothing window for motion correction

% look for T1 volume and leave blank if none exists
if exist(fullfile(session_dir, '3Danatomy', 't1.nii.gz'), 'file') == 2
    params.vAnatomy = fullfile(session_dir, '3Danatomy', 't1.nii.gz');
end

% look for inplane volume and create a pseudo inplane file if none exists
dd = dir; ff = {dd.name}; inplane_check = contains(lower(ff), 'inplane');
if sum(inplane_check) == 0
    nii = MRIread('Run1.nii.gz'); nii.vol = mean(nii.vol, 4);
    MRIwrite(nii, 'Inplane.nii.gz');
    params.inplane = fullfile(session_dir, 'Inplane.nii.gz');
else
    params.inplane = fullfile(session_dir, ff{find(inplane_check, 1)});
end

% inititalize vistasoft session and open hidden inplane view
mrInit(params); hi = initHiddenInplane('Original', 1);

% do within-scan motion compensation and check for motion > 2 voxels
setpref('VISTA', 'verbose', false); % suppress wait bar
hi = motionCompSelScan(hi, 'MotionComp', 1:rcnt, ...
    params.motionCompRefFrame, params.motionCompSmoothFrames);
saveSession; close all;
fig = openfig(fullfile(session_dir, 'Images', 'Within_Scan_Motion_Est.fig'), 'invisible');
L = get(get(fig, 'Children'), 'Children');
for rr = 1:rcnt
    motion_est = L{rr + 1}.YData;
    if max(motion_est(:)) > 2
        error('Warning: within-scan motion exceeds 2 voxels.');
    end
end

% do between-scan motion compensation and check for motion > 2 voxels
hi = initHiddenInplane('MotionComp', 1); baseScan = 1; targetScans = 1:rcnt;
[hi, M] = betweenScanMotComp(hi, 'MotionComp_RefScan1', baseScan, targetScans);
fname = fullfile('Inplane', 'MotionComp_RefScan1', 'ScanMotionCompParams');
save(fname, 'M', 'baseScan', 'targetScans');
hi = selectDataType(hi, 'MotionComp_RefScan1');
saveSession; close all;
fid = fopen('Between_Scan_Motion.txt', 'r'); motion_est = zeros(rcnt - 1, 3);
for rr = 1:rcnt - 1
    ln = strsplit(fgetl(fid), ' ');
    motion_est(rr, 1) = str2num(ln{8});
    motion_est(rr, 2) = str2num(ln{11});
    motion_est(rr, 3) = str2num(ln{14});
end
fclose(fid);
if max(motion_est(:)) > 2
    error('Warning: between-scan motion exceeds 2 voxels.');
end


%% Analyze fMRI data and generate model parameter maps

% set event-related parameters
er_params = er_defaultParams;
er_params.detrend = -1;      % linear detrending
er_params.glmHRF = 3;        % difference-of-gammas HRF
er_params.lowPassFilter = 0; % do not low-pass filter by default

% calculate number of frames per block
nii = MRIread(run_paths{1}); tr = nii.tr; clear nii;
[onsets, cond_nums, conds] = deal([]); cnt = 0;
for rr = 1:rcnt
    fid = fopen(parfiles{rr}, 'r');
    while ~feof(fid)
        ln = fgetl(fid); cnt = cnt + 1;
        if isempty(ln) || isempty(findstr(sprintf(' '), ln)); return; end
        ln(ln == sprintf('\t')) = ''; prts = deblank(strsplit(ln, ' '));
        onsets(cnt) = str2num(prts{1});
        cond_nums(cnt) = str2num(prts{3});
        conds{cnt} = prts{4};
    end
    fclose(fid);
end
block_dur = onsets(2) - onsets(1);
if rem(block_dur, tr / 1000) > 0
    error('TR must be a factor of experimental block duration.');
else
    frames_per_block = block_dur / (tr / 1000);
end

% make a list of unique condition numbers and corresponding condition names
cond_num_list = unique(cond_nums); cond_list = {};
for cc = 1:length(cond_num_list)
    cond_list{cc} = conds{find(cond_nums == cond_num_list(cc), 1)};
end
bb = find(cond_num_list == 0); cond_num_list(bb) = []; cond_list(bb) = [];

% group scans of preprocessed data and set event-related parameters
hi = initHiddenInplane('MotionComp_RefScan1', params.scanGroups{1}(1));
hi = er_groupScans(hi, params.scanGroups{1});
er_params.eventsPerBlock = frames_per_block; er_params.framePeriod = tr / 1000;
er_setParams(hi, er_params);
hi = er_assignParfilesToScans(hi, params.scanGroups{1}, parfiles);
saveSession; close all;

% run GLM and compute default statistical contrasts
hi = initHiddenInplane('MotionComp_RefScan1', params.scanGroups{1}(1));
hi = applyGlm(hi, 'MotionComp_RefScan1', params.scanGroups{1}, er_params);
hi = initHiddenInplane('GLMs', 1); cnt = 1;
for cc = 1:length(cond_num_list)
    active_conds = cc; control_conds = cond_num_list(cond_num_list ~= cc);
    contrast_name = [cond_list{cc} '_vs_all'];
    hi = computeContrastMap2(hi, active_conds, control_conds, ...
        contrast_name, 'mapUnits','T');
end

% compute custom user-defined contrast maps
if isstruct(contrasts)
    for cc = 1:length(contrasts)
        active_conds = strcat(cond_list{contrasts(cc).active});
        control_conds = strcat(cond_list{contrasts(cc).control});
        contrast_name = [active_conds '_vs_' control_conds];
        hi = computeContrastMap2(hi, contrasts(cc).active, ...
            contrasts(cc).control, contrast_name, 'mapUnits','T');
    end
end


end
