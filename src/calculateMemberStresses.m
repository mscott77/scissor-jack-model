function [stress_cb, stress_d, stress_v] = calculateMemberStresses(Fcb,Fd,Fv,CS_CB,CS_DV)

    stress_cb = Fcb/CS_CB.A;
    stress_d = Fd/CS_DV.A;
    stress_v = Fv/CS_DV.A;
end

