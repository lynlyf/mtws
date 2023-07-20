function [sh,id] = specf2h(sf,dim)
%% [sh,id] = specf2h(sf,dim)
% return spectrum for f>=0.
%
% input:
%   sf: full spectrum, complex vector|matrix|ndarray
%   dim: spectrum along dim (default, the first non-singleon dim)
% output: spectrum and idx for f>=0
% 
% see also: fftfreq, fftspec, spech2f, rfft, irfft
%%
if nargin == 0
    subfcn_demo;
    return;
end

sz = size(sf);
if nargin<2 || isempty(dim) % first non-singleon dim
    dim = find(sz>1,1,'first'); 
elseif dim < 0 % wrap dim
    dim = length(sz) + dim + 1;
end

if dim ~= 0
    nfft = sz(dim);
    id = 1:ceil((nfft+1)/2);
end
if isvector(sf)
    sh = sf(id);
elseif ismatrix(sf)
    if dim ==0  % fft2 to upper-right part for f1>=0 and f2>=0
        sh = sf(1:ceil((sz(1)+1)/2),1:ceil((sz(2)+1)/2));
    elseif dim == 1 % upper half for f1>=0
        sh = sf(id,:);
    else % right half for f2>=0
        sh = sf(:,id); 
    end
else
    idx = islice(length(sz),dim,id);
    sh = sf(idx{:});
end
%%

%%
function subfcn_demo
%% builtin demo
verb(1,'run builtin demo of ',mfilename);
% make data
dt = 0.1; % sampling interval
n = 1e4;
t = (0:n-1) * dt;
x = preproc(rand(1,n)+0.04*sin(2*pi/1*t),[1/20,2]*2*dt).';
% compare spectra
[y,nfft] = rfft(x);
y2 = spech2f(y,nfft,-2);
x2 = bysub(ifft(y2,nfft),1:n);
mkfig; hl = plot([x,x2,x-x2]); 
setprop(hl(3),'ls','--','lw',2,'col','k');
legend('original','ifft(spech2f)','diff');
%% EOF