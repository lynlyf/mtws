function [f,df] = fftfreq(fs,nfft,fullflag)
%% [f,df] = fftfreq(fs,nfft,fullflag);
% generate frequency vector for fft
%
% index for [0,fny] can be unified as f(1:ceil((nfft+1)/2))
% 
% input: 
%   fs: sampling rate
%   nfft: npts for fft | signal so that nfft=length(signal)
%   fullflag: return full freqs (default) or freqs>=0
%     for even nfft, f(1:nfft/2+1)=0:df:fny for both full spec and half spec if fullflag>0;
%       if fullfalg<0, matlab convention (compatible with `fftshift`) is taken, namely,
%       f(nfft/2+1)=-fny for full spec and fny for half spec.
%     for odd nfft, f(1:(nfft-1)/2) is the same for full spec and half spec.
%     ** changed to this behaviour on 2018-01-10; not sure about the influence on other existing codes
% output:
%   f: freqs
%   df: frequency interval
%
% see also: fftspec, fftplot, spech2f, specf2h, specplot, specwhiten
%%
if nargin == 0
    subfcn_demo;
    return;
end

if nargin<3, fullflag = true; end
if length(nfft)>1, nfft = length(nfft); end
nfft = fix(nfft);
assert(nfft>2,'wrong nfft');

df = fs / nfft;
%% index for [0,fny] can be unified as 1:ceil((nfft+1)/2)
if fullflag % freqs for full spectrum
    if mod(nfft,2) % odd nfft; f(1:(nfft+1)/2) for spectrum in fband [0,fny]
        f = df * [0:(nfft-1)/2,-(nfft-1)/2:1:-1];
    else % even nfft; f(1:nfft/2+1) for spectrum in fband [0,fny];
        % idx 1:nfft/2+1 for [0,fny], nfft/2+1:nfft for [-fny,-df]
        if fullflag < 0 % note f(nfft/2+1)=-fny in this case
            f = df * [0:nfft/2-1,-nfft/2:1:-1];
        else % note f(nfft/2+1)=fny in this case
            f = df * [0:nfft/2,-nfft/2+1:1:-1];
        end
    end
else % f>=0
    if mod(nfft,2) % odd nfft; f(1:(nfft+1)/2) for spectrum in fband [0,fny]
        f = df * (0:(nfft-1)/2);
    else % even nfft; f(1:nfft/2+1) for spectrum in fband [0,fny]
        f = df * (0:nfft/2);
    end
end
%%

%% SUBFUNCTION
function subfcn_demo
%% builtin demo
verb(1,'run builtin demo of ',mfilename);
fs = 5;
nfft = 128;
n = ceil((nfft+1)/2);
[f,df] = fftfreq(fs,nfft,false);
assert(abs(f(n)-fs/2)<1e-6*df,'test failed');
[f,df] = fftfreq(fs,nfft);
assert(abs(f(n)-fs/2)<1e-6*df,'test failed');

nfft = 127;
n = ceil((nfft+1)/2);
[f,df] = fftfreq(fs,nfft,false);
assert(abs(f(n)-fs/2+df/2)<1e-6*df,'test failed');
[f,df] = fftfreq(fs,nfft);
assert(abs(f(n)-fs/2+df/2)<1e-6*df,'test failed');
verb(1,'...test passed');
%% EOF