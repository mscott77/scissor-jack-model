function SF = calculateSF_diag_bearing(S,F,D,CStype)
    
    if (CStype == 'I')              % I-beam has 1 hole of width t compared to U and rect which have 2 holes of width t to support the pin
        F = F*2;
    end
    stress = F/(2*D);
    SF = S/stress;
end

