function badRow = findjumps(arcTable, jumpSizeThresh)
%findjumps returns a vector (to be used as a table column) that indicates
%where each arc has a phase jump that is unacceptable 

%   The assumptions for linear phase unwrapping require that pixel-to-pixel
%   does not jump by more than pi. 
%   A more aggressive filter would limit cases that are theoretically
%   allowed for phase unwrapping.

%   phaseD %the distance traveled for one rad, halved to account for reflection mode (double the distance was traveled)
%   phaseD = wavelength/(2*2*pi*n_RI); 

%   in general, our data takes the following:
%   wavelength = 800;
%   n_RI = 1.346; %refractive index of medium
%   >>> phaseD = 47.297159908438440

%   thus for our data:
%   2*pi in the phase data corresponds to 297.1768 nm

%% filter ridges (label good or bad)

badRow = false(size(arcTable.arcZ));

for id = 1:height(arcTable)
    jumpSize = diff(arcTable.arcZ{id}) / (arcTable.phaseD(id)/1000);
%     badPoint = abs(jumpSize)>pi;
    badPoint = abs(jumpSize)>jumpSizeThresh;
    
    badRow(id) = any(badPoint,(1));
end

% arcTable = addvars(arcTable, badRow);

end

