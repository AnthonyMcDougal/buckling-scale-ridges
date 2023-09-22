function [Pimg, varargout] = HT2D(img,varargin)
% Process amplitude and phase map of off-axis holographic image.
%   Anthony McDougal, Sungsam Kang, Zahid Yaqoob, Peter So, and Mathias Kolle, 2021 
% 
% input configuration
%   img: 2D off-axis interferogram
%   variable input: 
%           mi, mj, cmask: fixed off-axis parameters - x, y off-axis
%           distance, circular mask corresponding to numerical aperture of the system
%           option 'p': obtain off-axis parameters mi, mj, cmask
% output configuration
%   Pimg: complex field map
%   variable output:
%           with option 'p' input: mi, mj, cmask, DC (non-interfereing
%           image), contrast (average contrast map)
%           with off-axis parameters: DC, contrast
%
% Example
% [Pimg, DC, contrast] = HT2D(IMG)
%       : Generate amplitude and phase map. Automatically detect the off-axis
%       distance and mask size in spatial frequency domain. Choose maximum 
%       peak at 3rd or 4th quadrant of the k-space with 50 pixel margin
%       from the center. Mask size is determined by the half distance
%       between the off-axis peak to the center of the k-space. 
%
% [Pimg, mi, mj, cmask, DC, contrst] = HT2D(IMG, 'p')
%       : Generate amplitude and phase map. Automatically detect the off-axis
%       distance and mask size in spatial frequency domain. Output the
%       detected off-axis parameters.
%
% [Pimg, DC, contrast] = HT2D(IMG, mi, mj, cmask)
%       : Generate amplitude and phase map under the input off-axis
%       parameters. 


FFTIMAGE=0;
[xsize, ysize]=size(img);
nv=length(varargin);
% varargout=[];
if nv>2
    for ii=1:nv
        mi=varargin{1};
        mj=varargin{2};
        cmask=varargin{3};        
    end
    fixedkr=true;
    outpar=false;
elseif nv==1 && strcmpi(varargin{1}, 'p')
    fixedkr=false;
    outpar=true;
else 
    fixedkr=false;
    outpar=false;
end

Fimg = fftshift(fft2(double(img))); %FFT

if ~fixedkr
    tmp1=max(max(Fimg(round(xsize/2+xsize/50):xsize,1:round(ysize/2-ysize/50))));
    tmp2=max(max(Fimg(round(xsize/2+xsize/50):xsize,round(ysize/2+ysize/50):ysize)));
    [mi,mj]=find(Fimg==max(tmp1, tmp2));
%     [mi,mj]=find(Fimg==max(max(Fimg(round(xsize/2+xsize/50):xsize,1:ysize))));
%     [mi,mj]=find(Fimg==max(max(Fimg(round(xsize/10:xsize/2-xsize/50),round(ysize/10:(ysize/2-ysize/50))))));
    
    tmp22=Fimg;
%     tmp22=tmp22.*mkmask(20, xsize, [mi, mj]);
%     logimg(100, tmp22);
    
    mi=round(mi-xsize/2-1);
    mj=round(mj-ysize/2-1);
    

    
    dc=round(sqrt(mi.^2+mj.^2)./10);%round(sqrt(mi.^2+mj.^2)./8);
    dc1 = round(dc*4*1.3); %% half the distance from oth to 1st order.
    dc=round(dc/4);
    %Just force the mi value
    c1mask = ~(mk_ellipse(dc1,dc1,ysize,xsize));
    c3mask = c1mask.*1;
    cmask = conv2(c3mask,ones(dc),'same')/(dc.^2);
    if outpar
        varargout{1}=mi;
        varargout{2}=mj;
        varargout{3}=cmask;
    end
end
DCF=Fimg.*cmask;
Fimg = circshift(Fimg,[-mi -mj]);
Fimg = Fimg.*cmask;
% logimg(1001, Fimg);
Pimg = ifft2(ifftshift(Fimg)); %IFFT
if or((nargout>1 && ~outpar),   ((nargout>4)&& outpar))
    DC=abs(ifft2(ifftshift(DCF)));
    contrast=2*sum(sum(abs(Pimg))) / sum(sum(abs(DC)));
    if outpar 
        no=3;
    else no=0;
    end
    varargout{no+1}=DC;
    varargout{no+2}=contrast;
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function H = mk_circle(R,X,Y)
[XX YY]=meshgrid(1:X,1:Y);
H=(XX-X/2).^2+(YY-Y/2).^2<R.^2;
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function H = mk_ellipse(XR,YR,X,Y)
 
[XX YY]=meshgrid(1:X,1:Y);
H=((XX-X/2)./XR).^2+((YY-Y/2)./YR).^2>1.0;
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Out = PhaseShift (Uimg,px,py,isize,jsize)
is=10;
ie=isize-10;
js=10;
je=jsize-10;
if px==0 && py==0
  px=sum((Uimg(is:ie,js)-Uimg(is:ie,je)))/((ie-is+1)*(je-js+1));
  py=sum((Uimg(is,js:je)-Uimg(ie,js:je)))/((ie-is+1)*(je-js+1));
end
[XX YY]=meshgrid(1:jsize,1:isize);
Out=Uimg+XX.*px+YY.*py;
daout = Out;
%figure(20); plot(daout(200,:)), axis ([0 512 -6 6]),title('X-axis');
%figure(21); plot(daout(:,500)), axis([0 768 -6 6]),title('Y-axis');
%status = fclose('all');
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Phase Shift 
function Out = PhaseShift2(Uimg,is,ie,js,je)
py=sum((Uimg(is,js:je)-Uimg(ie,js:je)))/((ie-is+1)*(je-js+1));
px=sum((Uimg(is:ie,js)-Uimg(is:ie,je)))/((ie-is+1)*(je-js+1));
[XX YY]=meshgrid(1:jsize,1:isize);
Out=Uimg+XX.*px+YY.*py;
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Out = PowerShift(img,ii,jj,A); 
rd=3;
% ii=240;jj=100;
ii=ii/2; jj=jj/2;
Shift = mean2(img)
Out = img - Shift;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Out = PowerShift2(img,tlxval,tlyval,brxval,bryval); 
disp('Summmmm')
tlxval
tlyval
brxval
bryval

tlxval + tlyval + brxval + bryval
if tlxval == 0 & tlyval == 0 & brxval == 0 & bryval == 0
    Shift = 0;
else
    Shift = mean2(img(tlxval:tlyval,brxval:bryval));
end
Out = img - Shift;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%