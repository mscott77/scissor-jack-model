function SF = calculateSF_cross_buckle(E, Sy, Lcb, Acb, Icb, Fcb)
    C = 1;                          % End conditions
    k = sqrt(Icb/Acb);              % k value
    Sr = Lcb/k;                     % Slenderness ratio
    lk_1 = sqrt(2*pi^2*C*E/Sy);     %
    Pcr = Acb*C*E*pi^2/(Sr^2);      % Euler Column - Critical Load
    SF = Pcr/ Fcb;                  % Safety factor
end


