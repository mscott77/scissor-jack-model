function SF = calculateSF_diag_bearing(S,F,D)
    stress = F/(2*D);
    SF = S/stress;
end

