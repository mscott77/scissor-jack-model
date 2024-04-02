function [A,Ix,Iy] = calculateSectionProperties_Channel(w,height,t)

    b = t;
    h = t;
    H = height-(2*t);
    B = w;

    A = 2*(B*h) + (b*H);

    xc = ((2*h*(B^2)/2) + ((b^2)*H/2))/A;

    Ix = ((H^3)*b/12) + 2*(  ((h^3)*b/12) + ((h*B*(h+H)^2)/4) );
    Iy = ((b^3)*H/12) + (b*H*(xc-(b/2))^2) + (2*(B^3)*h/12) + (2*B*h*(xc-(B/2))^2);
end

