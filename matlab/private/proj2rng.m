function y = proj2rng(x,rng,xb)
%% project data to given range
% usage: y = ...
%   proj2rng(x,@proj) %return proj(x)
%   proj2rng(x,@proj,{xlo,xhi}) %return proj(clip(x))
%   proj2rng(x,[lo,hi]) %equivalent to proj2rng(x,[lo,hi],[min(x),max(x)])
%   proj2rng(x,[lo,hi],[xlo,xhi]) %linear projection (xlo->lo, xhi->xhi)
%   proj2rng(x,[lo,hi],{xlo,xhi}) %project clip(x,[xlo,xhi]) to [lo,hi]
%
%% input:
%  x: data array
%  rng: [lo hi] for a linear projection from [xlo,xhi] to [lo,hi]
%     | function handle, nonlinear projection can be feasible
%  xb: [xlo,xhi], x values ouside `xb` are projected as is
%    | {xlo,xhi}, clip x values to [xlo,xhi]
%% output: new data
%%
if nargin == 0
    subfcn_demo;
    return; 
end

%if nargin<2||isempty(rng), rng = [0,1]; end
if nargin<3
    xb = getbound(x);
elseif iscell(xb) % clip x data
    xb = [xb{1},xb{end}];
    x(x<xb(1)) = xb(1);
    x(x>xb(2)) = xb(2);
end
    
if isa(rng,'function_handle')
    y = rng(x);
    return;
end

assert(xb(1)~=xb(2),'null x range');

% linear projection
y = rng(1) + (x-xb(1))*(rng(2)-rng(1))/(xb(2)-xb(1));
%%

%% SUBFUNCTION
function subfcn_demo
%% builtin demo
verb(1,'run builtin demo of ',mfilename);
assert(isequal(-1:1,proj2rng(1:3,[-1,1])),'test failed');
assert(isequal(-2:2,proj2rng(0:4,[-1,1],[1,3])),'test failed');
assert(isequal([-1,-1:1,1],proj2rng(0:4,[-1,1],{1,3})),'test failed');
verb(1,'...test passed');
%% EOF