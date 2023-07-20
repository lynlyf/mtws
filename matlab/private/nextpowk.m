function [np,e] = nextpowk(n,k)
%% [np,e] = nextpowk(n,k)
% return next higher power of k for np=k.^e>=n
%
% * `nextpowk(n,2)` is equivalent to 2^nextpow2(n)
%
% input:
%   n: npts
%   k: base (default, 2)
% output: 
%   np: next higher power of k
%   e: exponent
%
% example:
%   > nextpowk(100) 
% see also: nextpow2
%%
if nargin<2, k = 2; end
assert(all(n>0)&&k>0,'n and k must be positive');
e = ceil(log(n)/log(k));
np = k.^e;
%% EOF
