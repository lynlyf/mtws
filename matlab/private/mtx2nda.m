function A = mtx2nda(M,sz,dim)
%% A = mtx2nda(M,sz,dim)
% convert matrix to ndarray [inverse operation of `nda2mtx`]
%
% tips:
%  * `mtx2nda(M,[n1,n2],1)` returns `M` itself
%  * `mtx2nda(M,[n1,n2],2)` returns `M.'`
%
% input:
%   M: 2d matrix
%   sz: size of output ndarray
%   dim: size(M,1) <--> size(A,dim)
% output: ndarray
%
% see also: nda2mtx, ipermute
%%
if nargin == 0
    subfcn_demo;
    return;
end

msz = size(M);
assert(length(msz)==2,'M should be 2d matrix');
nd = length(sz);
if dim<0, dim = nd+dim+1; end
if nd == 2
    if dim==1, A = M; else; A = M.'; end
    return;
end
A = reshape(M,[msz(1),sz([1:dim-1,dim+1:nd])]);
A = ipermute(A,[dim,1:dim-1,dim+1:nd]);
%%

%% SUBFUNCTIONS
function subfcn_demo
%% buildtin demo
verb(1,'run buildin demo of ',mfilename);
sz = [2,3,4];
dim = 2;
A = reshape(1:prod(sz),sz);
assert(isequal(A,mtx2nda(nda2mtx(A,dim),sz,dim)),'test failed');
verb(1,'...test passed');
%% EOF