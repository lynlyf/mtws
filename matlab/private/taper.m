function s = taper(s,pct,dim)
%% s2 = taper(s,pct|win,dim)
% taper two ends of s
% 
% input:
%   s: ndarray
%   pct: percentage or npts at two ends to taper (default, 0.05)
%     if <=0.5, percentage of length to taper
%     if >1, npts to taper
%     if a vector, window to modulate `s` along given dim
%   dim: dimension to taper (default, first non-singleon dim)
% output: tapered data
%
% see also: coswin, preproc
%%
if nargin == 0
    subfcn_demo;
    return;
end

if nargin<2 || isempty(pct), pct = 0.05; end
if isempty(s)||pct<=0, return; end

if isvector(s)
    s = subfcn_vec(s,pct);
else
    sz = size(s);
    if nargin<3, dim = find(sz>1,1); elseif dim<0, dim = ndims(s)+dim+1; end
    s = subfcn_nda(s,pct,dim);
end
%%

%% SUBFUNCTIONS
function ntap = subfcn_ntap(n,pct)
%% return npts to taper
if pct>1, pct = pct/n; end % npts to percentage
assert(0<=pct&&pct<=0.5,'`pct` outside [0,0.5]');
ntap = round(n*pct);
%%

function s = subfcn_vec(s,pct)
%% taper a vector
if ~isscalar(pct) % `pct` is a window
    s = s .* reshape(pct,size(s));
    return;
end
n = length(s);
ntap = subfcn_ntap(n,pct);
if ntap<2, return; end
x = linspace(pi,2*pi,ntap);
w = 0.5*(1+cos(x));
if ~isrow(s), w = w.'; end
s(1:ntap) = s(1:ntap) .* w;
s(n-ntap+1:n) = s(n-ntap+1:n) .* w(end:-1:1);
%%

function s = subfcn_nda(s,pct,dim)
%% taper a ndarray
sz = size(s);
nd = length(sz);
wsz = ones(1,nd);
if dim<0, dim = nd+dim+1; end

if ~isscalar(pct)% taper(s,w,dim)
	wsz(dim) = sz(dim);
    w = reshape(pct,wsz);
    s = bsxfun(@times,s,w);
    return;
end

ntap = subfcn_ntap(sz(dim),pct);
if ntap<2, return; end
wsz(dim) = ntap;
x = linspace(pi,2*pi,ntap);
w = reshape(0.5*(1+cos(x)),wsz);
id = repmat({':'},1,nd);
id{dim} = 1 : ntap;
s(id{:}) = bsxfun(@times,s(id{:}),w);
id{dim} = (sz(dim)-ntap+1) : sz(dim);
s(id{:}) = bsxfun(@times,s(id{:}),w(end:-1:1));  
%%

function subfcn_demo
%% buildtin demo
verb(1,'run buildin demo of ',mfilename);
x = repmat(sign(detrend(rand(1,1000))),4,1);
y = [taper(x(1,:),0.5); taper(x(2:3,:),250,2); taper(x(4,:).',50).'];
mkfig; plot(bsxfun(@plus,x.', 0:2:2*size(x,1)-1),'k'); 
hold on; plot(bsxfun(@plus,y.',0:2:2*size(x,1)-1),'b');
%% EOF