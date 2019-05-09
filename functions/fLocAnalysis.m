function err = fLocAnalysis(session, init_params, glm_params, clip, QA)
% 
% Automated analysis of fMRI data from fLoc funcional localizer experiment 
% using vistasoft functions (https://github.com/vistalab/vistasoft). 
% 
% err = fLocAnalysis(session, [init_params], [glm_params], clip, [QA])
%
% INPUTS
% 1) session: fullpath to scanning session directory in ~/fLoc/data/ that 
%             is being analyzed (string)
% 2) init_params: optional preprocessing parameters organized into a
%                 structure appropriate for vistasoft's mrInit function
% 3) glm_parms: optional GLM analysis parameters organized into a structure
%               appropriate for vistasoft's er_setParams
% 4) clip: number of TRs to clip from beginnning of each run (int)
% 5) QA: optional flag controlling whether analysis will return if
%        within scan or between scan motion exceeds 2 voxels (boolean, default is
%        false)
%
% OUTPUT
% 1) err: 1 if analysis terminated with an error, 0 if analysis completed
% 
% Each session directory must contain the following files
% 1) An inplane nifti containing 'inplane' in the nifti name and ending in
%    nii.gz
% 2) Functional nifti's ending in runX.nii.gz where X is the corresponding
%    run number
% 3) Parfiles ending in runX.par where X is the corresponding run number
%
% By default the code generates the following voxel-wise parameters maps: 
% Beta values, model residual error, proportion of variance explained, and
% GLM contrasts (t-values). All parameter maps are saved as .mat and nifti 
% files in session/Inplane/GLMs/ and can be viewed in vistasoft. The code 
% also writes a file named "fLocAnalysis_log.txt" that logs progress of the 
% analysis in vistasoft, and saves input and glm parameters as 
% fLocAnalysisParams.mat. If there are 10 conditions specified, 15 contrast
% maps will be generated. 10 maps will contrast each individual condition
% versus all others. The other 5 maps will contrast conditions 1 and 2 vs
% all others, 3 and 4 versus all others, and so on. If there are not 10
% conditions specified in the parfiles, then the maps generated will
% contrast each individual condition versus all others.
% 
% AS 8/2018
% AR & MN 09/2018


%% Check inputs and get analysis parameters

err = 1;

% check for correct MATLAB version
vers = version;
year = str2num(vers(end-5:end-2));
if year < 2016
    fprintf('Error: fLocAnalysis requires MATLAB version 2016 or later');
    return;
end

% check session argument and get session_id
if nargin < 1 || isempty(session) || ~(exist(session, 'dir') == 7)
    fprintf('Error: path to "session" data directory not found. \n\n'); return;
else
    [~, session_id] = fileparts(session);
end

% check and set default for clip argument
if nargin < 4 || isempty(clip); clip = 0; end
if rem(clip, 1) ~= 0
    fprintf('Error: clip arguement must be an integer. \n\n'); return;
end

% check and set default for QA argument
if nargin < 6 || isempty(QA); QA = false; end
if QA == 1; QA = true; end
if QA == 0; QA = false; end
if ~islogical(QA)
    fprintf('Error: QA argument must be a logical. \n\n'); return;
end

% move to session's folder
cd(session)

% set preprocessing parameters if not provided
if nargin < 2 || isempty(init_params)
    [~, init_params, dglm_params] = fLocAnalysisParams(session, clip);
end

% set GLM analysis parameters if not provided
if nargin < 3 || isempty(glm_params)
    glm_params = dglm_params;
end

% save init_params and glm_params
save fLocAnalysisParams.mat init_params glm_params


% use mri convert (instead of canonicalXform) on the functionals and the inplane.
% this change has been made to account for the problem of mixed up axes in some of
% the sessions.
for rr = 1: length(init_params.functionals)
    unix([ sprintf('mri_convert --force_ras_good %s %s ', init_params.functionals{rr}, init_params.functionals{rr}) ])
end

unix([ sprintf('mri_convert --force_ras_good %s %s ', init_params.inplane, init_params.inplane) ])


nii = readFileNifti(init_params.functionals{1}); nslices = size(nii.data, 3);

% open logfile to track progress of analysis
logFileName = fullfile(session, 'fLocAnalysis_log.txt');
lid = fopen(logFileName, 'w+');
fprintf(lid, 'Starting analysis for session %s. \n\n', session_id);
fprintf('Starting analysis for session %s. \n\n', session_id);

%% Initialize session

% inititalize vistasoft session and open hidden inplane view
fprintf(lid, 'Initializing vistasoft session directory in: \n%s \n\n', session);
fprintf('Initializing vistasoft session directory in: \n%s \n\n', session);
setpref('VISTA', 'verbose', false); % suppress wait bar
if exist(fullfile(session, 'Inplane'), 'dir') ~= 7
    mrInit(init_params); % saves mrSESSION.mat under session's folder
end
hi = initHiddenInplane('Original', 1);

%% Within-scan motion

% run within-scan motion compensation
fprintf(lid, 'Starting within-scan motion compensation... \n');
fprintf('Starting within-scan motion compensation... \n');
setpref('VISTA', 'verbose', false); % suppress wait bar
if exist(fullfile(session, 'Images', 'Within_Scan_Motion_Est.fig'), 'file') ~= 2
    hi = motionCompSelScan(hi, 'MotionComp', 1:length(init_params.functionals), ...
        init_params.motionCompRefFrame, init_params.motionCompSmoothFrames);
    saveSession; close all;
end

% check to see if there is too much motion
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

fprintf(lid, 'Within-scan motion compensation complete. \n\n');
fprintf('Within-scan motion compensation complete. \n\n');

%% Between-scan motion

% group motion compensation scans
hi = initHiddenInplane('MotionComp', init_params.scanGroups{1}(1));
hi = er_groupScans(hi, init_params.scanGroups{1});

% run between-scan motion compensation
fprintf(lid, 'Starting between-scan motion compensation... \n');
fprintf('Starting between-scan motion compensation... \n');
if exist(fullfile(session, 'Between_Scan_Motion.txt'), 'file') ~= 2
    hi = initHiddenInplane('MotionComp', 1);
    baseScan = 1; targetScans = 1:length(init_params.functionals);
    [hi, M] = betweenScanMotComp(hi, 'MotionComp_RefScan1', baseScan, targetScans);
    %%%%%%%%%%%%%%% changed this to create local paths MN 12/2018 %%%%%%%%
    % fname = fullfile(session, 'Inplane', 'MotionComp_RefScan1', 'ScanMotionCompParams');
     fname = fullfile('Inplane', 'MotionComp_RefScan1', 'ScanMotionCompParams');
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    save(fname, 'M', 'baseScan', 'targetScans');
    hi = selectDataType(hi, 'MotionComp_RefScan1');
    saveSession; close all;
end

% calculate between-scan motion
fid = fopen(fullfile(session, 'Between_Scan_Motion.txt'), 'r');
motion_est = zeros(length(init_params.functionals) - 1, 3);
for rr = 1:length(init_params.functionals) - 1
    ln = strsplit(fgetl(fid), ' ');
    motion_est(rr, 1) = str2double(ln{8});
    motion_est(rr, 2) = str2double(ln{11});
    motion_est(rr, 3) = str2double(ln{14});
end
fclose(fid);

% check to see if there is too much motion
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

%% Apply GLM

% complile list of all conditions in parfiles
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

% initialize new inplane, group scans, and set glm parameters and parfiles
hi = initHiddenInplane('MotionComp_RefScan1', init_params.scanGroups{1}(1));
hi = er_groupScans(hi, init_params.scanGroups{1});
er_setParams(hi, glm_params);
hi = er_assignParfilesToScans(hi, init_params.scanGroups{1}, init_params.parfile);
saveSession; close all;

% run GLM
fprintf(lid, 'Performing GLM analysis for %s... \n\n', session);
fprintf('Performing GLM analysis for %s... \n\n', session);
hi = initHiddenInplane('MotionComp_RefScan1', init_params.scanGroups{1}(1));
hi = applyGlm(hi, 'MotionComp_RefScan1', init_params.scanGroups{1}, glm_params);

%% Compute contrast maps

% store functional nifti data fields
functionalNifti = readFileNifti(init_params.functionals{1});
% making a director for nifti maps
mkdir Inplane/GLMs/NiftiMaps

hi = initHiddenInplane('GLMs', 1);
% if there are 10 conditions, contrast ...
%   - 1&2 vs. all others, 3&4 vs. all others, and so on
%   - 1 vs. all not 2, 2 vs. all not 1, 3 vs. all not 4, and so on
if length(cond_num_list) == 10
    for cc = 1:2:length(cond_num_list)
        % Contrasting domain vs. all other domains
        active_conds = [cc cc + 1];
        control_conds = setdiff(cond_num_list, active_conds);
        contrast_name = [strcat(cond_list{cc:cc + 1}) '_vs_all'];
        hi = computeContrastMap2(hi, active_conds, control_conds, ...
            contrast_name, 'mapUnits','T');
        % storing contrast map as nifti
        niftiFileName = [contrast_name,'.nii.gz'];
        contrastNifti = contrastMap2Nii(hi.map{1},niftiFileName,...
                                        functionalNifti);
        % saving nifti under Inplane/GLMs/NiftiMaps
        cd Inplane/GLMs/NiftiMaps
        writeFileNifti(contrastNifti);
        cd ../../..
        
        % Contrasting category vs. all other categories not in domain
        domain_conds = [cc cc + 1];
        j = 1;
        for i = 0:1
            active_conds = cc + i;
            control_conds = setdiff(cond_num_list, domain_conds);
            contrast_name = [strcat(cond_list{cc + i}) '_vs_all_except_' ...
                             strcat(cond_list{cc + j})];
            hi = computeContrastMap2(hi,active_conds,control_conds,...
                                     contrast_name,'mapUnits','T');
            % Storing contrast map as nifti
            niftiFileName = [contrast_name,'.nii.gz'];
            hi = computeContrastMap2(hi, active_conds, control_conds, ...
            contrast_name, 'mapUnits','T');
            % storing contrast map as nifti
            niftiFileName = [contrast_name,'.nii.gz'];
            contrastNifti = contrastMap2Nii(hi.map{1},niftiFileName,...
                                        functionalNifti);
            % saving nifti under Inplane/GLMs/NiftiMaps
            cd Inplane/GLMs/NiftiMaps
            writeFileNifti(contrastNifti);
            cd ../../..
            
            % move to next condition
            j = j - 1;
        end
            
    end
end
% for any number of conditions, contrast each individual condition with all
% others
for cc = 1:length(cond_num_list)
	active_conds = cc; control_conds = cond_num_list(cond_num_list ~= cc);
	contrast_name = [cond_list{cc} '_vs_all'];
	hi = computeContrastMap2(hi, active_conds, control_conds, ...
                             contrast_name, 'mapUnits','T');
    % storing contrast map as nifti
    niftiFileName = [contrast_name,'.nii.gz'];
    contrastNifti = contrastMap2Nii(hi.map{1},niftiFileName,...
                                    functionalNifti);
    % saving nifti under Inplane/GLMs/NiftiMaps
    cd Inplane/GLMs/NiftiMaps
    writeFileNifti(contrastNifti);
    cd ../../..
end

fprintf(lid, 'GLM parameter maps saved in: \n%s/GLMs/... \n\n', session);
fprintf('GLM parameter maps saved in: \n%s/GLMs/... \n\n', session);

fprintf(lid, 'fLocAnalsis for %s is complete! \n\n', session_id);
fprintf('fLocAnalsis for %s is complete! \n', session_id); 

%% Add documentation

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
for l = 1:length(dataTYPES(1).scanParams)
    fprintf(lid,['Original data type scan ',num2str(l),' params:\n\n',l,evalc( 'disp(dataTYPES(1).scanParams(l))' )]);
end
fprintf(lid,['GLM data type scan params:\n\n',evalc('disp(dataTYPES(4).scanParams)')]);
fprintf(lid,['---------------------------------------------------','\n\n']);
% GLM params
fprintf(lid,['Event analysis parameters used\n\n',evalc('disp(dataTYPES(length(dataTYPES)).eventAnalysisParams)')]);

% close log file
fclose(lid);
err = 0;

%Move directory back to fLoc from session
cd ..

%Clear workspace
clearvars -except err

end
