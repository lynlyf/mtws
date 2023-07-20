function [M,sz,dim] = nda2mtx(A,dim)
%% [M,sz,dim] = nda2mtx(A,dim)
% covert a ndarray to a matrix (shift given dim of A to dim 1, then reshape)
%
% tips:
%  * `nda2mtx(matrix,1)` returns the matrix itself
%  * `nda2mtx(matrix,2)` returns the transpose
%  * `nda2mtx(ndarray,1)` is equivalent to `reshape(ndarray,sz(1),[])`
%  * `mtx2nda(M,sz,dim)` does the inverse
%
% input:
%   A: ndarray
%   dim: given dim of A => dim 1 of M
%     if `dim` is empty or not specified, set to the first non-singleon dim
% output: matrix, size of A, dim
%
% see also: mtx2nda, permute, shiftdim, shiftdata
%%
if nargin == 0
    subfcn_demo;
    return;
end

if nargin<2, dim = []; end
[dim,sz,nd] = fdim(A,dim);
if dim==1 && nd==2
    M = A;
    return;
elseif dim > 1 % shift given dim to dim 1    
    A = permute(A,[dim,1:dim-1,dim+1:nd]);
end
 M = reshape(A,sz(dim),[]);
%%

%% SUBFUNCTIONS
function subfcn_demo
%% buildtin demo
verb(1,'run buildin demo of ',mfilename);
A = reshape(1:12,2,3,2);
assert(isequal(nda2mtx(A,-2),[1,3,5;2,4,6;7,9,11;8,10,12].'),'test failed');
assert(isequal(mtx2nda(nda2mtx(A,2),size(A),2),A),'test failed');
verb(1,'...test passed');
%% EOF