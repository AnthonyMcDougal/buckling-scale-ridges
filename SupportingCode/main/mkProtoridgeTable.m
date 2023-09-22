function arcTable = mkProtoridgeTable(roi)
%mkProtoridgeTable Summary of this function goes here
%   Detailed explanation goes here

%% variables hardcoded
resampleL = 100;

%% dependencies
dirSuppl = 'profileFunctions';
addpath(genpath(dirSuppl))


%% take in ROI data


%% find ridge cuts

arcTable = segmentRidges(roi);

%% filter ridges (label good or bad)
%MOVED to function findjumps.m and called in main script (after making
%full table)

%% rotate ridges

rotX = cell(size(arcTable.arcX));
rotZ = cell(size(arcTable.arcZ));


for id = 1:height(arcTable)
    [rotXnow, rotZnow] = rotProfileEndPts(arcTable.arcX{id}, arcTable.arcZ{id});
    rotX(id) = {rotXnow - rotXnow(1)};
    rotZ(id) = {rotZnow - rotZnow(1)};
end

arcTable = addvars(arcTable, rotX, rotZ);

%% get width and height

w = nan(size(arcTable.rotZ)); 
h = nan(size(arcTable.rotZ));

for id = 1:height(arcTable)
    w(id) = rotX{id}(end) - rotX{id}(1);
    h(id) = max(rotZ{id});
end

arcTable = addvars(arcTable, w, h);

%% scale ridges

% scaledX = cell(size(arcTable.rotX)); 
% scaledZ = cell(size(arcTable.rotZ)); 

scaledX = []; 
scaledZ = []; 
scaledH = [];

for id = 1:height(arcTable)
    scaledXsmall = arcTable.rotX{id} / arcTable.w(id);
    scaledZsmall = arcTable.rotZ{id} / arcTable.w(id);
    
    %sample to make same array length
    [sampledX, sampledZ] = newInterp([scaledXsmall], [scaledZsmall], resampleL);
    
%     scaledX(id) = {sampledX};
%     scaledZ(id) = {sampledZ};
    scaledX(end+1, :) = sampledX;
    scaledZ(end+1, :) = sampledZ;

end
scaledH = max(scaledZ, [], 2);

arcTable = addvars(arcTable, scaledX, scaledZ,scaledH);


%% add age and file info to table
dayAge = repmat(roi.dayAge, height(arcTable), 1);
fullAge = 11.848; %Full development age for this generation
pctAge = 100*dayAge/fullAge;

arcTable = addvars(arcTable, dayAge, pctAge);

measFile = repmat(string(roi.measFile), height(arcTable), 1);  
arcTable = addvars(arcTable, measFile);


%% functions

function [xq, vq] = newInterp(x, v, newArrayLength)

xqstep = (x(end)-x(1)) / (newArrayLength-1);
xq = x(1):xqstep:x(end);

vq = interp1(x,v,xq); %linear interpolation

end

end