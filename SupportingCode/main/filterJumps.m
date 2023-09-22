function ptableAll = filterJumps(ptableAll, phaseThreshold)
%filterJumps Summary of this function goes here
%   Detailed explanation goes here

%label bad curves
badRow = findjumps(ptableAll, phaseThreshold);
ptableAll = addvars(ptableAll,badRow);

%exclude bad curves
%find all arcs that have been given a bad filter and remove
% ptableAll = ptableAll(find(ptableAll.badArc==0) , :);
ptableAll = ptableAll(find(ptableAll.badRow==0) , :);

end