function [roi] = simplifyStruct(measFile)
%simplifyStruct : takes the original messy data struct and creates a less messy
%struct
%   dataFile is a .mat file (typically saved as '*_meas.mat') with the data extracted from the raw phase data

load(measFile)

roi.surfZ = meas.phase_2DNewUmRot; %(unwrapped surface in microns)
roi.surfX = meas.cx_2DNewUmRot; %
roi.surfY = meas.cy_2DNewUmRot;

roi.measFile = measFile; %can use dir(roi.datafile) to get more info
roi.dataVolume = meas.DataVolume;
roi.dayAge = meas.Age;

roi.phaseD = meas.phaseD;

% redundant, but useful for other features
roi.meas = meas;

end