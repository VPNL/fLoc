% This script should be run on Matlab 2017b, GLNXA64.
% 
% EXAMPLE USAGE
%       /software/matlab/r2017b/bin/matlab -nodesktop -r fLocGearRun_Build

% Check that we are running a compatible version
if (strfind(version, '9.3.0') ~= 1) || (strfind(computer, 'GLNXA64') ~= 1)
    error('You must compile this function using R2017b (9.3.0.713579) 64-bit (glnxa64). You are using %s, %s', version, computer);
end

% Download the source code
disp('Cloning source code...');
system('git clone -b gear https://github.com/vpnl/fLoc');
system('git clone https://github.com/vistalab/vistasoft');

% Set paths
disp('Adding paths to build scope...');
restoredefaultpath;
addpath(genpath(fullfile(pwd, 'fLoc')));
rmpath(genpath(fullfile(pwd, 'fLoc', '.git')));
addpath(genpath(fullfile(pwd, 'vistasoft')));
rmpath(genpath(fullfile(pwd, 'vistasoft', '.git')));

% Compile
disp('Running compile code...');
mcc -m fLoc/functions/fLocGearRun.m

% Clean up
disp('Cleaning up...')
rmdir(fullfile(pwd, 'fLoc'), 's')
rmdir(fullfile(pwd, 'vistasoft'), 's')

disp('Done!');
exit
