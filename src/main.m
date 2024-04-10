% SCISSOR JACK ANALYTICAL MODEL
% nomenclature:
% p_ = parameter - to be changed by the user when performing optimization
% o_ = output - results of the model

clear;
clc;

%%---------------------------------------------MODEL INPUTS-------------------------------------------------%%
% ALL UNITS IN INCHES

% to be changed by the user:
p_pin_D = .5;                          % diameter of the pin        
p_crossBar_D = 0.5;                     % diameter of the cross bar
p_sectionStockSelection = 'R3';         % see the function 'getSectionDimensions' for details on the options (I1, I2, I3, C1, C2, C3, R1, R2, R3)


% NOT to be changed by the user:
F = 2000;                             % applied force (lb) - force the jack will lift
Ld = 10;                          % length of the diagonal member from pin to pin (center to center)
Lap = 1.5;                   % length of the diagonal and vertical members after the pin  
Lv = 2;                       % length of the vertical member from pin to pin (center to center)
Lcb_start = 8.7;               % length of the cross bar IN THE STARTING POSITION (fully extended i.e. the shortest length or the cross-bar, it will grow from here
% crossBar L ending                     - this will be calculated later, it will be however big it needs to be to allow for the jack to raise the desired height 
Lextend = 6;                      % desired extension of the jack (height the jack will raise the load)

% material properties of titanium
Density_Ti = 0.16;                  % (lb/in^3)
Sy_Ti = 128000;                     % (psi) - yield strength
Sut_Ti = 138000;                    % (psi) - ultimate tensile strength
Sf_Ti = 74000;                      % (psi) - fatigue strength
G_Ti = 16500;                       % (psi) - modulus of elasticity
Poisson_Ti = 0.3;                   %       - poisson's ratio
% decide dimensions of the cross section of the diagonal and vertical members based on 'p_stockSectionSelection'
[W_section, H_section, t_section, sectionType_dv] = getSectionDimensions(p_sectionStockSelection);



%%---------------------------------------------CROSS SECTION CALCS-------------------------------------------------%%
CS = struct('A',0,'Ix',0,'Iy',0);   % Cross Section of the Diagonal and Vertical Members
switch sectionType_dv
    case 'I'
        % I-Beam
        [CS.A, CS.Ix, CS.Iy] = calculateSectionProperties_Ibeam(W_section, H_section, t_section);

    case 'C'
        % C-Channel
        [CS.A, CS.Ix, CS.Iy] = calculateSectionProperties_Channel(W_section, H_section, t_section);

    case 'R'
        % Hollow Rectangular
        [CS.A, CS.Ix, CS.Iy] = calculateSectionProperties_Rectangle(W_section, H_section, t_section);

    otherwise
        error('Invalid input for p_diagSectionType. Must be "I", "C", or "R"');
end

CS_CB = struct('A',0,'Ix',0,'Iy',0);      % Cross Section of the Cross Bar
CS_CB.A = pi*(p_crossBar_D/2)^2;          % cross section area of the cross bar
CS_CB.Ix = pi*(p_crossBar_D/2)^4/4;       % moment of inertia of the cross bar
CS_CB.Iy = CS.Ix;


%%---------------------------------------------GEOMETRY CALCS-------------------------------------------------%%

% calculate the height of the scissor jack in the starting position (fully extended)
startingHeight = 2*sqrt( (Ld)^2 - (Lcb_start/2)^2);
% calculate the height of the scissor jack in the ending position (fully retracted)
endingHeight = startingHeight - Lextend;
% calculate the length of the cross bar in the ending position (fully retracted)
Lcb_end = 2*sqrt( (Ld)^2 - (endingHeight/2)^2); % should be 16 inches

%%---------------------------------------------WEIGHT CALCS-------------------------------------------------%%
% calculate the total volume of the scissor jack
Vtotal = (CS_CB.A*Lcb_start) + (4*CS.A*(Ld+(2*Lap))) + (2*CS.A*(Lv+Lap));
% calculate the total volume of the scissor jack
o_totalWeight = Vtotal * Density_Ti;

%%---------------------------------------------MEMBER FORCES CALCS-------------------------------------------------%%

% NOTE: you will need to do this twice for the fully extended and fully retracted positions
[Fcb_start, Fd_start, Fv_start] = calculateMemberForces(F, Ld, Lcb_start);
[Fcb_end, Fd_end, Fv_end]       = calculateMemberForces(F, Ld, Lcb_end);

%%---------------------------------------------STRESS CALCS-------------------------------------------------%%
[stress_cb_start, stress_d_start, stress_v_start] = calculateMemberStresses(Fcb_start, Fd_start, Fv_start, CS_CB, CS);
[stress_cb_end, stress_d_end, stress_v_end] = calculateMemberStresses(Fcb_end, Fd_end, Fv_end, CS_CB, CS);

% calculate the maximum stress
% Store variable names in a cell array
variables = {'stress_cb_start', 'stress_d_start', 'stress_v_start', 'stress_cb_end', 'stress_d_end', 'stress_v_end'};
% Get the maximum stress value
o_maxStress = max([stress_cb_start, stress_d_start, stress_v_start, stress_cb_end, stress_d_end, stress_v_end]);
% Find the index of the variable with the maximum stress
index = find([stress_cb_start, stress_d_start, stress_v_start, stress_cb_end, stress_d_end, stress_v_end] == o_maxStress);
% Get the variable name corresponding to the maximum stress
o_maxStress_location = variables{index};

%%---------------------------------------------FAILURE MODE CALCS-------------------------------------------------%%
ridiculousValue = 70e70;            
%------DIAGONAL MEMBER-------
% tearout
SF_d_tearout_start = calculateSF_diag_tearout(Sf_Ti, Fd_start, Lap, t_section, p_pin_D, sectionType_dv);
SF_d_tearout_end = calculateSF_diag_tearout(Sf_Ti, Fd_end, Lap, t_section, p_pin_D, sectionType_dv);
% axial
SF_d_axial_start = calculateSF_diag_axial(Sf_Ti, stress_d_start);
SF_d_axial_end = calculateSF_diag_axial(Sf_Ti, stress_d_end);
% bearing
SF_d_bearing_start = calculateSF_diag_bearing(Sf_Ti, Fd_start, p_pin_D, sectionType_dv);
SF_d_bearing_end = calculateSF_diag_bearing(Sf_Ti, Fd_end, p_pin_D, sectionType_dv);

%------CROSS BAR-------
% bearing
SF_cb_bearing_start = ridiculousValue;
SF_cb_bearing_end = ridiculousValue;
% buckling
SF_cb_buckling_start = ridiculousValue;
SF_cb_buckling_end = ridiculousValue;
%------PIN-------
% shear
SF_pin_shear_start = calculateSF_pin_shear(Sf_Ti, Fd_start, p_pin_D, sectionType_dv);
SF_pin_shear_end = calculateSF_pin_shear(Sf_Ti, Fd_end, p_pin_D, sectionType_dv);
% bearing
SF_pin_bearing_start = calculateSF_pin_bearing(Sf_Ti, Fcb_start, p_pin_D, t_section, sectionType_dv);
SF_pin_bearing_end = calculateSF_pin_bearing(Sf_Ti, Fcb_end, p_pin_D, t_section, sectionType_dv);


%--------decide the dominant faliure mode (lowest safety factor)--------
failureNames = {'SF_d_tearout_start', 'SF_d_tearout_end', 'SF_d_axial_start', 'SF_d_axial_end', 'SF_d_bearing_start','SF_d_bearing_end', ...
                'SF_cb_bearing_start', 'SF_cb_bearing_end', 'SF_cb_buckling_start', 'SF_cb_buckling_end', ...
                'SF_pin_shear_start', 'SF_pin_shear_end', 'SF_pin_bearing_start', 'SF_pin_bearing_end'};

failureVals = [SF_d_tearout_start, SF_d_tearout_end, SF_d_axial_start, SF_d_axial_end, SF_d_bearing_start, SF_d_bearing_end, ...
               SF_cb_bearing_start, SF_cb_bearing_end, SF_cb_buckling_start, SF_cb_buckling_end, ...
               SF_pin_shear_start, SF_pin_shear_end, SF_pin_bearing_start, SF_pin_bearing_end];

% Find the minimum safety factor
o_failModeSafetyFactor = min(failureVals);
% Find the index of the minimum safety factor
fMode_Index = find(failureVals == o_failModeSafetyFactor);
fMode_info = failureNames{fMode_Index};
[o_failureMode, o_failureModeLocation, o_failureModeOrientation] = getFailureModeInfo(fMode_info);




%%---------------------------------------------SUMMARY OF OUTPUTS-------------------------------------------------%%

% FIXME: these will be calculated throughout the model. just placeholders for now
% 1. total weight of the scissor jack (including pins, diagonal and vertical members, and cross bar) - DONE 
% 2. maximum stress (stress in the member under maximum stress) - DONE
% 3. failure mode and related info
       

% define result as strings
string1 = ['Total Weight:                           '  num2str(o_totalWeight)           '       (lb)                                                ']; 
string2 = ['Max Stress:                             '  num2str(o_maxStress)             '       (psi)'];     
string21 =['----Location:                             '  o_maxStress_location];
string3 = ['Dominant Failure Mode:          '  o_failureMode];
string4 = ['----Location:                             '  o_failureModeLocation];
string5 = ['----Safety Factor:                     '  num2str(o_failModeSafetyFactor)  ''];
string6 = ['----orientation:                          '  num2str(o_failureModeOrientation)  ''];
 


% Concatenate the strings
result_str = join({string1, string2, string21 string3, string4, string5, string6}, newline);


% Display the concatenated string in a message box
msgbox(result_str, 'Results');



%----------------------------------write simulation details and results to a text file----------------------------------%
% open a file for writing
filename = 'simulationResults.txt';
fileID = fopen(filename,'a');
% Check if the file opened successfully
if fileID == -1
    error('Unable to open file for writing.');
end
% check if the file is empty
file_info = dir(filename);
if file_info.bytes == 0
    % write the header
    fprintf(fileID, ['date/time,'...
        'cs type,W cs,H cs,t cs,D pin,D cross bar,' ...
        'F applied force,L diagonal,L vert,L cross bar (starting),' ...
        'weight,max stress value,max stress location,dominant failure mode,failure location,failure safety factor,failure orientation,' ...
        'SF_d_tearout_start,SF_d_tearout_end,SF_d_axial_start,SF_d_axial_end,SF_d_bearing_start,SF_d_bearing_end,' ...
        'SF_cb_bearing_start,SF_cb_bearing_end,SF_cb_buckling_start,SF_cb_buckling_end,' ...
        'SF_pin_shear_start,SF_pin_shear_end,SF_pin_bearing_start,SF_pin_bearing_end,'...
        'stress_cb_start,stress_d_start,stress_v_start,stress_cb_end,stress_d_end,stress_v_end,' ...
        'Fcb_start,Fd_start,Fv_start,Fcb_end,Fd_end,Fv_end'...
        ]);
    fprintf(fileID, newline);
end
% write the results to the file
datetime = datestr(now,'mm/dd HH:MM:SS');
fileOutput = [datetime, ...
                sectionType_dv, string(W_section), string(H_section), string(t_section), string(p_pin_D), string(p_crossBar_D), ...
                string(F), string(Ld), string(Lv), string(Lcb_start), ...
                string(o_totalWeight), string(o_maxStress), o_maxStress_location, o_failureMode, o_failureModeLocation, string(o_failModeSafetyFactor), string(o_failureModeOrientation), ...
                string(SF_d_tearout_start), string(SF_d_tearout_end), string(SF_d_axial_start), string(SF_d_axial_end), string(SF_d_bearing_start), string(SF_d_bearing_end), ...
                string(SF_cb_bearing_start), string(SF_cb_bearing_end), string(SF_cb_buckling_start), string(SF_cb_buckling_end), ...
                string(SF_pin_shear_start), string(SF_pin_shear_end), string(SF_pin_bearing_start), string(SF_pin_bearing_end), ... 
                string(stress_cb_start), string(stress_d_start), string(stress_v_start), string(stress_cb_end), string(stress_d_end), string(stress_v_end), ...
                string(Fcb_start), string(Fd_start), string(Fv_start), string(Fcb_end), string(Fd_end), string(Fv_end)  
             ];

outputString = join(fileOutput,',');
fprintf(fileID, outputString);
fprintf(fileID, '\n');

% Close the file
fclose(fileID);
%-----------------------------------------------------------------END---------------------------------------------------------------------


