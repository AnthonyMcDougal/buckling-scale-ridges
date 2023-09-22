function ddirPhase = phaseGradOr(PimgsIn)
%phaseGradOr calculates the orientation of the phase gradient
%   Anthony McDougal, Sungsam Kang, Zahid Yaqoob, Peter So, and Mathias Kolle, 2021 
%   The orientation of the phase gradient, which encodes the local slope at
%   the scale surface.

dyPhase = angle(PimgsIn./(circshift(PimgsIn, [1 0 0])));
dxPhase = angle(PimgsIn./(circshift(PimgsIn, [0 1 0])));

dmagPhase = sqrt((dxPhase).^2 + (dyPhase).^2);
ddirPhase = atan2(dyPhase,dxPhase);

end

