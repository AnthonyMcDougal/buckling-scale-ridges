function [out, varargout]=ima2full(IMG, varargin)
% Process amplitude and phase map of 3D stacked off-axis interferogram.
%   Anthony McDougal, Sungsam Kang, Zahid Yaqoob, Peter So, and Mathias Kolle, 2021 
%
% input configuration
%   IMG: 3D stacked off-axis interferogram.
%   ref: Reference image to determine the off-axis parameters. Image size
%   should be the same as the image size in 'IMG'. Optional.
%
% output configuration
%   out: 3D stacked complex field map. 
%   par: Parameter struct containing off-axis parameters, complex map of
%   reference image, and average intensity of complex field maps.
%
% Example
% [out, par] = ima2full(IMG)
%       : Generate 3D stacked complex field maps. Off-axis parameters are
%       determined by a reference image which is automatically chosen from 
%       'IMG' stack. 
%
% [out, par] = ima2full(IMG, ref)
%       : Generate 3D stacked complex field maps. Off-axis parameters are
%       determined by 'ref'. 
%

sz=size(IMG);
scale=1;


if length(varargin)>0
    ref=varargin{1};
else
    tmp=IMG-circshift(IMG, [2,2,0]);
    conttmp=squeeze(mean(mean(tmp, 1), 2));
    [~, ind]=max(conttmp);
    ref=data.IMG(:,:, ind);
end

[Pref, mi, mj, cmask]=HT2D(ref, 'p');

IMGk=fftshift(fftshift(fft(fft(double(IMG), [], 1), [], 2), 1), 2);
IMGk=circshift(IMGk, [-mi -mj, 0]);
IMGk=IMGk.*repmat(cmask, [1 1 sz(3)]);

oszy=round(sz(1)*scale);
oszx=round(sz(2)*scale);

% % hh=(1:oszy)+round(sz(1)/4);
% % ww=(1:oszx)+round(sz(2)/4);
% 
hh=(-round(oszy/2):round(oszy/2)-1)+round(sz(1)/2)+1;
ww=(-round(oszx/2):round(oszx/2)-1)+round(sz(2)/2)+1;
% 

IMGk=IMGk(hh, ww, :);

out=ifft(ifft(ifftshift(ifftshift(IMGk, 1), 2), [], 1), [], 2)*scale^2;

if nargout>1
    par.ref=Pref;
    par.inten=squeeze(mean(mean(abs(out).^2, 1), 2));
    par.mi=mi;
    par.mj=mj;
    par.cmask=cmask;
    varargout{1}=par;
end
end