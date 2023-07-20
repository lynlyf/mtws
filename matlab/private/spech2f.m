function sf = spech2f(sh,nfft,dim)
%% sf = spech2f(sh,nfft,dim)
% convert spectrum for f>=0 to full spectrum
%
% * better to always specify nfft and dim
%
% input:
%   sh: spectrum for f>=0, complex vector|matrix|ndarray
%   nfft: nfft for given dim
%     if sh is 2d spectrum of rfft2, nfft=[nfft1,nfft2] 
%   dim: spectrum along dim (default, the first non-singleon dim)
% output: full spectrum
% 
% see also: fftfreq, fftspec, specf2h, rfft, irfft
%%
if nargin == 0
    subfcn_demo;
    return;
end

sz = size(sh);
nd = length(sz);
if nargin<3 || isempty(dim) % first non-singleon dim
    dim = find(sz>1,1,'first'); 
elseif dim < 0 % wrap dim
    dim = nd + dim + 1;
end
n = sz(dim);
if nargin<2 || isempty(nfft) % guess from half spec assuming even nfft
    verb(1,'guess nfft [assuming even nfft; invalid for rfft2]');
    nfft = 2*(n-1);
else
    nfft = fix(nfft);
    assert((isscalar(nfft)&&2*n-2<=nfft&&nfft<=2*n-1) || (2*n-2<=nfft(dim)&&nfft(dim)<=2*n-1), ...
            'wrong nfft or incomplete half spectrum');
end

% odd nfft, k=0, df*(0:(N-1)/2) to df*[0:(N-1)/2,-(N-1)/2:1:-1];
% even nfft, k=1, df*(0:N/2) to df*[0:N/2-1,+-N/2,-N/2+1:1:-1]
if isscalar(nfft), k = 1-mod(nfft,2); else; k = 1-mod(nfft(dim),2); end
if isvector(sh) % 1d fft
    sf = cat(dim,sh(1:n-k),conj(sh(n:-1:2)));
elseif ismatrix(sh)
    if isscalar(nfft) % 1d fft of matrix along given dim
        if dim == 1 % f1>=0 to full f1 for 1d spectra
            sf = cat(dim,sh(1:n-k,:),conj(sh(n:-1:2,:)));
        else % f2>=0 to full f2 for 1d spectra
            sf = cat(dim,sh(:,1:n-k),conj(sh(:,n:-1:2)));
        end
    else % rfft2 spectrum to fft2 spectrum; 
        % nfft=[N1,N2], if dim=1,
        % [odd,odd],   k=[0,0], df1*(0:(N1-1)/2) to df*[0:(N1-1)/2,-(N1-1)/2:-1]
        %                  f2 = df2*[0:(N2-1)/2,-(N2-1)/2:-1]
        % [even,even], k=[1,1], df1*(0:N1/2) to df1*[0:N1/2-1,+-N1/2,-N1/2+1:-1]
        %                  f2 = df2*[0:N2/2-1,+-N2/2,-N2/2+1:-1]
        if dim == 1
            sf = [sh(1:n-k,:); conj([sh(n:-1:2,1), rot90(sh(2:n,2:sz(2)),2)])];
        else
            sf = [sh(:,1:n-k), conj([sh(1,n:-1:2); rot90(sh(2:sz(1),2:n),2)])];
        end
    end
else % 1d fft of ndarray along give dim
    idx1 = islice(nd,dim,1:n-k);
    idx2 = islice(nd,dim,n:-1:2);
    sf = cat(dim,sh(idx1{:}),conj(sh(idx2{:})));
end
%%

%% SUBFUNCTION
function subfcn_demo
%% builtin demo
verb(1,'run builtin demo of ',mfilename);
% make data
dt = 0.1; % sampling interval
n = 1e4;
t = (0:n-1) * dt;
x = preproc(rand(1,n)+0.04*sin(2*pi/10*t),[1/100,2]*2*dt).';
% compare spectra
ha = mkaxes(2,1,'ti',1); 
axes(ha(1));
y = fft(x,n);   f = fftfreq(1/dt,n,1);   yf = spech2f(specf2h(y),n);
plot(f,abs([y,yf,y-yf]),'linewidth',2); 
legend('fft(even nfft)','spech2f(specf2h(fft))','diff');
axes(ha(2));
y = fft(x,n+1); f = fftfreq(1/dt,n+1,1); yf = spech2f(specf2h(y),n+1);
plot(f,abs([y,yf,y-yf]),'linewidth',2);
legend('fft(odd nfft)','spech2f(specf2h(fft))','diff');
%% EOF