function err = functionalPreprocessing(session, init_params, clip, stc, QA)
% Automated preprocessing of fMRI data 
% using vistasoft functions (https://github.com/vistalab/vistasoft). 
% 
% INPUTS functionalPrepcrocessing(session, init_params, clip, stc, QA)
% 1) session: name of session to analyze (string)
% 2) init_params: optional preprocessing parameters (struct)
% 3) clip: optional number of TRs to clip from beginnning of each run (int)
% 4) stc: optional flag controlling slice time correction (logical)
% 5) QA: optional flag controlling whether analysis exists if QA checks
% fail (logical)
%

% AS 8/2018
% AR 09/2018
% MN 09/2018


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
if nargin < 6 || isempty(QA); QA = false; end
if stc == 1; stc = true; end
if stc == 0; stc = false; end
if QA == 1; QA = true; end
if QA == 0; QA = false; end
if ~islogical(stc)
    fprintf('Error: stc argument must be a logical. \n\n'); return;
end
if ~islogical(QA)
    fprintf('Error: QA argument must be a logical. \n\n'); return;
end

%Move to session's folder
cd(session)

% set preprocessing parameters if not provided
if nargin < 2 || isempty(init_params)
    [~, init_params] = preprocessingParams(session, clip, stc);
end


% apply canonical transformation to .nii.gz files
for rr = 1:length(init_params.functionals)
  
    niftiWrite(niftiApplyCannonicalXform(niftiRead(init_params.functionals{rr})));
end

niftiWrite(niftiApplyCannonicalXform(niftiRead(init_params.inplane)));
nii = niftiRead(init_params.functionals{1}); nslices = size(nii.data, 3);

% open logfile to track progress of analysis
logFileName = fullfile(session, 'preprocessing_log.txt');
lid = fopen(logFileName, 'w+');
fprintf(lid, 'Starting analysis for session %s. \n\n', session_id);
fprintf('Starting analysis for session %s. \n\n', session_id);


%% Initialize session and preprocess fMRI data

% inititalize vistasoft session and open hidden inplane view
fprintf(lid, 'Initializing vistasoft session directory in: \n%s \n\n', session);
fprintf('Initializing vistasoft session directory in: \n%s \n\n', session);
setpref('VISTA', 'verbose', false); % suppress wait bar
if exist(fullfile(session, 'Inplane'), 'dir') ~= 7
    mrInit(init_params); %Saves mrSESSION.mat under session's folder
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
        hi = AdjustSliceTiming(hi, 0, 'Timed',mrSESSION.functionals(1).sliceOrder);
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
if QA
    for rr = 1:length(init_params.functionals)
        motion_est = L{rr + 1}.YData;
        if max(motion_est(:)) > 2
            fprintf(lid, 'Warning -- Within-scan motion exceeds 2 voxels. \n');
            fprintf('Warning -- Within-scan motion exceeds 2 voxels. \n');
            fprintf(lid,'Exited analysis'); 
            fprintf('Exited analysis');
            ffclose(lid); 
            return; 
        end
        fprintf(lid,'QA checks passed for run %i. ',rr);
        fprintf('QA checks passed for run %i. ',rr);
    end
end

% group motion compensation scans
hi = initHiddenInplane('MotionComp', init_params.scanGroups{1}(1));
hi = er_groupScans(hi, init_params.scanGroups{1});

fprintf(lid, 'Within-scan motion compensation complete. \n\n');
fprintf('Within-scan motion compensation complete. \n\n');

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

fid = fopen(fullfile(session, 'Between_Scan_Motion.txt'), 'r');
motion_est = zeros(length(init_params.functionals) - 1, 3);
for rr = 1:length(init_params.functionals) - 1
    ln = strsplit(fgetl(fid), ' ');
    motion_est(rr, 1) = str2double(ln{8});
    motion_est(rr, 2) = str2double(ln{11});
    motion_est(rr, 3) = str2double(ln{14});
end
fclose(fid);
if QA
    if max(motion_est(:)) > 2
        fprintf(lid, 'Warning -- Between-scan motion exceeds 2 voxels. \nExited analysis.');
        fprintf('Warning -- Between-scan motion exceeds 2 voxels. \nExited analysis.');
    	fclose(lid); return; 
    else
        fprintf(lid,'QA checks passed. \n\n');
        fprintf('QA checks passed. \n\n');
    end
end
fprintf(lid, 'Between-scan motion compensation complete.\n\n');
fprintf('Between-scan motion compensation complete.\n\n');

%% Write parameters to logfile 


fprintf(lid, 'Preprocessing for %s is complete! \n\n', session_id);
fprintf('Preprocessing for %s is complete! \n', session_id); 

% add MATLAB and Mr Vista Version to logfile 
fprintf(lid,['---------------------------------------------------','\n\n']);

fprintf(lid,['MATLAB version ',version,'\n\n']);
load mrSESSION.mat
fprintf(lid,['mrVista Version ',mrSESSION.mrVistaVersion,'\n\n']);

% add all parameters used to logfile
fprintf(lid,['---------------------------------------------------','\n\n']);

load mrInit_params.mat
% initialization params
fprintf(lid,['Initialization parameters used\n\n',evalc('disp(params)')]);
fprintf(lid,['including: functionals\n\n',evalc('disp(params.functionals(:))')]);
fprintf(lid,['keepFrames\n\n',evalc('disp(params.keepFrames)')]);
fprintf(lid,['parfiles\n\n',evalc('disp(params.parfile(:))')]);

fprintf(lid,['---------------------------------------------------','\n\n']);

% scan params
for l = 1:length(dataTYPES(1).scanParams), fprintf(lid,['Original data type scan ',num2str(l),' params:\n\n',l,evalc( 'disp(dataTYPES(1).scanParams(l))' )]), end

fprintf(lid,['---------------------------------------------------','\n\n']);


% close file
fclose(lid);
err = 0;

%Move cd back from session
cd ..

%Clear workspace
clearvars -except err

end
