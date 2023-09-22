% Demonstration of ridge segmentation pipeline for a single surface region
% of interest

%   Jan Totz, Anthony McDougal, Leonie Wagner, Sungsam Kang, Peter So, 
%   Jörn Dunkel, Bodo Wilts, and Mathias Kolle, 2023

%% Add subdirectories to path
currfolder = fileparts(which(mfilename));
addpath(genpath(currfolder));


%% Load and show single file measurement

% main file
filepath = 'Measured\A-40-01_11_04_34_set_115-d4.86\scale6-10L-3D_meas.mat';

ptrn = 'Measured';
strInd = strfind(filepath, ptrn);
filelabel = filepath(strInd+length(ptrn):end);

roi = simplifyStruct(filepath);


%% Load 3D view previously measured
ax3DExample = make3DFromRoi(roi);
view(-16.6880, 33.0428)
h = gcf;
h.Position = [680 200 1150 760];
xticks([0 2 4 6 8 10])
yticks([0 2])
zticks([0 0.2])


%% Recreate phase slice
%requires SupportingCode_prevRel, this script has already added it to path

%Get data
%Other timepoints can work with this as well
dataFile = roi.meas.DataVolume
slice = roi.meas.slice;

%Load data
load(dataFile)

%Process interferogram for complex data
Pimgs = ima2full(data.IMG, data.ref);

% display the phase slice
figure
imagesc(angle(Pimgs(:,:,slice))), axis image, title('phase data')
colormap(twilight)

% Visualize phase gradient orientation
Pimgs_pGrad = phaseGradOr(Pimgs);
figure
imagesc(Pimgs_pGrad(:,:,slice)), axis image, title('Orientation of the phase gradient')
colormap(twilight)


%% show ROI
% get corners
pt1 = [roi.meas.cx_2D(1,1), roi.meas.cy_2D(1,1)];
pt2 = [roi.meas.cx_2D(1,end), roi.meas.cy_2D(1,end)];
pt3 = [roi.meas.cx_2D(end,end), roi.meas.cy_2D(end,end)];
pt4 = [roi.meas.cx_2D(end,1), roi.meas.cy_2D(end,1)];

% plot roi
h = drawpolygon('Position', [pt1;pt2;pt3;pt4]);


%% get roi phase 2d
figure
imagesc(roi.meas.phase_2D')
set(gca,'YDir','normal')
axis image, title('phase of ROI'), colormap(twilight)


%% Begin example analysis of one scale

%% make table of a single measurement

[ptableSingleROI_basic, peakInd,troughInd] = segmentRidges(roi);
ptableSingle = mkProtoridgeTable(roi);

%filter
phaseThreshold = 3*pi/4; %See note in function findjumps.m
ptableSingle = filterJumps(ptableSingle, phaseThreshold);

%% Plot side view of measurement

figH = figure;
figH.Position(1:4) = [50 50 1500 700];

subplot(3,1,1)
plotTransparent(roi.surfX', roi.surfZ')

hold on

avProfileX = mean(roi.surfX,2);
avProfile = mean(roi.surfZ,2);

plot(avProfileX , avProfile, 'Color', [.9 0 0])

ylabel(['height, ', char(0181), 'm'])
xlabel(['lateral position, ', char(0181), 'm'])

title(filelabel,'Interpreter',"none")

%% show cuts
hold on;
scatter(avProfileX(peakInd),avProfile(peakInd), 'blue');
scatter(avProfileX(troughInd),avProfile(troughInd), 36, [0 .5 0]);

%% Group by ridge
[ridgeGroups, ridgeTable] = findgroups(  ptableSingle(:,{'peakInd'})  );

%% Plot each unscaled ridge
clear axRot
for k = 1:height(ridgeTable)
    axRot(k) = subplot(3, height(ridgeTable)+1, k+1*(height(ridgeTable)+1));
    
    ptable_thisRidge = ptableSingle(ridgeGroups == k,:);
    thisX = cell2mat(ptable_thisRidge.rotX);
    thisZ = cell2mat(ptable_thisRidge.rotZ);
    
    plotTransparent(thisX , thisZ)
    
    this_avProfileX = mean(thisX,1);
    this_avProfile = mean(thisZ,1);
    hold on
    plot(this_avProfileX , this_avProfile, 'Color', [.9 0 0])
    
    this_h = max(this_avProfile);
    this_w = this_avProfileX(end) - this_avProfileX(1);
    
    hString = ['h of mean=',num2str(this_h*1000,'%2.0f'), 'nm,'];
    wString = ['w=',num2str(this_w,'%0.2f'), char(0181), 'm'];
    dimStr = {hString, wString};
    title(dimStr)
    
end

ylabel(axRot(1), ['height (after rotation), ', char(0181), 'm'])
xlabel(axRot(1), ['(rotated) lateral position, ', char(0181), 'm'])

% linkaxes(axRot)
setSameYLims(axRot)
setSameXLims(axRot)

%% Plot each scaled ridges

ridgeTable = statsOfGroups(ptableSingle, ridgeGroups, ridgeTable);

clear axScaled
for k = 1:height(ridgeTable)
    axScaled(k) = subplot(3, height(ridgeTable)+1, k+2*(1*(height(ridgeTable)+1)));
    
    ptable_thisRidge = ptableSingle(ridgeGroups == k,:);
    thisX = ptable_thisRidge.scaledX;
    thisZ = ptable_thisRidge.scaledZ;
    
    plotTransparent(thisX , thisZ)
    
    plot(ridgeTable.scaledX(k,:), ridgeTable.meanProfile(k,:), 'Color', [1 0 0], 'LineWidth', 1.5)
    plot(ridgeTable.scaledX(k,:), ridgeTable.upperStd(k,:), 'Color', [0 0 1], 'LineWidth', 1.5)
    plot(ridgeTable.scaledX(k,:), ridgeTable.lowerStd(k,:), 'Color', [0 0 1], 'LineWidth', 1.5)
    
    ridgeTable.scaledH(k) = max(ridgeTable.meanProfile(k,:));
    
    hScString = ['h_{scaled} of mean=',num2str(ridgeTable.scaledH(k)*1000,'%2.0f'), 'nm*'];
    title(hScString)
end

ylabel(axScaled(1),['height, scaled by width normalization'])
xlabel(axScaled(1),['width, normalized to 1'])

% linkaxes([axScaled axCombo])
setSameYLims(axScaled)

%% Combine all

subplot(3, height(ridgeTable)+1, 3*(1*(height(ridgeTable)+1)))
title('All scaled ridges together')
plotTransparent(ptableSingle.scaledX, ptableSingle.scaledZ)

statsAll = statsOfWholeTable(ptableSingle);

plot(statsAll.scaledX, statsAll.meanProfile, 'Color', [1 0 0], 'LineWidth', 1.5)
plot(statsAll.scaledX, statsAll.upperStd, 'Color', [0 0 1], 'LineWidth', 1.5)
plot(statsAll.scaledX, statsAll.lowerStd, 'Color', [0 0 1], 'LineWidth', 1.5)

statsAll.scaledH = max(statsAll.meanProfile);
hScString = ['h_{scaled} of mean=',num2str(statsAll.scaledH*1000,'%2.0f'), 'nm*'];
titleString1 = 'all ridges together';

title({titleString1, hScString})

%% reinterpolate function
function [xq, vq] = newInterp(x, v, newArrayLength)

xqstep = (x(end)-x(1)) / (newArrayLength-1);
xq = x(1):xqstep:x(end);

vq = interp1(x,v,xq); %linear interpolation

end

function statsOut = statsOfWholeTable(tablein)

statsOut.meanProfile = mean(tablein.scaledZ);
statsOut.stdProfile = std(tablein.scaledZ);
statsOut.upperStd = statsOut.meanProfile + statsOut.stdProfile;
statsOut.lowerStd = statsOut.meanProfile - statsOut.stdProfile;
statsOut.scaledX = mean(tablein.scaledX);

end