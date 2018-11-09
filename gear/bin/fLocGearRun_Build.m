% This script should be run on Matlab 2017b, GLNXA64.
% 
% EXAMPLE USAGE
%       /software/matlab/r2017b/bin/matlab -nodesktop -r fLocGearRun_Build

% Check that we are running a compatible version
if (strfind(version, '9.3.0') ~= 1) || (strfind(computer, 'GLNXA64') ~= 1)
    error('You must compile this function using R2017b (9.3.0.713579) 64-bit (glnxa64). You are using %s, %s', version, computer);
end

disp(mfilename('fullpath'));
compileDir = fileparts(mfilename('fullpath'));
if ~strcmpi(pwd, compileDir)
    disp('You must run this code from %s', compileDir);
end


% Download the source code
disp('Cloning source code...');
system('git clone https://github.com/vistalab/vistasoft');

% Set paths
disp('Adding paths to build scope...');
restoredefaultpath;
addpath(genpath(fullfile(pwd, 'vistasoft')));
addpath(genpath('../../fLoc'))

% Compile
disp('Running compile code...');
mcc -v -R -nodisplay -m ../../functions/fLocGearRun.m

% Clean up
disp('Cleaning up...')
rmdir(fullfile(pwd, 'vistasoft'), 's');

disp('Done!');
exit
