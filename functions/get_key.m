function get_key(key, laptopKey)
% Waits until user presses the key specified in first argument.
% Written by KGS Lab
% Edited by AS 8/2014

while 1
    while 1
        [key_is_down, dur, key_code] = KbCheck(laptopKey);
        if key_is_down
            break
        end
    end
    pressed_key = KbName(key_code);
    if ismember(key, pressed_key)
        break
    end
end

end