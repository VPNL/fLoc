function [session, init_params, glm_params] = fLocGearRun(session, config)
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


%% Run fLoc Analysis
err = fLocAnalysis(session, init_params, glm_params, clip, QA);

clear global


end
