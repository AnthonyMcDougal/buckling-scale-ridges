% Analysis of butterfly scale surfaces for Fig 3. Measurement files 
% manually identified using analyzePhaseProfile.m and phaseProfiler3_1.m 

%   Jan Totz, Anthony McDougal, Leonie Wagner, Sungsam Kang, Peter So, 
%   Jörn Dunkel, Bodo Wilts, and Mathias Kolle, 2023

%% Add subdirectories to path
currfolder = fileparts(which(mfilename));
addpath(genpath(currfolder));


%% Make list of all ridges of all times

set115Dir = "Measured\A-40-01_11_04_34_set_115-d4.86\*_meas.mat";
set114Dir = "Measured\A-40-01_11_03_34_set_114-d4.82\*_meas.mat";
set113Dir = "Measured\A-40-01_11_02_34_set_113-d4.78\*_meas.mat";
set112Dir = "Measured\A-40-01_11_01_34_set_112-d4.74\*_meas.mat";
set111Dir = "Measured\A-40-01_11_00_34_set_111-d4.70\*_meas.mat";
dirListTimes = [set115Dir; set114Dir; set113Dir; set112Dir; set111Dir];

ptableAll = table();

for i = 1:length(dirListTimes)
    thisDir = dirListTimes(i);
    pTableTimepoint = combineScalesTable(thisDir);
    ptableAll = [ptableAll; pTableTimepoint];
end

% use `ptableAll.Properties.VariableNames` to see variable names

COrder = colororder();


%% rearrange table
ptableAll = movevars(ptableAll, {'dayAge', 'measFile'}, 'Before',1);
ptableAll = movevars(ptableAll, 'pctAge', 'Before',1);

% % alternative indexing note:
% a = ptableAll(:,1:2);


%% Filter table

phaseThreshold = 3*pi/4; %See note in function findjumps.m
ptableAll = filterJumps(ptableAll, phaseThreshold);

% ptableAll_noJumps = ptableAll;


%% Filter curves that are too low

height(ptableAll)
lowerLimit = -0.02;
ptableAll = filterLow(ptableAll, lowerLimit);
height(ptableAll)

% ptableAll_noVeryNegative = ptableAll;


%% break out by age

% break out by age
[ageGroups, ageTable] = findgroups(  ptableAll(:,{'pctAge'})  );
ageTable = statsOfGroups(ptableAll, ageGroups, ageTable);

upperQuart = @(x) quantile(x, [0.75]);
ageTable.upperQuart = splitapply(upperQuart, ptableAll.scaledZ, ageGroups);
lowerQuart = @(x) quantile(x, [0.25]);
ageTable.lowerQuart = splitapply(lowerQuart, ptableAll.scaledZ, ageGroups);
medQuart = @(x) quantile(x, [0.5]);
ageTable.medQuart = splitapply(medQuart, ptableAll.scaledZ, ageGroups);

% ageTable contains the curves used to compare to the numerical analysis
ageTable

%% Create normalized height and width plots
% Using bastibe's violinplot() https://github.com/bastibe/Violinplot-Matlab

newC = [255,199,0;...
    237,138,41;...
    237,101,84;...
    212,101,161;...
    191,112,255];
newC = newC/255;

figure
colororder(newC)

vplotHeight = violinplot(1000*ptableAll.scaledH, ptableAll.pctAge,...
    'Width', 0.4,...
    'MarkerSize', 12);

for i = 1:length(vplotHeight)

vplotHeight(i).ScatterPlot.MarkerFaceAlpha = 0.3;
vplotHeight(i).BoxWidth = .05;
vplotHeight(i).BoxPlot.FaceAlpha = 0.7;
vplotHeight(i).ShowMean = true;
vplotHeight(i).MeanPlot.Color = [0.5, 0.5, 0.5];

end
xlabel('Pupal development time (%)')
ylabel('Amplitude {\it w0}')
vplotHeight_Fig = gcf;
vplotHeight_Fig.Position(3:4) = [600 240];

figure
colororder(newC)
vplotWidth = violinplot(ptableAll.w, ptableAll.pctAge,...
    'Width', 0.4,...
    'MarkerSize', 12);

for i = 1:length(vplotWidth)
    vplotWidth(i).ScatterPlot.MarkerFaceAlpha = 0.3;
    vplotWidth(i).BoxWidth = .05;
    vplotWidth(i).BoxPlot.FaceAlpha = 0.7;
    vplotWidth(i).ShowMean = true;
    vplotWidth(i).MeanPlot.Color = [0.5, 0.5, 0.5];
end

xlabel('Pupal development time (%)')
ylabel(['Width {\it L} (', char(0181), 'm)'])
vplotWidth_Fig = gcf;
vplotWidth_Fig.Position(3:4) = [600 240];