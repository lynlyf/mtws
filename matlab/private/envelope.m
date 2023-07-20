function E = envelope(X,dim,npad)
%% return the hilbert envelopes of X along a given dim
% usage:
%   E = envelope(vec,[],npad) % envelope of vector
%   E = envelope(X,dim,npad)  % envelope of ndarray
% 
% input:
%   X: ndarray
%   dim: calc envelope of given dim
%   npad: pad `npad` zeros to tail to suppress edge jumps
%     `npad` does not affect the output `E` size
% output: envelope ndarray
%
% see also: hilbert
%%

if isempty(X)
    E = [];
    return;
end

if nargin<3, npad = 0; else, npad = fix(npad); end
if nargin<2, dim = []; end
[dim,sz] = fdim(X,dim);
    
if isvector(X)
    dim = find(sz>1,1);
    assert(~isempty(dim),'X cannot be scalar');
end

M = nda2mtx(X,dim);
if npad>0, M = [M; zeros(npad,size(M,2))]; end
E = abs(hilbert(M));
if npad>0, E = E(1:end-npad,:); end
E = mtx2nda(E,sz,dim);
%% EOF
