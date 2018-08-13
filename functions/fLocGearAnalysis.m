function err = fLocGearAnalysis(session)
% Automated preprocessing of fMRI data using functions from vistasoft 
% (https://github.com/vistalab/vistasoft). 
% 
% INPUTS
% 1) session: name of session in ~/fLoc/data/ to analyze (string)
%
% OUTPUTS
% 1) err: 1 if analysis terminated with an error, 0 if analysis completed
% 
% AS 8/2018


%% Initialize session and preprocess fMRI data

% setup analysis parameters for GLM
params = mrInitDefaultParams;
params.doAnalParams = 1;
params.doSkipFrames = 1;
params.doPreprocessing = 1;
params.functionals = niifiles;     % paths to runs of fMRI data
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
dd = dir; ff = {dd.name};
inplane_check = contains(lower(ff), 'inplane') & contains(lower(ff), '.nii.gz');
if sum(inplane_check) == 0
    nii = MRIread(niifiles{1}); nii.vol = mean(nii.vol, 4);
    MRIwrite(nii, 'PseudoInplane.nii.gz');
    fprintf(lid, 'Warning -- Inplane scan not found. Psuedo inplane created from run 1. \n');
    fprintf('Warning -- Inplane scan not found. Psuedo inplane created from run 1. \n');
    params.inplane = fullfile(session_dir, 'PseudoInplane.nii.gz');
else
    params.inplane = fullfile(session_dir, ff{find(inplane_check, 1)});
    nii = niftiApplyCannonicalXform(niftiRead(params.inplane));
    niftiWrite(nii, params.inplane);
end

% inititalize vistasoft session and open hidden inplane view
fprintf(lid, 'Initializing vistasoft session directory in: \n%s \n\n', session_dir);
fprintf('Initializing vistasoft session directory in: \n%s \n\n', session_dir);
if exist(fullfile(session_dir, 'Inplane'), 'dir') ~= 7
    mrInit(params);
end
hi = initHiddenInplane('Original', 1);

% do slice timing correction assuming interleaved slice acquisition
if stc_flag
    fprintf(lid, 'Starting slice timing correction... \n');
    fprintf('Starting slice timing correction... \n');
    if ~exist(fullfile(session_dir, 'Inplane', 'Timed'), 'dir') ~= 7
        load(fullfile(session_dir, 'mrSESSION'));
        for rr = 1:rcnt
            mrSESSION.functionals(rr).sliceOrder = [1:2:nslices 2:2:nslices];
        end
        saveSession; hi = initHiddenInplane('Original', 1);
        hi = AdjustSliceTiming(hi, 0, 'Timed');
        saveSession; close all;
    end
    fprintf(lid, 'Slice timing correction complete. \n\n');
    fprintf('Slice timing correction complete. \n\n');
    hi = initHiddenInplane('Timed', 1);
end

% do within-scan motion compensation and check for motion > 2 voxels
fprintf(lid, 'Starting within-scan motion compensation... \n');
fprintf('Starting within-scan motion compensation... \n');
setpref('VISTA', 'verbose', false); % suppress wait bar
if exist(fullfile(session_dir, 'Images', 'Within_Scan_Motion_Est.fig'), 'file') ~= 2
    hi = motionCompSelScan(hi, 'MotionComp', 1:rcnt, ...
        params.motionCompRefFrame, params.motionCompSmoothFrames);
    saveSession; close all;
end
fig = openfig(fullfile(session_dir, 'Images', 'Within_Scan_Motion_Est.fig'), 'invisible');
L = get(get(fig, 'Children'), 'Children');
for rr = 1:rcnt
    motion_est = L{rr + 1}.YData;
    if max(motion_est(:)) > 2
        fprintf(lid, 'Warning -- Within-scan motion exceeds 2 voxels. \nExited analysis.');
        fprintf('Warning -- Within-scan motion exceeds 2 voxels. \nExited analysis.');
        fclose(lid); return;
    end
end
fprintf(lid, 'Within-scan motion compensation complete. QA checks passed. \n\n');
fprintf('Within-scan motion compensation complete. QA checks passed. \n\n');

% do between-scan motion compensation and check for motion > 2 voxels
fprintf(lid, 'Starting between-scan motion compensation... \n');
fprintf('Starting between-scan motion compensation... \n');
if exist(fullfile(session_dir, 'Between_Scan_Motion.txt'), 'file') ~= 2
    hi = initHiddenInplane('MotionComp', 1); baseScan = 1; targetScans = 1:rcnt;
    [hi, M] = betweenScanMotComp(hi, 'MotionComp_RefScan1', baseScan, targetScans);
    fname = fullfile('Inplane', 'MotionComp_RefScan1', 'ScanMotionCompParams');
    save(fname, 'M', 'baseScan', 'targetScans');
    hi = selectDataType(hi, 'MotionComp_RefScan1');
    saveSession; close all;
end
fid = fopen('Between_Scan_Motion.txt', 'r'); motion_est = zeros(rcnt - 1, 3);
for rr = 1:rcnt - 1
    ln = strsplit(fgetl(fid), ' ');
    motion_est(rr, 1) = str2double(ln{8});
    motion_est(rr, 2) = str2double(ln{11});
    motion_est(rr, 3) = str2double(ln{14});
end
fclose(fid);
if max(motion_est(:)) > 2
    fprintf(lid, 'Warning -- Between-scan motion exceeds 2 voxels. \nExited analysis.');
    fprintf('Warning -- Between-scan motion exceeds 2 voxels. \nExited analysis.');
    fclose(lid); return;
end
fprintf(lid, 'Between-scan motion compensation complete. QA checks passed. \n\n');
fprintf('Between-scan motion compensation complete. QA checks passed. \n\n');

% remove spikes from each run of data with median filter
fdir = fullfile(session_dir, 'Inplane', 'MotionComp_RefScan1', 'TSeries');
fprintf(lid, 'Removing spikes from voxel time series. \n\n');
fprintf('Removing spikes from voxel time series. \n\n');
for rr = 1:rcnt
    fstem = ['tSeriesScan' num2str(rr)];
    if ~exist(fullfile(fdir, [fstem '_raw.nii.gz']), 'file') == 2
        copyfile(fullfile(fdir, [fstem '.nii.gz']), fullfile(fdir, [fstem '_raw.nii.gz']));
        nii = MRIread(fullfile(fdir, [fstem '.nii.gz']));
        [x, y, z, t] = size(nii.vol); swin = ceil(3 / (nii.tr / 1000));
        tcs = medfilt1(reshape(permute(nii.vol, [4 1 2 3]), t, []), swin, 'truncate');
        nii.vol = permute(reshape(tcs, t, x, y, z), [2 3 4 1]);
        MRIwrite(nii, fullfile(fdir, [fstem '.nii.gz']));
    end
end


%% Analyze fMRI data and generate model parameter maps

% set event-related parameters
er_params = er_defaultParams;
er_params.detrend = -1;      % linear detrending
er_params.glmHRF = 3;        % difference-of-gammas HRF
er_params.lowPassFilter = 0; % do not low-pass filter by default

% calculate number of frames per block
nii = MRIread(niifiles{1}); tr = nii.tr; clear nii;
[onsets, cond_nums, conds] = deal([]); cnt = 0;
for rr = 1:rcnt
    fid = fopen(parfiles{rr}, 'r');
    while ~feof(fid)
        ln = fgetl(fid); cnt = cnt + 1;
        if isempty(ln); return; end; ln(ln == sprintf('\t')) = '';
        prts = deblank(strsplit(ln, ' ')); prts(cellfun(@isempty, prts)) = [];
        onsets(cnt) = str2double(prts{1});
        cond_nums(cnt) = str2double(prts{2});
        conds{cnt} = prts{3};
    end
    fclose(fid);
end
block_dur = onsets(2) - onsets(1);
if rem(block_dur, tr / 1000) > 0
    fprintf(lid, 'Error -- TR must be a factor of experimental block duration. \nExited analysis.');
    fprintf('Error -- TR must be a factor of experimental block duration. \nExited analysis.');
    fclose(lid); return;
else
    frames_per_block = block_dur / (tr / 1000);
end

% make a list of unique condition numbers and corresponding condition names
cond_num_list = unique(cond_nums); cond_list = cell(1, length(cond_num_list));
for cc = 1:length(cond_num_list)
    cond_list{cc} = conds{find(cond_nums == cond_num_list(cc), 1)};
end
% remove baseline from list of conditions
bb = find(cond_num_list == 0); cond_num_list(bb) = []; cond_list(bb) = [];

% group scans of preprocessed data and set event-related parameters
hi = initHiddenInplane('MotionComp_RefScan1', params.scanGroups{1}(1));
hi = er_groupScans(hi, params.scanGroups{1});
er_params.eventsPerBlock = frames_per_block;
er_params.framePeriod = tr / 1000;
er_setParams(hi, er_params);
hi = er_assignParfilesToScans(hi, params.scanGroups{1}, parfiles);
saveSession; close all;

% run GLM and compute default statistical contrasts
fprintf(lid, 'Performing GLM analysis for %s... \n\n', session);
fprintf('Performing GLM analysis for %s... \n\n', session);
hi = initHiddenInplane('MotionComp_RefScan1', params.scanGroups{1}(1));
hi = applyGlm(hi, 'MotionComp_RefScan1', params.scanGroups{1}, er_params);
hi = initHiddenInplane('GLMs', 1);
for cc = 1:length(cond_num_list)
    active_conds = cc; control_conds = cond_num_list(cond_num_list ~= cc);
    contrast_name = [cond_list{cc} '_vs_all'];
    hi = computeContrastMap2(hi, active_conds, control_conds, ...
        contrast_name, 'mapUnits','T');
end
fprintf(lid, 'Default GLM parameter maps saved in: \n%s/GLMs/... \n\n', session_dir);
fprintf('Default GLM parameter maps saved in: \n%s/GLMs/... \n\n', session_dir);

% compute custom user-defined contrast maps
if isstruct(contrasts)
    for cc = 1:length(contrasts)
        active_conds = strcat(cond_list{contrasts(cc).active});
        control_conds = strcat(cond_list{contrasts(cc).control});
        contrast_name = [active_conds '_vs_' control_conds];
        hi = computeContrastMap2(hi, contrasts(cc).active, ...
            contrasts(cc).control, contrast_name, 'mapUnits','T');
    end
    fprintf(lid, 'Custom GLM contrast maps saved in: \n%s/GLMs/... \n\n', session_dir);
    fprintf('Custom GLM contrast maps saved in: \n%s/GLMs/... \n\n', session_dir);
end
fprintf(lid, 'fLocAnalsis for %s is complete! \n', session);
fprintf('fLocAnalsis for %s is complete! \n', session); fclose(lid);
err = 0;

end
