function plotTransparent(Xdata,Zdata)
%plotTransparent plots data with transparent curves
%   Detailed explanation goes here

if size(Xdata)~=size(Zdata)
    msg = 'dimensions of x and z are not the same';
    error(msg)
end

% figure
for m = 1:size(Xdata,1)
    p(m) = plot(Xdata(m,:),Zdata(m,:),'Color', [0 0 0]);
    hold on
    p(m).Color(4) = .06;
end


end

