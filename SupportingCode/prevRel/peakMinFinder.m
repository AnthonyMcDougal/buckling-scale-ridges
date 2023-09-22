function [peakInd,troughInd] = peakMinFinder(aProfile,minspacing,minPeak)
%peakMinFinder returns indices of peaks and troughs, constrained by minimum peak height and minimal peak separation
%   Anthony McDougal, Sungsam Kang, Zahid Yaqoob, Peter So, and Mathias Kolle, 2021 


%Identify peaks
[pks, peakInd] = findpeaks(aProfile,'MinPeakDistance',minspacing,'MinPeakProminence',minPeak);

%Identify troughs
troughInd = zeros(length(peakInd)+1,1);
for i = 1:length(troughInd)
    if i == 1
        [~, troughInd(i)] = min(aProfile(1:peakInd(i)));
    elseif i == length(troughInd)
        [~, tempTrough] = min(aProfile(peakInd(i-1):end));
        troughInd(i)  = tempTrough + peakInd(i-1) - 1;
    else
        [~, tempTrough] = min(aProfile(peakInd(i-1):peakInd(i)));
        troughInd(i)  = tempTrough + peakInd(i-1) - 1;
    end
end

%Exclude max/min on edges
if peakInd(1) == 1
    peakInd = peakInd(1+1:end);
end
if peakInd(end) == length(aProfile)
    peakInd = peakInd(1:end-1);
end
if troughInd(1) == 1
    troughInd = troughInd(1+1:end);
end
if troughInd(end) == length(aProfile)
    troughInd = troughInd(1:end-1);
end


end

