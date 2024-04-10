
clear;
clc;

Dpin = 0.5;
Dcb = 1;
CrossSection = 'I1';
runSingleSimulation(Dpin,Dcb,CrossSection,false);

Dpin = 1;
Dcb = 2;
CrossSection = 'I2';
runSingleSimulation(Dpin,Dcb,CrossSection,false);