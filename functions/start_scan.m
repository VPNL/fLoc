function [status, start_time] = start_scan
% This code will trigger the 3T GE scanner at CNI using the E-prime trigger
% cable. --Michael 09/30/2013

try
    s = serial('/dev/tty.usbmodem12341', 'BaudRate', 57600);
    fopen(s);
    fprintf(s, '[t]');
    fclose(s);
catch
    err
end

if exist('err','var') == 0
    start_time  = GetSecs;
    status = 0;
else
    start_time = GetSecs;
    status = 1;
end

end
