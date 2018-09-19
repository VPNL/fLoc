function [session, init_params] = preprocessingParams(session, clip, stc)
% Generate data structures of vistasoft parameters for preprocessing
%
% INPUTS
% 1) session: name of session to analyze (string)
% 2) clip: number of TRs to clip from beginnning of each run (int)
% 3) stc: flag controlling slice time correction (logical)
% 
% OUPUTS
% 1) session -- name of session to analyze (string)
% 2) init_params -- parameters for initialization/preprocessing (struct)
% 
% AS 8/2018
% AR 9/2018
% MN 9/2018


%% Initialize default parameters for preprocessing and GLM anlaysis

init_params = mrInitDefaultParams;



%% Find paths to data and stimulus files

% find paths to fMRI data and corresponding stimulus parfiles
[~, session_id] = fileparts(session);
niifiles = dir(fullfile(session, '*.nii.gz')); niifiles = {niifiles.name};
niifiles = niifiles(~contains(niifiles,'._')); % Alex made an edit: some file names had a random ._ at the beginning that need to be excluded
parfiles = dir(fullfile(session, '*.par')); parfiles = {parfiles.name};
niipaths = {}; parpaths = {}; num_runs = 0;
while sum(contains(lower(niifiles), ['run' num2str(num_runs + 1) '.nii.gz'])) >= 1
    num_runs = num_runs + 1;
    nii_idx = find(contains(lower(niifiles), ['run' num2str(num_runs) '.nii.gz']), 1);
    niipaths{num_runs} = fullfile(session, niifiles{nii_idx});
    par_idx = find(contains(lower(parfiles), ['run' num2str(num_runs) '.par']), 1);
    if isempty(par_idx)
        fprintf('Error: no .par file found for run %d. \n\n', num_runs); return;
    else
        parpaths{num_runs} = fullfile(session, parfiles{par_idx});
    end
end

%Adding annotation for each run
annotations = {};
for i = 1:length(niipaths)
    annotations{i} = ['localizer_run',num2str(i)];
end

% find path to anatomical inplane scan
inplane_idx = find(contains(lower(niifiles), 'inplane'), 1);
if isempty(inplane_idx)
    fprintf('Warning: no inplane scan found for session %s. Generating pseudo inplane file. \n\n', session_id);
    nii = niftiRead(niipaths{1}); nii.data = mean(nii.data, 4);
    niftiWrite(nii, 'PseudoInplane.nii.gz');
    inplane = fullfile(session, 'PseudoInplane.nii.gz');
else
    inplane = fullfile(session, niifiles{inplane_idx});
end

% get the durations of TR and block
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


%% Initialize and modify preprocessing parameters

% necessary fields that can be modified by user
init_params.inplane     = inplane;  % path to inplane file found by gear code (.nii.gz)
init_params.functionals = niipaths; % paths to fMRI data with filenames (.nii.gz)
init_params.parfile     = parpaths; % paths to stimulus parameter files with filenames (.par)
init_params.clip        = clip;     % int, number of TRs to clip from beginning of each run (initialize as 0)
% for clipping TRs from countdown, default should be [2] for MUX and [countdown/TR] for non-MUX
init_params.scanGroups  = {1:num_runs}; % cell array of scan numbers to group
init_params.sliceTimingCorrection = 0;  % logical, do slice time correction

% necessary fields for motion compensation
init_params.motionCompRefFrame     = 8; % frame number of reference TR for within-scan compensation
init_params.motionCompSmoothFrames = 3; % time window (in TRs) for within-scan compensation
init_params.motionCompRefScan      = 1; % run number of reference scan for between-scans compensation

% necessary fields that cannot be modified (maybe these can be hidden)
init_params.sessionCode = session_id; % char array, local session data directory
init_params.doAnalParams      = 0; % logical, set GLM analysis parameters during intialization
init_params.doSkipFrames      = 1; % logical, clip countdown frames during initialization
init_params.doPreprocessing   = 1; % logcial, do some preprocessing during initialization
init_params.applyGlm          = 0; % logical, apply GLM during initialization
init_params.applyCorAnal      = 0; % logical, unnecessary for GLM analysis
init_params.motionComp        = 0; % logical, wait to do this until later
% set init_params.keeFrames using the value of the "clip" field set above
init_params.keepFrames = repmat([init_params.clip -1], num_runs, 1);

% unnecessary fields that can be filled in by user
init_params.subject     = session_id(1:find(session_id == '_') - 1); % char array with participant ID
init_params.description = 'localizer'; % char array describing session
init_params.comments    = 'Analyzed using fLoc'; % char array of comments
init_params.annotations = annotations; % cell array of descriptions for each run

%Alex noticed that the sessionDir needed to be changed so that the
%mrSESSION.mat file would be added to the session's folder, not to the fLoc
%folder
init_params.sessionDir = session;


end
