% Script to process measurement files used in Fig. 1.
% Measurement files identified manually with analyzePhaseProfile.m

%   Jan Totz, Anthony McDougal, Leonie Wagner, Sungsam Kang, Peter So, 
%   Jörn Dunkel, Bodo Wilts, and Mathias Kolle, 2023

%% Add subdirectories to path
currfolder = fileparts(which(mfilename));
addpath(genpath(currfolder));


%% central profiles
clear meas
load('Measured\Example unwraps\41_0pct-A-40-01_11_04_34_set_115.mat')

figure
show2Dunwrap(meas)
axSet115 = gca;
clim =  axSet115.CLim;

showCrossSec(meas)
h = gca;
h.Children(1).Color = [205,22,224]/255*0.8;
f = gcf;
f.Position(3:4) = [275 200];

%%
clear meas
load('Measured\Example unwraps\40_0pct-A-40-01_11_01_34_set_112.mat')

figure
show2Dunwrap(meas)
axSet112 = gca;
axSet112.CLim = axSet115.CLim;

showCrossSec(meas)
h = gca;
h.Children(1).Color = [224    180    45]/255*0.8;
f = gcf;
f.Position(3:4) = [275 200];

%%
clear meas
load('Measured\Example unwraps\35_8pct-A-40-01_10_10_52_set_97.mat')

figure
show2Dunwrap(meas)
axSet97 = gca;
axSet97.CLim = axSet115.CLim;

showCrossSec(meas)
h = gca;
h.Children(1).Color = [67    224    185]/255*0.8;
f = gcf;
f.Position(3:4) = [275 200];


%% Functions

function show2Dunwrap(meas)

imagesc([meas.cx_2DNewUmRot(1,1),meas.cx_2DNewUmRot(end,1)], [meas.cy_2DNewUmRot(1,1), meas.cy_2DNewUmRot(1,end)], meas.phase_2DNewUmRot')
axis image, colormap(viridis)
xlabel([char(0181),'m'])
ylabel([char(0181),'m'])
hold on
midline2 = round(size(meas.cx_2DNewUmRot,2)/2);
scatter3(meas.cx_2DNewUmRot(1,midline2), meas.cy_2DNewUmRot(1,midline2), meas.phase_2DNewUmRot(1,midline2),'r')
hold off
cbar = colorbar;
cbar.Label.String = ['rotated height, ', char(0181), 'm'];
set(gca,'Ydir','normal')

end

function showCrossSec(meas)

profileHeight = meas.heightProfileUmRot;
profilePosition = meas.cxNewUmRot;
figure
plot(profilePosition,1000*profileHeight)
% hold on
ylabel(['height (nm)'])
xlabel(['distance (',char(0181),'m)'])
h = gca;
h.XLim = [-0.5, 5.5];
xticks([0 1 2 3 4 5])
yticks([0 50 100])
h.YLim = [-10, 110];

end
