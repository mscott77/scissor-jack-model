% iterates through all possible combinations of the 3 parameters

clear;
clc;

Dpin_smallest = 0.2;
Dpin_largest = 1.5;
Dpin_resolution = 0.1;

Dcb_smallest = 1;
Dcb_largest = 3;
Dcb_resolution = 0.1;

Dpin = (Dpin_smallest:Dpin_resolution:Dpin_largest);
Dcb = (Dcb_smallest:Dcb_resolution:Dcb_largest);
CrossSection = {'I1', 'I2', 'I3', 'C1', 'C2', 'C3', 'R1', 'R2', 'R3'};

currentIteration = 0;
totalIterations = length(Dpin) * length(Dcb) * length(CrossSection);
lastCheckpoint = 0;
disp("Progress: ");
disp('|------------------------------|');
fprintf('|*');
for i = 1:length(Dpin)
    for j = 1:length(Dcb)
        for k = 1:length(CrossSection)
            runSingleSimulation(Dpin(i),Dcb(j),char(CrossSection(k)),false);

            currentIteration = currentIteration + 1;
            percentFinished = (currentIteration/totalIterations)*100;
            if (percentFinished - lastCheckpoint) > (100/30)
                lastCheckpoint = percentFinished;
                fprintf('*');
            end
        end
    end
end
fprintf('|\n');
msgbox("Iterations: " + string(currentIteration));
