function err = fLocGearRun(session, config_file, out_dir)
% Generate data structures of vistasoft parameters for preprocessing and
% analyzing fLoc data with a GLM using a Flywheel gear.
%
% INPUTS
% 1) session -- path to data directory in Flywheel (char array)
% 2) config -- path to Flywheel config file (char array)
%
% OUPUTS
% 1) session -- path to data directory in Flywheel (char array)
% 2) init_params -- parameters for initialization/preprocessing (struct)
% 3) glm_params -- parameters for running GLM analysis (struct)
%
% AS 8/2018

%% Parse config file for params.

% Read the json file
config = jsondecode(fileread(config_file));

% Set the params
clip = config.config.clip;

% Currently we're not setting those params in the config/manifest
% file, thus we set the defaults below.
[~, init_params, glm_params] = fLocAnalysisParams(session, clip);

%% Run fLoc Analysis
err = fLocAnalysis(session, init_params, glm_params, clip);

if err == 0
    zip(fullfile(out_dir, 'fLoc_output.zip'), session);
    delete(session)

clear global

end
