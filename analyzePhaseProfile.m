% Example script of approach used to manually measure phrase profiles
% Modified from McDougal et al., 2021
% Example file referenced below
% Suggested to run a single section at a time

%   Jan Totz, Anthony McDougal, Leonie Wagner, Sungsam Kang, Peter So, 
%   Jörn Dunkel, Bodo Wilts, and Mathias Kolle, 2023

%% Add required directories
% currfolder = fileparts(which(mfilename));
% addpath(genpath(currfolder));

addpath(genpath(pwd));

%% Input data
%Run this section to get a data struct with profile info
Dir1 = 'RawData';
filename = ...
    'A-40-01_11_04_34_set_115.mat';
pupationTimeStamp = datetime('2020-01-06  07:48');

%Load data
load(fullfile(Dir1, filename))

% Grab time, age, specimen id from file name
filenameINpre = filename(1:end-4);
setIDpos = find(filenameINpre=='_', 1, 'last')+1;
setID = str2num(filenameINpre(setIDpos:end));

imgTimeStamp = datetime(data.Start_Time);
currentAge = (imgTimeStamp - pupationTimeStamp);
currentAgeStr = ['d' , num2str(days(currentAge), '%0.2f')];

filenamepre = [filenameINpre, '-', currentAgeStr];

bfID = strrep(filenamepre(1:4),'-','')


%% Process raw data
%Process interferogram for complex data
Pimgs = ima2full(data.IMG, data.ref);

%Calculate the phase gradient
Pimgs_pGrad = phaseGradOr(Pimgs);


%% Run phase profile
% addpath('profileFunctions')

% Get line data, repeat
phaseD = 800/(2*2*pi*1.346); %parameter to convert phase to difference via phase shift
% figsOut = phaseProfiler3(Pimgs,Pimgs_pGrad,phaseD);
figsOut = phaseProfiler3_1(Pimgs,Pimgs_pGrad,phaseD);


%% Save data and figs
%add file details to struct
meas.ButterflyID = bfID;
meas.Age = hours(currentAge)/24;
meas.DataVolume = filename;

% get folder
%folder for data volume
currentDir = pwd;
dataVolDir = [pwd, '\', filenamepre, '\'];
mkdir(dataVolDir)

savepath = uigetdir(dataVolDir,'Select folder to store Figs and meas');

% enter prefix for saving:
prompt= 'Enter prefix for files to be saved:';
fileoutPre =input(prompt,'s');


% save struct
filename = [fileoutPre,'_meas.mat'];
filepath = fullfile(savepath,filename);
save(filepath,'meas')


% Save figs,
figname = fieldnames(figsOut);
for k = 1:numel(figname)
    thisFig = figsOut.(figname{k});
    filenameFig = [fileoutPre,'_',figname{k},'.fig'];
    filepathFig = fullfile(savepath,filenameFig);
    saveas(thisFig, filepathFig)
end

