function [y,nfft,f] = fftspec(x,nfft,dim,fflag,aflag,fs)
%% [y,nfft,f] = fftspec(x,nfft,dim,fflag,aflag,fs)
% return fft spectrum
%
% input:
%   x: signal, ndarray
%   nfft: npts of fft
%     if nfft==2, nfft is set to 2^nexppow2(npts)
%     if nfft is empty (default) or <npts, nfft is forced to be npts
%   dim: dim to compute fft
%     if not specified (default), set to the first non-singleon dim
%   fflag: true for full spec | false (default) for f>=0 only
%   aflag: 0 (default) for complex spectrum
%          2 for power |fft|^2/npts
%          otherwise spectral amplitude |fft|
%   fs: sampling rate (default, 2) needed if `f` is to be outputed
% output: spectrum, nfft, freqs
%   y: spectrum
%   nfft: npts of fft
%   f: freqs, `fftfreq(fs,nfft,fflag)` 
%
% see also: fftfreq, fftfreq2, spech2f, specf2h, fftplot, specfilt, specwhiten
%%
if nargin == 0
    subfcn_demo;
    return;
end

sz = size(x);
nd = length(sz);
if nargin<3 || isempty(dim)
    dim = find(size(x)>1,1);
elseif dim<0
    dim = nd + dim + 1;
end
npts = sz(dim);
if nargin<2 || isempty(nfft)
    nfft = npts; 
elseif nfft==2
    nfft = nextpowk(npts,2);
elseif nfft<npts
    nfft = npts; 
end
if ~exist('fflag','var')||isempty(fflag), fflag = false; end
if ~exist('aflag','var')||isempty(aflag), aflag = false; end

y = fft(x,nfft,dim);
if ~fflag
    if isvector(x)
        y = y(1:ceil((nfft+1)/2));
    else
        idx = islice(ndims(x),dim,1:ceil((nfft+1)/2));
        y = y(idx{:});
    end
end
if aflag==2, y = abs(y).^2/npts; elseif aflag, y = abs(y); end

if nargout>2
    if ~exist('fs','var') || isempty(fs), fs = 2; end
    f = fftfreq(fs,nfft,fflag);
end
%%

%%
function subfcn_demo
%% builtin demo
verb(1,'run builtin demo of ',mfilename);
dt = 0.1; % sampling interval
n = 1e4; % npts
t = (0:n-1) * dt;
Tc = 1;
% without tapering, large amplitudes at low freqs (~100s)
x = preproc(rand(1,n)+0.05*sin(2*pi/Tc*t),[1/100,2]*2*dt,0.03);
mytic = tic;  [y,nfft,f] = fftspec(x,[],[],false,1,1/dt);  t1 = toc(mytic);
mytic = tic;  y0 = abs(fft(x,nfft));  t0 = toc(mytic);
verb(1,sprintf('fft cost %gs; %s cost %gs (%g times)',t0,mfilename,t1,t1/t0));
% f = fftfreq(1/dt,nfft,0); 
ff = fftfreq(1/dt,nfft,-1); % freqs in matlab convention
mkfig; plot(fftshift(ff),fftshift(y0), f,y);
xlabel('f (Hz)'); ylabel('Spectral magnitude');
legend('matlab fft',mfilename);
%% EOF