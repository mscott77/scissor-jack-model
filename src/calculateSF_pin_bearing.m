function SF = calculateSF_pin_bearing(S, Fcb, Dpin, t, CStype)

    % adjust force for different cross section types
    % (hand calculations done based on U-bar cross section)
    Feq = 0;
    if CStype == 'I'
        Feq = Fcb*2;
    else
        Feq = Fcb;
    end

    % calculate bearing stress and safety factor
    tau_pb = Feq/(2*Dpin*t);
    SF = S/tau_pb;

end

