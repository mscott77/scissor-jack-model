function [A,Ix,Iy] = calculateSectionProperties_Rectangle(w,h,t)

    A = (w*h) - ((w-t)*(h-t));
    
    Ix = (w*h^3 - (w-t)*(h-t)^3)/12;
    Iy = (h*w^3 - (h-t)*(w-t)^3)/12;
end

