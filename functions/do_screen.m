function [w, center] = doScreen
% Opens a full-screen window, sets text properties, and hides the cursor.
% Written by KGS Lab
% Edited by AS 8/2014

% open window and find center
S = Screen('Screens');
screen_num = max(S);
[w, rect] = Screen('OpenWindow', screen_num);
center = rect(3:4) / 2;

% set text properties
Screen('TextFont', w, 'Times');
Screen('TextSize', w, 24);
Screen('FillRect', w, 128);

% hide cursor
HideCursor;

end
