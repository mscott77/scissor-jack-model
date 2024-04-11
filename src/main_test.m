
clear;
clc;

Dpin = .25;
Dcb = .5;
CrossSection = 'I1';
runSingleSimulation(Dpin,Dcb,CrossSection,true);

% validate CB hand calcs:  E            Syc  Lcb    Acb    Icb    Fcb
%                          16500000, 141000, 16, .1963, .003068, 2664