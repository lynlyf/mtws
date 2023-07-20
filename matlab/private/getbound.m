function varargout = getbound(X,dim,pct)
%% [lo,hi] = getbound(X[,dim,pct]);
% return upper and lower boundary [at given percentiles] of b in dim direction
% or limits of all data if dim is empty
%
% input:
%   X: ndarray; if being a vector, `dim` is neglected
%   dim: which dim to work on (default,[])
%     if not specified or empty, return limits of all data
%   pct: [lo,hi] percentiles
% output: [lo,hi]
%   
% see also: getspan
%%
if nargin == 0
    subfcn_demo;
    return; 
end

if nargin<2, dim = []; end
if nargin<3
    pct = [];
else
    pct = [pct(1),pct(end)];
    assert(0<=pct(1)&&pct(2)<=100,'wrong pct');
    if pct(2)<=1, pct = 100*pct; end % x% to x
    if pct(1)==0&&pct(2)==100, pct = []; end
end
if isempty(dim) || isvector(X)
    if isempty(pct) % [lo,hi] of all data
        [lb,ub] = deal(min(X(:),[],'omitnan'), max(X(:),[],'omitnan'));
    else % prctiles of all data
        y = prctile(X(:),pct);
        [lb,ub] = deal(y(1),y(2));
    end
elseif isempty(pct) % [lo,hi] along dim
    % `min|max` returns array of the same ndims as X; size(lb|ub,dim)=1
    [lb,ub] = deal(min(X,[],dim), max(X,[],dim));
else % [lo,hi] prctiles
     lm = prctile(X,pct,dim); % size(lm,dim)=2
     ilo = islice(ndims(lm),dim,1);
     ihi = islice(ndims(lm),dim,2);
     [lb,ub] = deal(lm(ilo{:}),lm(ihi{:}));
end
if nargout>1
    varargout = {lb,ub};
else
    if isrow(lb)
        varargout = {[lb;ub]}; 
    elseif iscolumn(lb)
        varargout = {[lb,ub]}; 
    else 
        % varargout = {cat(dim(1),lb,ub)}; 
        varargout = {squeeze(cat(dim(1),lb,ub))};
    end
end
%%

%% SUBFUNCTION
function subfcn_demo
%% builtin demo
verb(1,'run builtin demo of ',mfilename);
x = reshape(1:6,2,3);
assert(isequal(getbound(x),[1;6]),'test failed');
assert(isequal(getbound(x,2),[1,5;2,6]),'test failed');
assert(isequal(getbound(x,2),[1,5;2,6]),'test failed');
x = repmat(reshape(-1:100,1,1,[]),2,2);
y = repmat(reshape([24,75],1,1,[]),2,2);
assert(isequal(getbound(x,-1,[25,75]),y),'test failed');
verb(1,'...test passed');
%% EOF