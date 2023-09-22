function h = make3DFromRoi(roi)
%make3DFromRoi creates a 3D surface from the measurement data
%   roi can be made from simplifyStruct.m and *_meas.mat measurement data

scaleH3D = 5;

figure
s = surf(roi.surfX, roi.surfY, roi.surfZ);
h = gca;

colorbar
s.EdgeColor = 'none';

try
    dirSuppl = '\colormaps';
    addpath(genpath(dirSuppl))
    colormap(viridis)
catch
    warning('It looks like you don''t have the viridis colormap; using default colormap.');
end

axis image
axis vis3d
rotate3d on

set(h, 'DataAspectRatio', [1 1 1/scaleH3D])
%         set(h,'Xdir','reverse')
title(['z-axis stretched by × ', num2str(scaleH3D)])
xlabel([char(0181),'m'])
ylabel([char(0181),'m'])
zlabel([char(0181),'m'])

end