function dist = dpointline(pt,lnpt1, lnpt2)
%dpointline gets distance from a point to a line
%   Anthony McDougal, Sungsam Kang, Zahid Yaqoob, Peter So, and Mathias Kolle, 2021 

%   Formula used is 
% ax + by + c = 0
% y = ax +c


a = (lnpt2(2) - lnpt1(2)) / (lnpt2(1) - lnpt1(1));
b = -1;
c = -b*lnpt1(2) - a*lnpt1(1);

dist = abs(a*pt(1) + b*pt(2) + c) / sqrt(a^2 + b^2) ;

end

