function [xrot,zrot] = rotProfileEndPts(xmat,zmat)
%rotProfile takes a height profile and rotates it to place the end points
%on the same line
%   MAKE SURE THAT THE UNITS FOR x and z ARE THE SAME!!
clUm = xmat;
cUWum = zmat;

clUmEND = xmat([1, end]);
cUWumEND = zmat([1, end]);

        M = [clUmEND, clUmEND.^0];
        C = M\cUWumEND;
                
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

