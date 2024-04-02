function [A,Ix,Iy] = calculateSectionProperties_Ibeam(w,h,t)

    h1 = h - 2*t;
    b1 = t;
    h2 = h1;
    b2 = w;
    A2 = h2*b2;
    b3 = w;
    h3 = t;
    A3 = h3*b3;
    d1 = h-t;
    d2 = d1;

    A = 2*(h2*b2) + (h1*b1);

    Ix1 = (1/12)*b1*h1^3;
    Ix2 = (1/12)*b2*h2^3 + A2*d1^2;
    Ix3 = (1/12)*b3*h3^3 + A3*d2^2;
    Ix = Ix1 + Ix2 + Ix3;

    Iy = (1/12)*( h1*b1^3 + h2*b2^3 + h3*b3^3 );
end

