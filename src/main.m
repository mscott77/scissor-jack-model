% SCISSOR JACK ANALYTICAL MODEL
% nomenclature:
% p_ = parameter - to be changed by the user when performing optimization
% c_ = constant - pre-defined parameters not to be changed by the user
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
c_diag_L = 12;                          % length of the diagonal member from pin to pin (center to center)
c_lengthAfterPin = 2;                   % length of the diagonal and vertical members after the pin  
c_vertical_L = 2;                       % length of the vertical member from pin to pin (center to center)
c_crossBar_Lstarting = 6;               % length of the cross bar IN THE STARTING POSITION (fully extended i.e. the shortest length or the cross-bar, it will grow from here
% crossBar L ending                     - this will be calculated later, it will be however big it needs to be to allow for the jack to raise the desired height 
c_extension_L = 6;                      % desired extension of the jack (height the jack will raise the load)

% material properties of titanium
c_mtrl_Density = 0.16;                  % (lb/in^3)
c_mtrl_Sy = 128000;                     % (psi) - yield strength
c_mtrl_Sut = 138000;                    % (psi) - ultimate tensile strength
c_mtrl_Sf = 34800;                      % (psi) - fatigue strength
c_mtrl_G = 16500;                       % (psi) - modulus of elasticity
c_mtrl_Poisson = 0.3;                   %       - poisson's ratio
% decide dimensions of the cross section of the diagonal and vertical members based on 'p_stockSectionSelection'
c_diagSectionType = 'C';                % 'I'=I-Beam , 'C'=C-Channel , 'R'= hollow rectangular                                                  % FIXME: add a decision tree here!
c_diagCS_w = 1;                         % width of the diagonal member cross section
c_diagCS_h = 1;                         % height of the diagonal member cross section
c_diagCS_t = 1/16;                      % thickness of the diagonal member cross section



%%---------------------------------------------CROSS SECTION CALCS-------------------------------------------------%%
CS = struct('A',0,'Ix',0,'Iy',0);   % "CS" = Cross Section
switch c_diagSectionType
    case 'I'
        % I-Beam
        [CS.A, CS.Ix, CS.Iy] = calculateSectionProperties_Ibeam(c_diagCS_w, c_diagCS_h, c_diagCS_t);

    case 'C'
        % C-Channel
        [CS.A, CS.Ix, CS.Iy] = calculateSectionProperties_Channel(c_diagCS_w, c_diagCS_h, c_diagCS_t);

    case 'R'
        % Hollow Rectangular
        [CS.A, CS.Ix, CS.Iy] = calculateSectionProperties_Rectangle(c_diagCS_w, c_diagCS_h, c_diagCS_t);

    otherwise
        error('Invalid input for p_diagSectionType. Must be "I", "C", or "R"');
end


% DEBUG: display cross section properties
disp(CS);














%%---------------------------------------------SUMMARY OF OUTPUTS-------------------------------------------------%%

% FIXME: these will be calculated throughout the model. just placeholders for now
% 1. total weight of the scissor jack (including pins, diagonal and vertical members, and cross bar)
o_totalWeight = 0;   
% 2. maximum stress
o_maxStress = 0;                        % maximum stress (stress in the member under maximum stress)
% 3. failure mode and related info
o_failureMode = 'xxx';                  % which failure mode failed first (which one has the lowest safety factor) 
o_failureModeLocation = 'xxx';          % where the failure mode occurred (which member or pin)
o_failModeSafetyFactor = 0;             % safety factor of the failed mode
       

% define result as strings
string1 = ['Total Weight:                           '  num2str(o_totalWeight)           '       (lb)                                                ']; 
string2 = ['Max Stress:                             '  num2str(o_maxStress)             '       (psi)'];     
string3 = ['Failure Mode:                          '  o_failureMode];
string4 = ['Failure Location:                     '  o_failureModeLocation];
string5 = ['Failure Mode Safety Factor:    '  num2str(o_failModeSafetyFactor)  ''];
 


% Concatenate the strings
result_str = join({string1, string2, string3, string4, string5}, newline);


% Display the concatenated string in a message box
msgbox(result_str, 'Results');


