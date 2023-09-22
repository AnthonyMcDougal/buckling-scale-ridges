function [arcTable, peakIndices,troughInd] = segmentRidges(roi)
%segmentRidges takes an roi struct and determines where to cut the ridges
%   Detailed explanation goes here

dirSuppl = 'profileFunctions';
addpath(genpath(dirSuppl))

% Identify ridge
surfXax = roi.surfX(:,1);
avProfile = mean(roi.surfZ,2);
[peakIndices,troughInd] = ridgePositions(surfXax, avProfile, roi);



% Cut ridges into segments
arcTable = cutRidges(roi, peakIndices, troughInd);


end

function [peakIndices,troughInd] = ridgePositions(surfXax, avProfile, roi);

%segmentation parameters
maxPeriod = roi.meas.maxPeriod;
% maxPeriod = 2;
minFreqRatioAllow = roi.meas.minFreqRatioAllow;
% minFreqRatioAllow = 0.3;
minPeak = roi.meas.minPeak;
% minPeak = 0.005;

%get peak and trough indices
% get peaks

[frqs1,pks1,fsampleP,fs, df] = getProfileFreq(avProfile,surfXax,maxPeriod);
w = 1/frqs1;
minspacing = w*fs*minFreqRatioAllow;
[peakIndices,troughInd] = peakMinFinder(avProfile,minspacing,minPeak);

%first and last peak must be bookended by troughs
peakIndices = bookendTest(peakIndices, troughInd);



%Retest each peak for double peak
peakIndices_mod = peakIndices;
troughInd_mod = troughInd;

for i = 1:length(peakIndices)
    
    peakInd = peakIndices(i);
    trough1Ind = troughInd(find(troughInd<peakInd,1,'last'));
    trough2Ind = troughInd(find(troughInd>peakInd,1));
    
    shortX = roi.surfX(trough1Ind:trough2Ind,1);
    shortAvProfile = mean(roi.surfZ(trough1Ind:trough2Ind,:),2);
    shiftInd = trough1Ind-1;
    [rotShortX, rotShortAvProfile] = rotProfileEndPts(shortX, shortAvProfile); 
    rotShortX = rotShortX';
    rotShortAvProfile = rotShortAvProfile';
    
    
    newPeaks = [];
    newTrough = [];
    try
        [newPeaks , newTrough] = peakMinFinder(rotShortAvProfile,minspacing,minPeak);
    catch
%         - Note that a few ridges throw a custom warning when being segmented, but this is a negligible concern
% 	- each initial cut is checked to see if rotation makes the ridges easier to identify
% 	- all cases with warnings have been inspected: they produce acceptable ridges
%   - uncomment the rest of this catch to examine
        
%         ridgeID = num2str(i);
%         msg = ['In: ', roi.measFile, ' '];
%         msg1 = ['did not run test for double peak for ridge #', ridgeID, ', '];
%         msg2 = 'possibly(?) due to MinPeakDistance in findpeaks being too large (larger than data)';
%         
%         warning([msg, msg1, msg2])
    end
        

    
    if length(newPeaks)>1
        peakIndices_mod(find(peakIndices_mod==peakInd)) = [];
        peakIndices_mod = [peakIndices_mod; (newPeaks+shiftInd)];
        peakIndices_mod = sort(peakIndices_mod);
        
        %troughs already on end, only get troughs between peaks
        newTrough = bookendTest(newTrough, newPeaks);

        
        troughInd_mod = [troughInd_mod; (newTrough+shiftInd)];
        troughInd_mod = sort(troughInd_mod);
    end
    
    peakIndices = peakIndices_mod;
    troughInd = troughInd_mod;
    
end


end

function peakIndices = bookendTest(peakIndices, troughInd)

%first and last peak must be bookended by troughs

%check first peak
thisPeakInd = peakIndices(1);
trough1Ind = troughInd(find(troughInd<thisPeakInd,1,'last'));
%Skip peak if not surrounded by trough
if isempty(trough1Ind)
    peakIndices(1) = [];
end

%check last peak
thisPeakInd = peakIndices(end);

trough2Ind = troughInd(find(troughInd>thisPeakInd,1));
%Skip peak if not surrounded by trough
if isempty(trough2Ind)
    peakIndices(end) = [];
end


end

function arcTable = cutRidges(roi, peakIndices, troughInd)

%for splitting en masse
% splitPeaks = cell(length(peakIndices), 3); % (individual ridge profiles, (x,y,z))
arcTable = table;

%Loop over ridges
for j = 1:length(peakIndices)
    
    peakInd = peakIndices(j);
    trough1Ind = troughInd(find(troughInd<peakInd,1,'last'));
    trough2Ind = troughInd(find(troughInd>peakInd,1));
    
    %split en masse
    %     splitPeaks{j, 1} = roi.surfX(trough1Ind:trough2Ind,:);
    %     splitPeaks{j, 2} = roi.surfY(trough1Ind:trough2Ind,:);
    %     splitPeaks{j, 3} = roi.surfZ(trough1Ind:trough2Ind,:);
    
    %split each trace
    for k = 1:size(roi.surfZ,2)
        arcX = {roi.surfX(trough1Ind:trough2Ind,k)};
        arcY = {roi.surfY(trough1Ind:trough2Ind,k)};
        arcZ = {roi.surfZ(trough1Ind:trough2Ind,k)};
        
        profileDepthID = k;
        phaseD = roi.phaseD;
        arcTNew = table(profileDepthID, arcX, arcY, arcZ, peakInd, trough1Ind, trough2Ind, phaseD);
        arcTable = [arcTable; arcTNew];
    end
end

end