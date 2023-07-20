function varargout = specfilt(s,wn,nfft,dim)
%% fir filter via windowing spectrum | return a fir filter
% usage:
%   sf = specfilt(s,wn,nfft,dim); % firfilt
%    b = specfilt([],wn,[nfft[,npts]][,tapfrac]); % similar to `fir2`
%   
% * use `w = coswin(f,fl)` to make spectral window
% * in the presence of excessive pulse close to an end, the other end will be affected
%   => tapering ends helps.
%
% input:
%   s: signal, ndarray
%   wn: **normalized** freq limits | spectral window
%     + len(wn) between [2,4] => wn = [flo[,fc],fhi] | [f1,f2,f3,f4]
%     + len(wn)>4 => freqs for rfft
%   nfft: npts of fft (default, [])
%   dim: dim to apply fft and ifft
%   -----
%   npts: size of window in t-domain
%   tapfrac: fraction to taper ends of the window
% output: filtered signal | coefficients of fir filter
%
% see also: designfilt, fftfilt, fftspec, fir1, fir2, rfft
%%
if nargin == 0
    subfcn_demo;
    return;
end

if nargin<3, nfft = []; end
if nargin<4, dim = []; end

if isempty(s) % ([],wn,nfft,npts)
    if isempty(wn)
        varargout = {[],[],[]};
        return;
    end
    [b,w,f] = subfcn_fir(wn,nfft,dim);
    if nargout>0
        varargout = {b,w,f};
    else % plot filter
        fvtool(b,1);
    end
    return;
end

varargout = {subfcn_filt(s,wn,nfft,dim)};
%%

%% SUBFUNCTIONS
function [b,w,f] = subfcn_fir(wn,nfft,tapfrac)
%% make a window
if isempty(nfft)
    if wn(1)==0
        nfft = 2*fix(4/wn(2));
    else
        nfft = 2*fix(2/wn(1));
    end
end
[nfft,npts] = deal(nfft(1),nfft(end));
if isempty(tapfrac), tapfrac = 0; end
f = fftfreq(2,nfft,0);
w = coswin(f,wn); 
x = irfft(w,nfft);
hw = fix(npts/2);
b = x([nfft-hw+1:nfft,1:hw+1]);
if tapfrac>0, b = taper(b,tapfrac); end
%%

function sf = subfcn_filt(s,wn,nfft,dim)
%% filter signal with spectral windowing
[dim,sz,nd] = fdim(s,dim);
if isempty(nfft)||nfft<sz(dim), nfft = nextpowk(1.05*sz(dim),2); end    
[y,nfft] = rfft(s,nfft,dim);
if length(wn) > 4
    w = wn; 
else
    f = fftfreq(2,nfft,0); % f in [0,1]
    w = coswin(f,wn); 
end
% apply spectral windowing
wsz = ones(1,nd);
wsz(dim) = size(y,dim);
w = reshape(w,wsz);
yf = bsxfun(@times,y,w);
sf = irfft(yf,nfft,dim);
% make `sf` the same shape as `s`
id = islice(nd,dim,1:sz(dim));
sf = sf(id{:});
%%

%% SUBFUNCTIONS
function subfcn_demo
%% Builtin demo
verb(1,'run builtin demo of ',mfilename);
n = 5e2;
dt = 0.2;
t = (1:n)*dt;
Tc = 5;
x = sin(2*pi/Tc*t) + sin(2*pi/(3*Tc)*t);
flim = [1/8,1/Tc,1/4];
wn = flim * 2 * dt;
nfft = 2048;
specfilt([],wn,[nfft,51]);
y = specfilt(x,wn,nfft);
% y = specfilt(taper(x,0.05),wn);
ha = mkaxes(2,1);
plot(ha(1),t,x,'k',t,y,'r');
xlabel(ha(1),'t (s)');
ylabel(ha(1),'waveform');
f = fftfreq(1/dt,nfft,0);
plot(ha(2),f,abs(rfft(x,nfft))/n,'b',f,abs(rfft(y,nfft))/n,'r');
xlabel(ha(2),'f (Hz)');
ylabel(ha(2),'spectral amplitude'); 
xlim(ha(2),[0,0.5]);
batchfun(@(h)legend(h,'original','filtered'),ha); 
%% EOF
