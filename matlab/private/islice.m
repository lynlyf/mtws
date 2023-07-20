function idx = islice(nd,varargin)
%% return index like {':',...,ind_i,...,ind_j,...,':'}
% usage:
%   {id1,...} = islice(nd[,def_idx],dim_i,ind_i,dim_j,ind_j,...)
%         ... = islice(A[,def_idx],dim_i,{istart[,istop,istop]},...)
%
%% input:
% nd: [ndims of] ndarray
% def_idx: indexing for dims not specified (default, ':')
%     [] and NaN imply ':'
% dim_X: dim id
% ind_X: index along dim_X
%   | {istart[,istop[,istep]]} if `nd` is a ndarray
%   nan is equivalent to ':'
%% output: index like {':',...,idX,...,':'}
%
%% example:
% > islice(3) % {':',':',':'}
% > islice(rand(2,3),nan|':') % {':',':'}
% > islice(reshape(1:2*3*4,2,3,4),':',2,{-1,-2},1,{1,2},3,2)
% > islice(3,':',2,1:2) % {':',1:2,':'}
% > islice(3,2,nan,3,1) % {':',':',1}
% > islice(1:10) % {':',':'}
% > islice(1:10,nan|':') % 1:10
% > islice(1:10,{1}) % 1:10
% > islice(1:10,2:4) % [2,3,4]
%
% see also: bysub, idconv; ind2sub, sub2ind, num2cell
%%
if nargin == 0
    subfcn_demo;
    return;
end

if isempty(nd)
    error('`nd` cannot be empty');
elseif isscalar(nd) %(ndim,...)
    sz = nan(1,nd);
else %(arr,...)
    if isscalar(varargin) && isvector(nd) %(x,id); shortcut for vector
        idx = subfcn_idx(varargin{1},length(nd));
        return;
    end
    
    sz = size(nd);
    nd = length(sz);
end
assert(nd>0,'nd must be positive integer');

% default index
narg = length(varargin);
if mod(narg,2) == 0 % (nd,i1,ind1,...)
    idef = {':'}; 
else % (nd,def_ind,i1,ind1,...)
    [idef,varargin] = deal(varargin(1),varargin(2:end)); 
    if isempty(idef) || (isscalar(idef{1}) && isnan(idef{1}))
        idef = {':'};
    end
end

%% make {ind1,ind2,...}
idx = repmat(idef,1,nd);
for ii = 1 : 2 : length(varargin)
    [iX,indX] = deal(varargin{ii:ii+1});
    if iX<0, iX= nd+iX+1; end
    idx{iX} = subfcn_idx(indX,sz(iX));
    %% codes moved to `subfcn_idx`
%     if iscell(indX) % {istart[,istop[,istep]]}
%         [istart,istop,istep] = deal(indX{1},sz(iX),nan);
%         if length(indX)>1, istop = indX{2}; end
%         if length(indX)>2, istep = indX{3}; end
%         if istart<0, istart = istart+sz(iX)+1; end
%         if istop<0, istop = istop+sz(iX)+1; end
%         if isnan(istep)
%             istep = 2 * (istart <= istop) - 1;
%         end
%         indX = istart : istep : istop;
%     elseif isscalar(indX) && isnan(indX) % nan, equivalent to ':'
%         indX = ':'; 
%     end
%     idx{iX} = indX;
end
%% 

%% SUBFUNCTIONS
function idx = subfcn_idx(idx,len)
%% return an index vector
if iscell(idx) % {istart[,istop[,istep]]}
    [istart,istop,istep] = deal(idx{1},len,nan);
    if length(idx)>1, istop = idx{2}; end
    if length(idx)>2, istep = idx{3}; end
    if istart<0, istart = istart+len+1; end
    if istop<0, istop = istop+len+1; end
    if isnan(istep)
        istep = 2 * (istart <= istop) - 1;
    end
    idx = istart : istep : istop;
elseif isscalar(idx) && isnan(idx) % nan, equivalent to ':'
    idx = ':'; 
end
%%

function subfcn_demo
%% builtin demo
verb(1,'run builtin demo of ',mfilename);
A = reshape(1:12,3,4);
idx = islice(A,1,2);
assert(all(A(idx{:})==A(2,:)),'...2d test failed');
A = reshape(1:2*3*3*4,2,3,3,4);
idx = islice(A,2,1:2,3,2:3);
assert(isequal(idx,{':',1:2,2:3,':'}),'...nd test failed');
idx = islice(rand(2,3,4),':',2,{-1,-2},1,{1,2},3,2);
assert(isequal(idx,{1:2,[3,2],2}),'...nd test failed');
idx = islice(rand(2,3,4),':',2,{-1,-2},1,{1},3,{-1,2,-2});
assert(isequal(idx,{[1,2],[3,2],[4,2]}),'...nd test failed');
verb(1,'...test passed');
%% EOF
