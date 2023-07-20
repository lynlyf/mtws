function [s,sid] = subvec(y,x,xb)
%% slice vector y for x in given boundary xb
% usage: [s,sid] = ...
%   subvec(x,xb) | subvec([],x,xb);  % s=x(sid) in [xlo,xhi]
%   subvec(y,x,xb);  % s=y(sid) in [xlo,xhi]
%
%% tips:
% * ways to get index of subvec:
%   1. [sid,sid] = subvec(1:length(x),x,xb)
%   2. [~,sid] = subvec(x,xb) | subvec([],x,xb) | subvec(x,x,xb)
%
%% input:
%   y: data vector (if `y` is empty, then make y=x)
%   x: x data that must be in **ascending** order
%   xb: [xlo,xhi], so that xb(1)<=x(sid)<=xb(end)
%     if xb(1)>xb(2), then output `s` and `sid` in reversed order
%% output: 
%   s: sliced vector
%   sid: selected index
%
% see also: isinrng, subarr, submat
%%
if nargin == 0
    subfcn_demo;
    return; 
end

if nargin<3 % (x,xb) => (x,x,xb)
    [x,xb] = deal(y,x); 
elseif length(x)==2 % (y,[x1,xn],[xlo,xhi])
    x = linspace(x(1),x(2),length(y));
end
if isempty(y), y = x; end
assert(isvector(y),'y should be vector');
n = length(y);
if isempty(x)||(ischar(x)&&isequal(x,':')), x = 1:n; end

if xb(1) > xb(end) % reverse
    sid = find(x>=xb(end),1,'first') : find(x<=xb(1),1,'last');
    sid = sid(end:-1:1);
    s = y(sid);
else
    sid = find(x>=xb(1),1,'first') : find(x<=xb(end),1,'last');
    s = y(sid);
end
%%

%% SUBFUNCTION
function subfcn_demo
%% builtin demo
verb(1,'run builtin demo of ',mfilename);
[s,id] = subvec(1:10,[2,5]);
assert(isequal(s,2:5)&&isequal(id,2:5),'test failed');
[s,id] = subvec(1:10,':',[2,5]);
assert(isequal(s,2:5)&&isequal(id,2:5),'test failed');
[s,id] = subvec(0:9,1:10,[2,5]);
assert(isequal(s,1:4)&&isequal(id,2:5),'test failed');
[s,id] = subvec(0:9,1:10,[5,2]);
assert(isequal(s,4:-1:1)&&isequal(id,5:-1:2),'test failed');
verb(1,'...test passed');
%% EOF
