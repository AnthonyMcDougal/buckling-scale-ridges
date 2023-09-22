function [newX,newY] = rotCoordinates(cx_array,cy_array)
%rotCoordinates takes an array of x and y values which are not aligned in
%x and y (e.g. close to a rotated meshgrid), and gives the meshgrid with 
%coordinates aligned cordinates
%   designed to work with an array of k sampled profiles --> c(:,k)

refID = 1; %reference line
pID = 1; %reference point

% test if right angle
ax = cx_array(end,refID) - cx_array(1,refID);
ay = cy_array(end,refID) - cy_array(1,refID);
a = [ax, ay];

bx = cx_array(pID,end) - cx_array(pID,1);
by = cy_array(pID,end) - cy_array(pID,1);
b = [bx, by];

testAngle = (180/pi) * acos( dot(a,b)/( norm(a)*norm(b)));

angleThresh = 89.0;
if testAngle<angleThresh
    msg = ['angle is not right angle (less than', num2str(angleThresh), '): angle = ' num2str(testAngle)];
%     error(msg)
    warning(msg)
end

% get new x
xArray = cx_array(:,refID);
yArray = cy_array(:,refID);
newXVec = sqrt((xArray-xArray(1)).^2 + (yArray-yArray(1)).^2);

% get new y
xArray = cx_array(pID,:);
yArray = cy_array(pID,:);
newYVec = sqrt((xArray-xArray(1)).^2 + (yArray-yArray(1)).^2);

[newX, newY] = ndgrid(newXVec, newYVec);

end

