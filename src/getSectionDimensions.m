function [W,H,t,CStype] = getSectionDimensions(info)
%GETSECTIONDIMENSIONS choose from the following options:
%   C1 = 2x1x(1/8)
%   C2 = 3x1.5x(3/16)
%   C3 = 2x1x(1/4)
%   I1 = 1x1.95x.05
%   I2 = 2x2x(1/8)
%   I3 = 2.375x1x(1/4)
%   R1 = 1x1x(1/16)
%   R2 = 2x2x(1/16)
%   R3 = 2x2x(1/8)

    CStype = info(1);
    subtype = str2double(info(2));

    if CStype == 'C'
        if subtype == 1
            W = 2;
            H = 1;
            t = 1/8;
        elseif subtype == 2
            W = 3;
            H = 1.5;
            t = 3/16;
        elseif subtype == 3
            W = 2;
            H = 1;
            t = 1/4;
        else
            error('Invalid cross section subtype');
        end
    elseif CStype == 'I'
        if subtype == 1
            W = 1;
            H = 1.95;
            t = .05;
        elseif subtype == 2
            W = 2;
            H = 2;
            t = 1/8;
        elseif subtype == 3
            W = 2.375;
            H = 1;
            t = 1/4;
        else
            error('Invalid cross section subtype');
        end
    elseif CStype == 'R'
        if subtype == 1
            W = 1;
            H = 1;
            t = 1/16;
        elseif subtype == 2
            W = 2;
            H = 2;
            t = 1/16;
        elseif subtype == 3
            W = 2;
            H = 2;
            t = 1/8;
        else
            error('Invalid cross section subtype');
        end
    else
        error('Invalid cross section type');
    end
end

