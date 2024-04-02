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
p_diagSectionType = 'C';             % 'I'=I-Beam , 'C'=C-Channel , 'R'= hollow rectangular
p_diag_L = 5;                           % length of the diagonal member from pin to pin (center to center)
p_diagCS_w = 1;                         % width of the diagonal member cross section
p_diagCS_h = 1;                         % height of the diagonal member cross section
p_crossBar_D = 0.5;                     % diameter of the cross bar
p_crossBar_mtr = 'structural_steel';    % material of the cross bar: 'structural_steel' or 'aluminum'
p_extensionDim = 6;                     % ???
p_vert_w = 0.25;


% NOT to be changed by the user:
c_diagCS_t = 1/16;                      % thickness of the diagonal member cross section




%%---------------------------------------------CROSS SECTION CALCS-------------------------------------------------%%
CS = struct('A',0,'Ix',0,'Iy',0);   % "CS" = Cross Section
switch p_diagSectionType
    case 'I'
        % I-Beam
        [CS.A, CS.Ix, CS.Iy] = calculateSectionProperties_Ibeam(p_diagCS_w, p_diagCS_h, c_diagCS_t);

    case 'C'
        % C-Channel
        [CS.A, CS.Ix, CS.Iy] = calculateSectionProperties_Channel(p_diagCS_w, p_diagCS_h, c_diagCS_t);

    case 'R'
        % Hollow Rectangular
        [CS.A, CS.Ix, CS.Iy] = calculateSectionProperties_Rectangle(p_diagCS_w, p_diagCS_h, c_diagCS_t);

    otherwise
        error('Invalid input for p_diagSectionType. Must be "I", "C", or "R"');
end


% DEBUG: display cross section properties
disp(CS);














%%---------------------------------------------SUMMARY OF OUTPUTS-------------------------------------------------%%

% FIXME: these will be calculated throughout the model. just placeholders for now
o_maxStress = 0;            % maximum stress in... which member         ?
o_failureModes = 'xxx';     % ?                                         ?
o_totalDeflection = 0;      % total deflection of the scissor jack      ?
o_totalWeight = 0;          % total weight of the scissor jack 
o_overallDim = 0;           % overall dimensions of the scissor jack    ?
o_fatStrength_10k = 0;      % fatigue strength at 10,000 cycles

% define result as strings
string1 = ['Max Stress:                 '  num2str(o_maxStress)             ' psi'];     
string2 = ['Failure Mode:               '  o_failureModes];            
string3 = ['Total Deflection:           '  num2str(o_totalDeflection)       ' in'];    
string4 = ['Total Weight:               '  num2str(o_totalWeight)           ' lb'];          
string5 = ['Overall Dim:                '  num2str(o_overallDim)            ' in'];     
string6 = ['Fatigue Strength 10k:       '  num2str(o_overallDim)            ' psi'];     
 


% Concatenate the strings
result_str = join({string1, string2, string3, string4, string5, string6}, newline);


% Display the concatenated string in a message box
% msgbox(result_str, 'Results');


