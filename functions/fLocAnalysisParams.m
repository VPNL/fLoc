function [session, init_params, glm_params] = fLocAnalysisParams(session, clip)
% 
% Generate data structures for preprocessing and analyzing localizer data 
% using vistasoft functions (https://github.com/vistalab/vistasoft).
%
% [session, init_params, glm_params] = fLocAnalysisParams(session, clip)
% 
% INPUTS
% 1) session: fullpath to scanning session directory in ~/fLoc/data/ that 
%             is being analyzed (string)
% 2) clip: number of TRs to clip from beginnning of each run (int)
% 
% OUPUTS
% 1) session: fullpath to scanning session directory in ~/fLoc/data/ that 
%             is being analyzed (string)
% 2) init_params: parameters for initialization/preprocessing using
%                 vistasoft function mrInit (structure)
% 3) glm_params: parameters for running GLM analysis, to be set using 
%                vistasoft function er_setParams (structure)
% 
% AS 8/2018
% AR MN 9/2018

% check for correct MATLAB version
vers = version;
year = str2num(vers(end-5:end-2));
if year < 2016
    fprintf('Error: fLocAnalysis requires MATLAB version 2016 or later');
    return;
end

%% Initialize default parameters for mrVista preprocessing and GLM anlaysis

init_params = mrInitDefaultParams;
glm_params = er_defaultParams;

%% Find paths to data and stimulus files

% searches for all parfiles and nifti's in session directory
[~, session_id] = fileparts(session);
niifiles = dir(fullfile(session, '*.nii.gz')); niifiles = {niifiles.name};
niifiles = niifiles(~contains(niifiles,'._'));
parfiles = dir(fullfile(session, '*.par')); parfiles = {parfiles.name};

% identifying the corresponding run number for each parfile and nifti
niipaths = {}; parpaths = {}; num_runs = 0;
while sum(contains(lower(niifiles), ['run' num2str(num_runs + 1) '.nii.gz'])) >= 1
    num_runs = num_runs + 1;
    nii_idx = find(contains(lower(niifiles), ['run' num2str(num_runs) '.nii.gz']), 1);
    %%changed this and similar cases below to create local paths, MN 12/18 %%%%%%%
    %niipaths{num_runs} = fullfile(session, niifiles{nii_idx});
    niipaths{num_runs} = fullfile(niifiles{nii_idx});
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    par_idx = find(contains(lower(parfiles), ['run' num2str(num_runs) '.par']), 1);
    if isempty(par_idx)
        fprintf('Error: no .par file found for run %d. \n\n', num_runs); return;
    else
       
        %parpaths{num_runs} = fullfile(session, parfiles{par_idx});
        parpaths{num_runs} = fullfile(parfiles{par_idx});
      
    end
end

% creating annotation for each run (e.g. 'localizer_run1')
annotations = {};
for i = 1:length(niipaths)
    annotations{i} = ['localizer_run',num2str(i)];
end

% check for anatomical inplane nifti
inplane_idx = find(contains(lower(niifiles), 'inplane'), 1);
if isempty(inplane_idx)
    fprintf('Warning: no inplane scan found for session %s. Generating pseudo inplane file. \n\n', session_id);
    nii = niftiRead(niipaths{1}); nii.data = mean(nii.data, 4);
    niftiWrite(nii, 'PseudoInplane.nii.gz');
    % inplane = fullfile(session, 'PseudoInplane.nii.gz');
    inplane = fullfile('PseudoInplane.nii.gz');
else
    % inplane = fullfile(session, niifiles{inplane_idx});
    inplane = fullfile(niifiles{inplane_idx});
end

% get the durations of TR and events
nii = niftiRead(niipaths{1}); TR = nii.pixdim(4);
pid = fopen(parfiles{1}); 
ln1 = fgetl(pid); ln1(ln1 == sprintf('\t')) = '';
ln2 = fgetl(pid); ln2(ln2 == sprintf('\t')) = '';
prts1 = deblank(strsplit(ln1, ' ')); prts2 = deblank(strsplit(ln2, ' '));
prts1(cellfun(@isempty, prts1)) = []; prts2(cellfun(@isempty, prts2)) = [];
block_dur = str2double(prts2{1}) - str2double(prts1{1}); epb = block_dur / TR;
if rem(epb, 1) > 0
    fprintf('Error: TR must be a factor of block duration defined in .par files. \n\n'); return;
end

%% Set preprocessing parameters

% paths to nift's and parfiles
init_params.inplane     = inplane;  % path to inplane file found by gear code (.nii.gz)
init_params.functionals = niipaths; % paths to fMRI data with filenames (.nii.gz)
init_params.parfile     = parpaths; % paths to stimulus parameter files with filenames (.par)
% clipping
init_params.clip        = clip;     % int, number of TRs to clip from beginning of each run (initialize as 0)
% for clipping TRs from countdown, default should be [2] for MUX and [countdown/TR] for non-MUX
init_params.scanGroups  = {1:num_runs}; % cell array, group all functionals
init_params.sliceTimingCorrection = 0;  % logical, don't do slice time correction

% motion compensation
init_params.motionCompRefFrame     = 8; % frame number of reference TR for within-scan compensation
init_params.motionCompSmoothFrames = 3; % time window (in TRs) for within-scan compensation
init_params.motionCompRefScan      = 1; % run number of reference scan for between-scans compensation

% necessary fields
init_params.sessionCode = session_id; % char array, local session data directory
init_params.doAnalParams      = 1; % logical, set GLM analysis parameters during intialization
init_params.doSkipFrames      = 1; % logical, clip countdown frames during initialization
init_params.doPreprocessing   = 1; % logical, do some preprocessing during initialization
init_params.applyGlm          = 0; % logical, don't apply GLM during 
                                   %          initialization
init_params.applyCorAnal      = 0; % logical, don't apply CorAnal during 
                                   %          init
init_params.motionComp        = 0; % logical, don't do motion compensation
                                   %          during init

% set init_params.keeFrames using the value of the "clip" field set above
init_params.keepFrames = repmat([init_params.clip -1], num_runs, 1);

% descriptive fields for the mrVista session
init_params.subject     = session_id(1:find(session_id == '_') - 1); % char array with participant ID
init_params.description = 'localizer'; % char array describing session
init_params.comments    = 'Analyzed using fLoc'; % char array of comments
init_params.annotations = annotations; % cell array of descriptions for each run

% specify where mrSESSION.mat file will be saved
init_params.sessionDir = session;

%% Set GLM analysis parameters

% necessary fields that can be changed if desired
glm_params.detrend       = 1;  % detrending procedure: -1 = linear, 0 = do nothing, 1 = high-pass filter, 2 = quadratic
glm_params.detrendFrames = 20; % cutoff for high-pass filter in cycles/run (if glm_params.detrend = 1)
glm_params.inhomoCorrect = 1;  % time series transforamtion: 0 = do nothing, 1 = divide by mean and convert to PSC, 2 = divide by baseline
glm_params.glmHRF        = 3;  % set the HRF: 0 = deconvolve, 1 = estimate HRF from mean response, 2 = Boynton 1996, 3 = SPM, 4 = Dale 1999; default = 3
glm_params.glmWhiten     = 0;  % logical, controls whitening of data for GLM analysis

% necessary fields that shouldn't be changed
glm_params.eventAnalysis  = 1;   % logical, run a standard GLM
glm_params.lowPassFilter  = 0;   % logical, don't do low-pass filtering
glm_params.framePeriod    = TR;  % TR of fMRI data in seconds
glm_params.eventsPerBlock = epb; % int, number of TRs per block

% visulization parameters that do not affect GLM fits
glm_params.ampType    = 'betas'; % type of response amplitudes to visualize: 'difference' (raw), 'betas' (GLM betas), or 'deconvolved'
glm_params.timeWindow = -4:16;   % time window for brute-force averaging of conditions
glm_params.peakPeriod = 6:8;     % time window to estimate peak response
glm_params.bslPeriod  = -4:0;    % time window to estiamte baseline response

% GLM annotation
glm_params.annotation = sprintf('LocalizerGLM_%iruns',length(init_params.functionals));

end



