function [dim,sz,nd] = fdim(x,dim)
%% [dim,sz,nd] = fdim(x,dim)
% return target dim, size and ndims
%
% tips:
%   * `fdim(x)|fdim(x,[])` returns the first non-singleon dim
%   * `fdim(x,-dim)` returns nd-dim+1
%   * if `x` is empty or scalar, raises error
%   * size([])=[0,0], ndims([])=2
%   * size(1)=[1,1], ndims(1)=2
%
% inputs:
%   x: ndarray
%   dim: given dim
% output:
%   dim: target dim
%   sz: size(x)
%   nd: ndims(x)
%
% see also: permute, shiftdim
%%
if nargin == 0
    subfcn_demo;
    return;
end

sz = size(x);
nd = length(sz);
if nargin<2 || isempty(dim)
    dim = find(sz>1,1);
    assert(~isempty(dim),'x is empty or scalar');
else    
    if dim<0, dim = dim+nd+1; end
    assert(dim==fix(dim)&&1<=dim&&dim<=nd,'invalid dim');
end
%%

%% SUBFUNCTION
function subfcn_demo
%% builtin demo
verb(1,'run builtin demo of ',mfilename);
assert(fdim(rand(1,2,3))==2,'test failed');
assert(fdim(rand(1,2,3),-2)==2,'test failed');
verb(1,'...test passed');
%% EOF