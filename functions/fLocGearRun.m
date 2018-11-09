function err = fLocGearRun(session, config_file, out_dir, fshome)
% Generate data structures of vistasoft parameters for preprocessing and
% analyzing fLoc data with a GLM using a Flywheel gear.
%
% INPUTS
% 1) session -- path to data directory in Flywheel (char array)
% 2) config -- path to Flywheel config file (char array)
% 3) out_dir -- path to save outputs
% 4) fshome -- path to Freesurfer's directory
%
% OUPUTS
% 1) session -- path to data directory in Flywheel (char array)
% 2) init_params -- parameters for initialization/preprocessing (struct)
% 3) glm_params -- parameters for running GLM analysis (struct)
%
% AS 8/2018

%% Set env and parse config file for params

% Set the env for fs bin
setenv('FREESURFER_HOME', fshome);
setenv('PATH', [getenv('PATH'), ':', fullfile(fshome, 'bin')]);
disp(getenv('FREESURFER_HOME'));
disp(getenv('PATH'));

% Read the json file
config = jsondecode(fileread(config_file));

% Set the params
clip = config.config.clip;

% Currently we're not setting those params in the config/manifest
% file, thus we set the defaults below.
[~, init_params, glm_params] = fLocAnalysisParams(session, clip);

%% Run fLoc Analysis
err = fLocAnalysis(session, init_params, glm_params, clip);

%% Move select files to output and zip outputs
if err == 0
    [base_path, session_label] = fileparts(session);
    [~, subject_code] = fileparts(base_path)
    jpgs = mrvFindFile('*.jpg', session);
    for ii=1:numel(jpgs)
        [~, f, e] = fileparts(jpgs{ii})
        copyfile(jpgs{ii}, fullfile(out_dir, [subject_code, '_', session_label, '-', f, e]));
    end
    logs = mrvFindFile('*log*', session);
    for ii=1:numel(logs)
        [~, f, e] = fileparts(logs{ii})
        copyfile(logs{ii}, fullfile(out_dir, [subject_code, '_', session_label, '-', f, e]))
    end
    zip(fullfile(out_dir, [subject_code, '_', session_label, '-fLoc.zip']), session);
    rmdir(session, 's')

clear global

end
