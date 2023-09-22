function combScales = combineScalesTable(dirIn)
%combineScalesTable gets all the measurement files in a folder.
%   Detailed explanation goes here


flist = dir(dirIn);
combScales = table;

for i = 1:length(flist)
%     disp(i)s
    filein = fullfile(flist(i).folder,flist(i).name);

    thisRoi = simplifyStruct(filein);
    singleScale = mkProtoridgeTable(thisRoi);

    combScales = [combScales; singleScale];
end


end