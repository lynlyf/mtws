function sf = preproc(s,wn,tapfrac,dim)
%% sf = preproc(s,wn|b,tapfrac,dim)
% detrend, taper, and filter
%
%% tips:
% - better to taper ends before buterworth filtering
% - tapering is not important for FIR filter
% - the filter is zero-phase (by `filtfilt`)
%
%% input:
%   s: ndarray to process
% ---
%   wn: normalized freq band [flo,fhi]/fny for 2nd-ord `butterfilt` (iir)
%     | [flo,fc,fhi]/fny for `specfilt` (fir)
%  | b: wavelet to `conv` (like wavelet by `fir2|specfilt`)
% ---
%   tapfrac: taper fraction (default, 0.03) or npts (>=1)
%   dim: process along given dim (default, the first non-singleon dim)
%% output: processed data
%
% see also: taper, butterfilt, detrend, specfilt
%%
if nargin == 0
    subfcn_demo;
    return;
end

if isempty(s)
    sf = [];
    return;
end

sz = size(s);
nd = length(sz);
if nargin < 2
    wn = []; 
elseif ~isempty(wn)
    assert(isvector(wn)&&length(wn)>1,'wn should be a vector');
end
if nargin<3||isempty(tapfrac), tapfrac = 0.03; end
if nargin<4 % first non-singleon dim
    dim = find(sz>1,1);
elseif dim<0 % wrap dim
    dim = nd + dim + 1;
end

if length(wn)==2 && tapfrac<=0
    warning('better to taper ends before butterfilt');
end

if nd <= 2
    sf = subfcn_mtx(double(s),wn,tapfrac,dim);
else
    sf = subfcn_nda(double(s),wn,tapfrac,dim);
end
%%

%% SUBFUNCTIONS
function s = subfcn_nda(s,wn,pct,dim)
%% process ndarray; untested
sz = size(s);
if dim~=1, s = permute(s,[dim,1:dim-1,dim+1:length(sz)]); end
if pct>1, pct = pct / sz(dim); end % convert tapering npts to tap_frac
s = subfcn_mtx(reshape(s,sz(dim),[]),wn,pct,1);
s = reshape(s,sz);
%%

function s = subfcn_mtx(s,wn,pct,dim)
%% process matrix (2d array)
sz = size(s);
if pct>1, pct = pct / sz(dim); end % convert tapering npts to tap_frac
if dim == 1 % columnwise
    for ii = 1:sz(2), s(:,ii) = subfcn_vec(s(:,ii),pct,wn); end
else % row-wise    
    for ii = 1:sz(1), s(ii,:) = subfcn_vec(s(ii,:),pct,wn); end
end
%%

%% 
function s = subfcn_vec(s,pct,wn)
%% process vector
s = detrend(s);
% s = detrend(detrend(s,'constant'),'linear'); % demean, detrend
if pct>0, s = taper(s,pct); end % taper the ends
if isempty(wn), return; end % no filtering
nw = length(wn);
assert(nw>1,'invalid wn');
if nw == 2
    s = butterfilt(s,wn,2,true);
elseif nw <= 4
    s = specfilt(s,wn);
else % b (aka wavelet to convolve); 
    % note `filter(wn,1,s)|fftfilt(wn,s)` leads to a constant delay
    b = wn;
    s = conv(s,b,'same');
    %s = filtfilt(b,1,s);
end
%%

function subfcn_demo
%% buildtin demo
verb(1,'run buildin demo of ',mfilename);
dt = 0.2; % sampling interval in sec
fband = [1/10,1/2]; % [flo,fhi] in Hz
totlen = 3600; % total length in sec

ntot = fix(totlen / dt); % total npts
fs = 1 / dt; % sampling rate
fny = fs / 2; % nyquist freq
wn = fband / fny; % normalized freq band
t = (1:ntot).' * dt;

ntap = 1e3;
% s0 = CC_synrand(ntot+4*ntap,[1/1e3,1]/fny,ntap);
s0 = rand(ntot+4*ntap,1);
s = s0(2*ntap+(1:ntot));
% figure; plot((1-2*ntap:ntot+2*ntap)*dt,s0,'k',t,s,'r');
% linev([1-ntap,1,ntot,ntot+ntap]*dt,'b-.');

%% filter as a whole
sf0 = preproc(s0,wn,ntap);
sf = sf0(2*ntap+(1:ntot));
% figure; plot((1-2*ntap:ntot+2*ntap)*dt,sf0,'k',t,sf,'r');
% linev([1-ntap,1,ntot,ntot+ntap]*dt,'b-.','color',[1,1,1]*.5);

%% filter and join segments and compare with the filtered full trace
npts = 1.8e3 / dt; % npts of segments
id1 = 1 : npts; % index for first segment
ha = mkaxes(4,1,[],'ti',1);
for ii = 1:length(ha), plot(ha(ii),t,sf,'k'); end

% 50% tapering, 50% overlapping, stack overlaps
%  /\  good
%   /\  
tap = 0.5;
hop = (1-tap) * npts;
id2 = hop + id1;
s2 = preproc([s(id1),s(id2)],wn,tap);
ss = zeros((2-tap)*npts,1); 
ss(1:npts) = s2(:,1);
ss(1+hop:end) = ss(1+hop:end) + s2(:,2);
plot(ha(1),t(1:length(ss)),ss,'r');
linev(ha(1),[hop,npts]*dt,'b-.');

% stack overlaps
% ----\     good
%     /---- 
tap = 0.2;
hop = (1-tap) * npts;
id2 = hop + id1;
s2 = preproc([s(id1),s(id2)],wn,tap);
ss = zeros((2-tap)*npts,1); 
ss(1:npts) = s2(:,1);
ss(1+hop:end) = ss(1+hop:end) + s2(:,2);
plot(ha(2),t(1:length(ss)),ss,'r');
linev(ha(2),[hop,npts]*dt,'b-.');

% discard overlaps
% ----\     good
%    /---- 
tap = 0.2;
hop = (1-2*tap) * npts;
id2 = hop + id1;
s2 = preproc([s(id1),s(id2)],wn,tap);
ss = [s2(1:npts-tap*npts,1);s2(tap*npts+1:end,2)];
plot(ha(3),t(1:length(ss)),ss,'r');
linev(ha(3),[hop,hop+tap*npts,npts]*dt,'b-.');

% no tapering, no overlaps
% -----      small difference around joint
%      ----- 
id2 = npts + id1;
s2 = preproc([s(id1),s(id2)],wn,0);
ss = s2(:);
plot(ha(4),t(1:length(ss)),ss,'r');
linev(ha(4),npts*dt,'b-.');

axis(ha,'tight');
verb(1,'all looks fine; the last has small diff around joint');
%% EOF
