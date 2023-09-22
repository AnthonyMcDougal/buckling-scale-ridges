function [meanHeights,stdHeights,nHeights] = getHeights(clUmRot,aProfile,peakInd,troughInd)
%getHeights measures peak heights in a profile
%   Measures height of all peaks that have a trough to either side.
%   Note that there are different ways to measure "height" of a peak.
%   Here, we make a baseline from the troughs surrounding the height, and
%   measure the peak height from that baseline.
%   Anthony McDougal, Sungsam Kang, Zahid Yaqoob, Peter So, and Mathias Kolle, 2021 


%initialize height measurements
height = zeros(size(peakInd));

%loop over all peaks
for j = 1:length(peakInd)
    
    %get trough points surrounding peak
    thisPeakInd = peakInd(j);
    trough1Ind = troughInd(find(troughInd<thisPeakInd,1,'last'));
    trough2Ind = troughInd(find(troughInd>thisPeakInd,1));
    
    %Skip peak if not surrounded by trough
    if isempty(trough1Ind)
        continue
    end
    if isempty(trough2Ind)
        continue
    end
    
    %grab xy points of peaks and troughs (x is grabbed along length array, y is grabbed from height array)
    thisPeakXY = [clUmRot(thisPeakInd) , aProfile(thisPeakInd)];
    trough1XY = [clUmRot(trough1Ind) , aProfile(trough1Ind)];
    trough2XY = [clUmRot(trough2Ind) , aProfile(trough2Ind)];
    
    %Get height: distance from peak point to the line connecting both troughs
    height(j) = dpointline(thisPeakXY,trough1XY, trough2XY);
    %    height(j)= aProfile(thisPeakInd)-aProfile(thisTrough);
    
end

%Calculate statistics about the heights
rheights = height;

rheights  = nonzeros(rheights);

meanHeights = mean(rheights);
stdHeights = std(rheights);
nHeights = length(rheights);


end

