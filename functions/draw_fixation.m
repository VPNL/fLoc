function draw_fixation(windowPtr, center, color)
% Draws round fixation marker in the center of the window by superimposing
% vertical and horizontal bars.
% Written by KGS Lab
% Edited by AS 8/2014

% find center of window
center_x = center(1);
center_y = center(2);

% draw horizontal bar
Screen('FillRect', windowPtr, color, [center_x - 3 center_y - 2 center_x + 3 center_y + 2]);

% draw vertical bar
Screen('FillRect', windowPtr, color, [center_x - 2 center_y - 3 center_x + 2 center_y + 3]);

end
