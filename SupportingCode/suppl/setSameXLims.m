function setSameXLims(axisArray)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


xlims = [axisArray.XLim];
xlims = reshape(xlims,[2,length(axisArray)]);
xlims = xlims';

newXLim = [];
newXLim(1) = min(xlims(:,1),[],1);
newXLim(2) = max(xlims(:,2),[],1);

for i = 1:length(axisArray)
    axisArray(i).XLim = newXLim;
end
end