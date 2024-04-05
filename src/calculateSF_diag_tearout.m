function SF = calculateSF_diag_tearout(S,F,Lap,t,D)

    r = D/2;
    de = Lap-r;
    tau = (F/(4*de*t))*sqrt(3);
    SF = S/tau;
    
end

