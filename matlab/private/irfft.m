function x = irfft(y,n,dim)
%% x = irfft(y,n,dim)
% inverse fft for spectrum of f>=0
%
% input:
%   y: spectrum for f>=0, ndarray
%   n: nfft | [nfft,npts]
%     if npts is specified (npts<=nfft), `x` is cut to that length
%   dim: spectrum along dim (default, the first non-singleon dim)
% output: signal
% 
% see also: fftfreq, fftspec, specf2h, spech2f, rfft
%%
if nargin == 0
    subfcn_demo;
    return;
end

sz = size(y);
if nargin<3 || isempty(dim) % first non-singleon dim
    dim = find(sz>1,1,'first'); 
elseif dim < 0 % wrap dim
    dim = length(sz) + dim + 1;
end
npts = [];
if nargin<2 || isempty(n) % guess from half spec assuming even nfft
    verb(1,'guess nfft by assuming an even number');
    nfft = 2 * (sz(dim)-1);
else
    if isscalar(n)
        nfft = n; 
    else
        [nfft,npts] = deal(n(1),n(2)); 
        assert(npts<=nfft,'nfft<npts');
    end
    assert(2*(sz(dim)-1)<=nfft&&nfft<=2*sz(dim)-1,'wrong nfft or incomplete half spectrum');
end

y = spech2f(y,nfft,dim);
x = real(ifft(y,nfft,dim));
if ~isempty(npts) % cut to given npts
    id = repmat({':'},1,ndims(x));
    id{dim} = 1:npts;
    x = x(id{:}); 
end
%%

%% SUBFUNCTION
function subfcn_demo
%% builtin demo
verb(1,'run builtin demo of ',mfilename);
dt = 0.1; % sampling interval
n = 1e4;
t = (0:n-1) * dt;
x = preproc(rand(1,n)+0.04*sin(2*pi/10*t),[1/100,2]*2*dt).';
% compare
ha = mkaxes(2,1,'ti',1); 
x2 = irfft(rfft(x(:),n));
axes(ha(1)); hl = plot(t,[x,x2,x-x2]); 
setprop(hl(3),'ls','--','lw',2,'col','k');
legend('original','irfft(rfft)','diff');
x2 = irfft(rfft(x,n+1),[n+1,n]);
axes(ha(2));hl = plot(t,[x,x2,x-x2]); 
setprop(hl(3),'ls','--','lw',2,'col','k');
legend('original','irfft(rfft)','diff');
%% EOF
