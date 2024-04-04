% SCISSOR JACK ANALYTICAL MODEL
% nomenclature:
% p_ = parameter - to be changed by the user when performing optimization
% o_ = output - results of the model

clear;
clc;

%%---------------------------------------------MODEL INPUTS-------------------------------------------------%%
% ALL UNITS IN INCHES

% to be changed by the user:
p_pin_D = 0.5;                          % diameter of the pin        
p_crossBar_D = 0.5;                     % diameter of the cross bar
p_sectionStockSelection = 'I1';         % see the document 'p_sectionStockSelection' for details on the options (I1, I2, I3, C1, C2, C3, R1, R2, R3)


% NOT to be changed by the user:
F = 2000;                             % applied force (lb) - force the jack will lift
Ld = 12;                          % length of the diagonal member from pin to pin (center to center)
Lap = 2;                   % length of the diagonal and vertical members after the pin  
Lv = 2;                       % length of the vertical member from pin to pin (center to center)
Lcb_start = 6;               % length of the cross bar IN THE STARTING POSITION (fully extended i.e. the shortest length or the cross-bar, it will grow from here
% crossBar L ending                     - this will be calculated later, it will be however big it needs to be to allow for the jack to raise the desired height 
Lextend = 6;                      % desired extension of the jack (height the jack will raise the load)

% material properties of titanium
Density_Ti = 0.16;                  % (lb/in^3)
Sy_Ti = 128000;                     % (psi) - yield strength
Sut_Ti = 138000;                    % (psi) - ultimate tensile strength
Sf_Ti = 34800;                      % (psi) - fatigue strength
G_Ti = 16500;                       % (psi) - modulus of elasticity
Poisson_Ti = 0.3;                   %       - poisson's ratio
% decide dimensions of the cross section of the diagonal and vertical members based on 'p_stockSectionSelection'
sectionType_dv = 'C';                % 'I'=I-Beam , 'C'=C-Channel , 'R'= hollow rectangular                                                  % FIXME: add a decision tree here!
W_section = 1;                         % width of the diagonal/vertical member cross section
H_section = 1;                         % height of the diagonal/vertical member cross section
t_section = 1/16;                      % thickness of the diagonal/vertical member cross section



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
Lcb_end = 2*sqrt( (Ld)^2 - (endingHeight/2)^2);

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
%------DIAGONAL MEMBER-------
% tearout
SF_d_tearout_start = 0;
SF_d_tearout_end = 0;
% axial
SF_d_axial_start = calculateSF_diag_axial(Sy_Ti, stress_d_start);
SF_d_axial_end = calculateSF_diag_axial(Sy_Ti, stress_d_end);
% bearing
SF_d_bearing_start = 0;
SF_d_bearing_end = 0;

%------CROSS BAR-------
% bearing
SF_cb_bearing_start = 0;
SF_cb_bearing_end = 0;
% buckling
SF_cb_buckling_start = 0;
SF_cb_buckling_end = 0;
%------PIN-------
% shear
SF_pin_shear_start = 0;
SF_pin_shear_end = 0;
% bearing
SF_pin_bearing_start = 0;
SF_pin_bearing_end = 0;







%%---------------------------------------------SUMMARY OF OUTPUTS-------------------------------------------------%%

% FIXME: these will be calculated throughout the model. just placeholders for now
% 1. total weight of the scissor jack (including pins, diagonal and vertical members, and cross bar) - DONE 
% 2. maximum stress (stress in the member under maximum stress) - DONE
% 3. failure mode and related info
o_failureMode = 'xxx';                  % which failure mode failed first (which one has the lowest safety factor) 
o_failureModeLocation = 'xxx';          % where the failure mode occurred (which member or pin)
o_failModeSafetyFactor = 0;             % safety factor of the failed mode
       

% define result as strings
string1 = ['Total Weight:                           '  num2str(o_totalWeight)           '       (lb)                                                ']; 
string2 = ['Max Stress:                             '  num2str(o_maxStress)             '       (psi)'];     
string21 =['----Location:                           '  o_maxStress_location];
string3 = ['Dominant Failure Mode:           '  o_failureMode];
string4 = ['----Location:                           '  o_failureModeLocation];
string5 = ['----Safety Factor:                     '  num2str(o_failModeSafetyFactor)  ''];
 


% Concatenate the strings
result_str = join({string1, string2, string21 string3, string4, string5}, newline);


% Display the concatenated string in a message box
msgbox(result_str, 'Results');


