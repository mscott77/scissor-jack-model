function SF = calculateSF_diag_tearout(S,F,Lap,t,D,CStype)
    
    if (CStype == 'I')              % I-beam has 1 hole of width t compared to U and rect which have 2 holes of width t to support the pin
        F = F*2;
    end
    r = D/2;
    de = Lap-r;
    tau = (F/(4*de*t))*sqrt(3);
    SF = S/tau;
    
end

