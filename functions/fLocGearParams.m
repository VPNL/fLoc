function [init_params, glm_params] = fLocGearParams(session, clip, num_runs)
% Generate data structures of vistasoft parameters for preprocessing and 
% analyzing fLoc data with a GLM using a Flywheel gear. 
%
% INPUTS
% 1) session -- Flywheel exam number (char array)
% 2) clip -- number of TRs to clip from the beginning of each run (int)
% 3) num_runs -- number of localizer runs to analyze (int)
% 
% OUPUTS
% 1) init_params -- parameters for initialization/preprocessing (struct)
% 2) glm_params -- parameters for running GLM analysis (struct)
% 
% AS 8/2018


%% Initialize and modify preprocessing parameters

% get default vistasoft initialization settings
init_params = mrInitDefaultParams;

% necessary fields that can be modified by user
init_params.inplane      % path to inplane file found by gear code (.nii.gz)
init_params.functionals  % paths to fMRI data with filenames (.nii.gz)
init_params.parfile      % paths to stimulus parameter files with filenames (.par)
init_params.clip = clip; % int, number of TRs to clip from beginning of each run (initialize as 0)
% for clipping TRs from countdown, default should be [2] for MUX and [countdown/TR] for non-MUX
init_params.scanGroups = {1:num_runs}; % cell array of scan numbers to group

% necessary fields for motion compensation
init_params.motionCompRefFrame     = 8; % frame number of reference TR for within-scan compensation
init_params.motionCompSmoothFrames = 3; % time window (in TRs) for within-scan compensation
init_params.motionCompRefScan      = 1; % run number of reference scan for between-scans compensation

% necessary fields that cannot be modified (maybe these can be hidden)
init_params.sessionCode = session; % set to Flywheel exam number
init_params.doAnalParams      = 1; % logical, set GLM analysis parameters during intialization
init_params.doSkipFrames      = 1; % logical, clip countdown frames during initialization
init_params.doPreprocessing   = 1; % logcial, do some preprocessing during initialization
init_params.applyGlm          = 0; % logical, apply GLM during initialization
init_params.applyCorAnal      = 0; % logical, unnecessary for GLM analysis
init_params.motionComp        = 0; % logical, wait to do this until later
% set init_params.keeFrames using the value of the "clip" field set above
init_params.keepFrames = repmat([init_params.clip -1], num_runs, 1);
init_params.sliceTimingCorrection = 0; % logical, no slice time correction durin initialization

% unnecessary fields that can be filled in by user
init_params.subject     = ''; % char array with participant ID
init_params.description = ''; % char array describing session
init_params.comments    = ''; % char array of comments
init_params.annotations = {}; % cell array of descriptions for each run


%% Initialize and modify GLM analysis parameters

% get default vistasoft parameters for GLM analysis
glm_params = er_defaultParams;

% necessary fields that can be modified by user
glm_params.detrend       = 1;  % detrending procedure: -1 = linear, 0 = do nothing, 1 = high-pass filter, 2 = quadratic
glm_params.detrendFrames = 20; % cutoff for high-pass filter in cycles/run (if glm_params.detrend = 1)
glm_params.inhomoCorrect = 1;  % time series transforamtion: 0 = do nothing, 1 = divide by mean and convert to PSC, 2 = divide by baseline
glm_params.glmHRF        = 3;  % set the HRF: 0 = deconvolve, 1 = estimate HRF from mean response, 2 = Boynton 1996, 3 = SPM, 4 = Dale 1999; default = 3
glm_params.glmWhiten     = 0;  % logical, controls whitening of data for GLM analysis

% necessary fields that cannot be modified by user
glm_params.eventAnalysis = 1;  % logical, run a standard GLM
glm_params.lowPassFilter = 0;  % logical, do low-pass filtering
glm_params.framePeriod         % TR of fMRI data in seconds
glm_params.glmHRF_params       % generated with HRF depending on glm_params.glmHRF
glm_params.eventsPerBlock      % int, number of TRs per block; can be calculated from parfile and TR

% visulization parameters that do not affect GLM fits
glm_params.ampType    = 'betas'; % type of response amplitudes to visualize: 'difference' (raw), 'betas' (GLM betas), or 'deconvolved'
glm_params.timeWindow = -4:16;   % time window for brute-force averaging of conditions
glm_params.peakPeriod = 6:8;     % time window to estimate peak response
glm_params.bslPeriod  = -4:0;    % time window to estiamte baseline response

end
