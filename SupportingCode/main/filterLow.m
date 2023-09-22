function ptableAll = filterLow(ptableAll,lowestLevel)
%filterLow removes curves of a table that go below threshold 

%label low curves
hasLowArc = false(size(ptableAll.arcZ));

for id = 1:height(ptableAll)
    lowPoint = ptableAll.scaledZ(id,:) < lowestLevel;
    hasLowArc(id) = any(lowPoint);
end



ptableAll = addvars(ptableAll,hasLowArc);

%Keep all curves that do NOT have a low arc
ptableAll = ptableAll(find(ptableAll.hasLowArc==0) , :);

ptableAll = removevars(ptableAll,"hasLowArc");


end

