function SF = calculateSF_pin_shear(S,Fd, Dpin, CStype)

    % calculate equivalent force applied for various cross sectio type
    % (original hand calculations done for U-bar so I-beam needs to be adjusted)
    Feq = 0;
    if CStype == 1
        Feq = Fd*2;
    else
        Feq = Fd;
    end

    % calculate shear stress and safety factor
    tau_ps = 2*Feq/(pi*Dpin^2);
    SF = S/tau_ps;
end

