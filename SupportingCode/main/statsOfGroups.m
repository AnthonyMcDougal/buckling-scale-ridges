function groupTable = statsOfGroups(wholeTable, groups, groupTable)

groupTable.meanProfile = splitapply(@mean, wholeTable.scaledZ, groups);
groupTable.stdProfile = splitapply(@std, wholeTable.scaledZ, groups);
groupTable.upperStd = groupTable.meanProfile + groupTable.stdProfile;
groupTable.lowerStd = groupTable.meanProfile - groupTable.stdProfile;
%the below may be improved?
groupTable.scaledX = splitapply(@mean, wholeTable.scaledX, groups);

end
