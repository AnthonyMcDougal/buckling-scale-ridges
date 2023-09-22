function [xrot,zrot] = rotProfile(xmat,zmat)
%rotProfile takes a height profile and rotates it to find the most planar fit through the profile
%   Anthony McDougal, Sungsam Kang, Zahid Yaqoob, Peter So, and Mathias Kolle, 2021 
%   MAKE SURE THAT THE UNITS FOR x and z ARE THE SAME!!
clUm = xmat;
cUWum = zmat;

        M = [clUm, clUm.^0];
        C = M\cUWum;
                
        t = atan(-C(1));
        rotmat = [cos(t) -sin(t); sin(t) cos(t)];
        [rotResults] = rotmat * [clUm.'; cUWum.'];
        clRot = rotResults(1,:);
        clRot = clRot - min(clRot);
        cUWumRot = rotResults(2,:);
        cUWumRot = cUWumRot - min(cUWumRot(:));
        
        xrot = clRot;
        zrot = cUWumRot;
end

