function [Xnew,Ynew,Znew] = flatPlane(X,Y,Z)
%flatPlane rotates a plane to have minimal slope
%   Linear regression for a plane
%   May need to double-check some angles...

B = [X(:), Y(:), ones(size(X(:)))] \ Z(:);

Zplane = [X(:), Y(:), ones(size(X(:)))]*B;
Zplane = reshape(Zplane,size(X));

% figure
% mesh(X,Y,Zplane)
% colormap(viridis)
% axis image
% 
% %Compare figures
% figure
% mesh(X,Y,Z)
% colormap(viridis)
% axis image
% hold on
% surf(X,Y,Zplane)
% colormap(viridis)
% axis image

% rotate plane
t1 = atan(B(1));
t2 = atan(-B(2)); %ok
% t3 = atan(-B(3));

rotmatx = [1, 0, 0; 0, cos(t2), -sin(t2); 0, sin(t2), cos(t2)];
rotmaty = [cos(t1), 0, sin(t1); 0, 1, 0; -sin(t1), 0, cos(t1)];
% rotmatz = [cos(t), -sin(t), 0; sin(t), cos(t), 0; 0, 0, 1];

% [newSurf] = rotmatx * [X(:)'; Y(:)'; Z(:)'];
% [newSurf] = rotmaty * [X(:)'; Y(:)'; Z(:)'];
[newSurf] = rotmatx * rotmaty * [X(:)'; Y(:)'; Z(:)'];
Xnew = reshape(newSurf(1,:),size(X));
Ynew = reshape(newSurf(2,:),size(X));
Znew = reshape(newSurf(3,:),size(X));

end

