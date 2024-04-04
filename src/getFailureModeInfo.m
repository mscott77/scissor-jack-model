function [mode, location, orientation] = getFailureModeInfo(info)

    substrings = split(info, '_');
    loc = substrings{2};
    mode = substrings{3};
    orientation = substrings{4};

    % decide the location
    if strcmp(loc, 'd')
        location = 'diagonal';
    elseif strcmp(loc, 'c')
        location = 'cross bar';
    elseif strcmp(loc, 'p')
        location = 'pin';
    else
        location = 'unknown';
    end


end

