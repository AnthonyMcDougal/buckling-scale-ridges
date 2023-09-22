function setSameYLims(axisArray)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


ylims = [axisArray.YLim];
ylims = reshape(ylims,[2,length(axisArray)]);
ylims = ylims';

newYLim = [];
newYLim(1) = min(ylims(:,1),[],1);
newYLim(2) = max(ylims(:,2),[],1);

for i = 1:length(axisArray)
    axisArray(i).YLim = newYLim;
end
end