function [selectedFrq,selecPeak,fsampleP,fs, df] = getProfileFreq(aProfile,clUmRot,maxPeriod)
%getProfileFreq selects dominant frequency from a profile
%   aProfile is the profile to be analyzed
%   clUmRot is the length position, to be used to determine um frequency
%   maxPeriod is used to filter out low frequency signals
%   Anthony McDougal, Sungsam Kang, Zahid Yaqoob, Peter So, and Mathias Kolle, 2021


%Pixel (interval) size for profile, 
pxSizeProf = (clUmRot(end)-clUmRot(1))/ (length(clUmRot)-1); %um/px, i.e. length of pixel of LINEAR PROFILE, _not_ image px size
freqRes = 1/pxSizeProf; %samples/um
fs = freqRes; %sampling frequency

%Pad profile to get better interpolation of frequency
L = 2^(nextpow2(length(aProfile))+2);
%Calculate Fourier transform
fsampleP = fft(aProfile, L);

N = length(fsampleP);
df = (0:N-1)*fs/N; %frequency resolution, frequency axis

%Helpful visualizations, may uncomment to troubleshoot
% figure, plot(df,log10(abs(fftshift(fsampleP))));
% figure, plot(df,abs(fsampleP));

%Convert maxPeriod to frequency threshold
fpass = 1 / maxPeriod;
%Find dominant frequencies
[pks, frqs] = findpeaks(abs(fsampleP(1:N/2-1)),df(1:N/2-1),'SortStr','descend');
%Eliminate frequencies that do not pass threshold
pks(frqs<fpass) = 0;
pks = nonzeros(pks);
frqs(frqs<fpass) = 0;
frqs = nonzeros(frqs);

%Ouput dominant (filtered) frequency (and array position)
selectedFrq = frqs(1);
selecPeak = pks(1);
w = 1/frqs(1);

end

