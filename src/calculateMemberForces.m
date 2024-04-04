function [Fcb,Fd,Fv] = calculateMemberForces(F, Ld, Lcb)

    theta = asin((Lcb/2)/Ld);
    Fv = F;
    Fd = F/(2*cos(theta));
    phi = acos((Lcb/2)/Ld);
    Fcb = 2*Fd*cos(phi);
end

