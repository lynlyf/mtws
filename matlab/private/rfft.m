function [y,n] = rfft(x,n,dim)
%% [y,nfft] = rfft(x,nfft,dim)
% slice spectrum for f>=0 using `specf2h`
%
%   For length N input vector x, the DFT is given by
%                    N
%      X(k) =       sum  x(n)*exp(-j*2*pi*(k-1)*(n-1)/N), 1 <= k <= N.
%                   n=1
%   The inverse DFT is given by
%                    N
%      x(n) = (1/N) sum  X(k)*exp( j*2*pi*(k-1)*(n-1)/N), 1 <= n <= N.
%                   k=1
%
% input:
%   x: ndarray
%   n: npts of fft (default, [])
%   dim: apply fft along given dim (default, first non-singleon dim)
%     if <0, wrap to ndims+dim+1, namely, -1 means the last dim
% output:
%   y: spectrum for f>=0
%   n: nfft 
%
% see also: fft, irfft, fftspec, fftfreq
%%
if nargin == 0
    subfcn_demo;
    return;
end

if nargin<2, n = []; end
if nargin<3
    dim = find(size(x)>1,1); % first non-singleon dim
elseif dim < 0 % wrap dim
    dim = ndims(x) + dim + 1;
end

if ~isempty(n)
    n = fix(n);
    assert(n>=size(x,dim),'nfft<npts will discard the last npts-nfft samples');
end

y = fft(double(x),n,dim);
if isempty(n), n = size(y,dim); end
y = specf2h(y,dim);
%%

%%
function subfcn_demo
%% builtin demo
verb(1,'run builtin demo of ',mfilename);
n = 1e3;
x = randn(n,1); x = x - mean(x);
[y,nfft] = rfft(x,[],-2);
y2 = spech2f(y,nfft);
x2 = bysub(ifft(y2,nfft),1:n);
mkfig([800,400],'name',['demo of ',mfilename]); 
hl = plot([x,x2,x-x2]); 
setprop(hl(3),'ls','--','lw',2,'col','k');
legend('original','ifft(spech2f(rfft))','diff');
%% EOF