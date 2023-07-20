function w = coswin(varargin)
%% Make a cosine window
% usage:
%   w = coswin(n,ntap|tapfrac); % return a n-point row vector
%   w = coswin(n,[ntap1|tapfrac1,ntap2|tapfrac2]); % return a n-point row vector
%   w = coswin(x,xl); % w is the same size as x
%
% tips:
%  * `coswin(n,0.5)` gives a hanning window
%  * coswin can be eithor symmetric or asymmetric
%  * `coswin(x,[])` returns []
%
% input:
%   n: length of window 
%   ntap|tapfrac: fraction(0 to 1) or npts(>1) to taper
%     + scalar, npts|fraction to taper head and tail
%     + [ntap1|tapfrac1,ntap2|tapfrac2], npts|fraction to taper head and tail
%   x: data vector
%   xl: x limits
%     + [xlo,xhi] for box window __|^^|__
%     + [xlo,xc,xhi] for triangle window __/\__
%     + [x1,x2,x3,x4] for flat-hat window __/^^\__
%   xln: normalized x limits defining tapering ranges
% output: cosine window
%%
if nargin == 0
    subfcn_demo;
    return;
end

if isscalar(varargin{1}) % (n,..)
    if nargin<2, tapfrac = 0.05; else, tapfrac = varargin{2}; end
    w = subfcn_ntap(varargin{1},tapfrac);
else % (x,xl)
    w = subfcn_xl(varargin{:});
end
%%

%% SUBFUNCTIONS
function w = subfcn_ntap(n,ntap)
%% make window by tapering head and tail
ntap = subfcn_frac2ntap(n,ntap);
w = ones(1,n);
w(1:ntap(1)) = 0.5 * (1 + cos(linspace(pi,2*pi,ntap(1))));
w((n-ntap(end)+1):n) = 0.5 * (1 + cos(linspace(0,pi,ntap(end))));
%%
    
function ntap = subfcn_frac2ntap(n,frac)
%% fraction to npts to taper
ntap = frac;
for ii = 1 : length(frac)
    if frac(ii) > 1
        ntap(ii) = ceil(frac(ii));
    else
        assert(0<=frac(ii)&&frac(ii)<=0.5,'wrong `tapfrac`');
        ntap(ii) = round(n*frac(ii)); 
    end
end
%%
    
function w = subfcn_xl(x,xl)
%% make window by tapering given ranges
if isempty(xl)
    w = [];
    return;
end
xl = xl(:);
if length(xl) == 2 % brick wall
    xl = xl([1,1,2,2]); 
elseif length(xl) == 3 % bell
    xl = xl([1,2,2,3]); 
end
assert(length(xl)==4 &&all(diff(xl)>=0), 'wrong xl');
w  = zeros(size(x));
id = closest(x,xl);
t1 = linspace(pi,2*pi,id(2)-id(1)+1);
t2 = linspace(pi,2*pi,id(4)-id(3)+1);
w(id(1):id(2)) = 0.5 * (1 + cos(t1));
w(id(3):id(4)) = 0.5 * (1 - cos(t2));
w(id(2):id(3)) = 1;
%%

function subfcn_demo
%% builtin demo
verb(1,'run builtin demo of ',mfilename);
x = 1 : 100;
w1 = coswin(length(x),0.3);
w2 = coswin(length(x),[0.2,0.4]);
w3 = coswin(x,[40,40,70]);
w4 = coswin(x,[10.5,30.2,50.4,95.6]);
ha = mkaxes(1,1);
linemk(ha,x,[w1;w2;w3;w4],'lw',2); grid(ha,'on'); 
legend({'30% symmetric','asymmtric','triangle','tropz'});
%% EOF
