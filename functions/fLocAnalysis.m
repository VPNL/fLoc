function err = fLocAnalysis(session, init_params, glm_params, clip, stc)
% Automated analysis of fMRI data from fLoc funcional localizer experiment 
% using vistasoft functions (https://github.com/vistalab/vistasoft). 
% 
% INPUTS
% 1) session: name of session in ~/fLoc/data/ to analyze (string)
% 2) init_params: optional preprocessing parameters (struct)
% 3) glm_parms: optional GLM analysis parameters (struct)
% 4) clip: optional number of TRs to clip from beginnning of each run (int)
% 5) stc: optional flag controlling slice time correction (logical)
%
% OUTPUT
% 1) err: 1 if analysis terminated with an error, 0 if analysis completed
% 
% By default the code generates the following voxel-wise parameters maps: 
% Beta values, model residual error, proportion of variance explained, and
% GLM contrasts (t-values). All parameter maps are saved as .mat files in 
% session/Inplane/GLMs/ and can be viewed in vistasoft. The code also 
% writes a file named "fLocAnalysis_log.txt" that logs progress of the 
% analysis in vistasoft.
% 
% AS 8/2018


%% Check inputs and get analysis parameters

err = 1;

% check session argument and get session_id
if nargin < 1 || isempty(session) || ~(exist(session, 'dir') == 7)
    fprintf('Error: path to "session" data directory not found. \n\n'); return;
else
    [~, session_id] = fileparts(session);
end

% check and set defaults for clip and stc arguements
if nargin < 4 || isempty(clip); clip = 0; end
if rem(clip, 1) ~= 0
    fprintf('Error: clip arguement must be an integer. \n\n'); return;
end
if nargin < 5 || isempty(stc); stc = true; end
if stc == 1; stc = true; end
if stc == 0; stc = false; end
if ~islogical(stc)
    fprintf('Error: stc arguement must be a logical. \n\n'); return;
end

% set preprocessing parameters if not provided
if nargin < 2 || isempty(init_params)
    [~, init_params, dglm_params] = fLocAnalysisParams(session, clip, stc);
end

% set GLM analysis parameters if not provided
if nargin < 3 || isempty(glm_params)
    glm_params = dglm_params;
end

% apply canonical transformation to .nii.gz files
for rr = 1:length(init_params.functionals)
    niftiWrite(niftiApplyCannonicalXform(niftiRead(init_params.functionals{rr})));
end
niftiWrite(niftiApplyCannonicalXform(niftiRead(init_params.inplane)));
nii = niftiRead(init_params.functionals{1}); nslices = size(nii.data, 3);

% open logfile to track progress of analysis
lid = fopen(fullfile(session, 'fLocAnalysis_log.txt'), 'w+');
fprintf(lid, 'Starting analysis for session %s. \n\n', session_id);
fprintf('Starting analysis for session %s. \n\n', session_id);


%% Initialize session and preprocess fMRI data

% inititalize vistasoft session and open hidden inplane view
fprintf(lid, 'Initializing vistasoft session directory in: \n%s \n\n', session);
fprintf('Initializing vistasoft session directory in: \n%s \n\n', session);
setpref('VISTA', 'verbose', false); % suppress wait bar
if exist(fullfile(session, 'Inplane'), 'dir') ~= 7
    mrInit(init_params);
end
hi = initHiddenInplane('Original', 1);

% do slice timing correction assuming interleaved slice acquisition
if stc
    fprintf(lid, 'Starting slice timing correction... \n');
    fprintf('Starting slice timing correction... \n');
    if ~(exist(fullfile(session, 'Inplane', 'Timed'), 'dir') == 7)
        load(fullfile(session, 'mrSESSION'));
        for rr = 1:length(init_params.functionals)
            mrSESSION.functionals(rr).sliceOrder = [1:2:nslices 2:2:nslices];
        end
        setpref('VISTA', 'verbose', false); % suppress wait bar
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
if exist(fullfile(session, 'Images', 'Within_Scan_Motion_Est.fig'), 'file') ~= 2
    hi = motionCompSelScan(hi, 'MotionComp', 1:length(init_params.functionals), ...
        init_params.motionCompRefFrame, init_params.motionCompSmoothFrames);
    saveSession; close all;
end
fig = openfig(fullfile(session, 'Images', 'Within_Scan_Motion_Est.fig'), 'invisible');
L = get(get(fig, 'Children'), 'Children');
for rr = 1:length(init_params.functionals)
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
if exist(fullfile(session, 'Between_Scan_Motion.txt'), 'file') ~= 2
    hi = initHiddenInplane('MotionComp', 1);
    baseScan = 1; targetScans = 1:length(init_params.functionals);
    [hi, M] = betweenScanMotComp(hi, 'MotionComp_RefScan1', baseScan, targetScans);
    fname = fullfile(session, 'Inplane', 'MotionComp_RefScan1', 'ScanMotionCompParams');
    save(fname, 'M', 'baseScan', 'targetScans');
    hi = selectDataType(hi, 'MotionComp_RefScan1');
    saveSession; close all;
end
fid = fopen(fullfile(session, 'Between_Scan_Motion.txt', 'r'));
motion_est = zeros(length(init_params.functionals) - 1, 3);
for rr = 1:length(init_params.functionals) - 1
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


%% Analyze fMRI data and generate model parameter maps

% complile list of all conditions in experiment
[cond_nums, conds] = deal([]); cnt = 0;
for rr = 1:length(init_params.functionals)
    fid = fopen(init_params.parfile{rr}, 'r');
    while ~feof(fid)
        ln = fgetl(fid); cnt = cnt + 1;
        if isempty(ln); return; end; ln(ln == sprintf('\t')) = '';
        prts = deblank(strsplit(ln, ' ')); prts(cellfun(@isempty, prts)) = [];
        cond_nums(cnt) = str2double(prts{2});
        conds{cnt} = prts{3};
    end
    fclose(fid);
end

% make a list of unique condition numbers and corresponding condition names
cond_num_list = unique(cond_nums); cond_list = cell(1, length(cond_num_list));
for cc = 1:length(cond_num_list)
    cond_list{cc} = conds{find(cond_nums == cond_num_list(cc), 1)};
end
% remove baseline from lists of conditions
bb = find(cond_num_list == 0); cond_num_list(bb) = []; cond_list(bb) = [];

% group scans of preprocessed data and set event-related parameters
hi = initHiddenInplane('MotionComp_RefScan1', init_params.scanGroups{1}(1));
hi = er_groupScans(hi, init_params.scanGroups{1});
er_setParams(hi, glm_params);
hi = er_assignParfilesToScans(hi, init_params.scanGroups{1}, init_params.parfile);
saveSession; close all;

% run GLM and compute default statistical contrasts
fprintf(lid, 'Performing GLM analysis for %s... \n\n', session);
fprintf('Performing GLM analysis for %s... \n\n', session);
hi = initHiddenInplane('MotionComp_RefScan1', init_params.scanGroups{1}(1));
hi = applyGlm(hi, 'MotionComp_RefScan1', init_params.scanGroups{1}, glm_params);
hi = initHiddenInplane('GLMs', 1);
if length(cond_num_list) == 10
    for cc = 1:2:length(cond_num_list)
        active_conds = [cc cc + 1];
        control_conds = setdiff(cond_num_list, active_conds);
        contrast_name = [strcat(cond_list{cc:cc + 1}) '_vs_all'];
        hi = computeContrastMap2(hi, active_conds, control_conds, ...
            contrast_name, 'mapUnits','T');
    end
else
    for cc = 1:length(cond_num_list)
        active_conds = cc; control_conds = cond_num_list(cond_num_list ~= cc);
        contrast_name = [cond_list{cc} '_vs_all'];
        hi = computeContrastMap2(hi, active_conds, control_conds, ...
            contrast_name, 'mapUnits','T');
    end
end
fprintf(lid, 'GLM parameter maps saved in: \n%s/GLMs/... \n\n', session);
fprintf('GLM parameter maps saved in: \n%s/GLMs/... \n\n', session);

fprintf(lid, 'fLocAnalsis for %s is complete! \n', session_id);
fprintf('fLocAnalsis for %s is complete! \n', session_id); fclose(lid);
err = 0;

end
