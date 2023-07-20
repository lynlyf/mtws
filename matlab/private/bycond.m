function val = bycond(cond,varargin)
%% return value by condition(s)
% usage: val = ...
%   bycond(condition,val4true,val4false) % returns the value for true|false
%   bycond([cond1,cond2,...,condN],val4cond1,val4cond2,...,val4condN,defval)
%          % returns the value for the first true condition, or `defval` if all are false
%   bycond([conds],val4true,val4false) % returns an array the same size as [conds]
%   bycond({conds},val4true,val4false) % returns a cell array the same size as {conds}
%   bycond(cond,{...}) % expands values in {...} before continuing
%
% examples:
%   > bycond(2<1,'a','b') % 'b'
% see also: where
%%    
if nargin == 0
    subfcn_demo;
    return; 
end

if isscalar(varargin) && iscell(varargin{1}) % (condition,{val4true,val4false})
    varargin = varargin{1}; 
end

out_cell = iscell(cond); % output cell array if `cond` is a cell array
if out_cell, cond = cat(1,cond{:}); end
cond = logical(cond);

nc = numel(cond);
nv = length(varargin);
if nc>1 && nv==2 % ([cond1,cond2,...],val4true,val4false)
    if out_cell
        val = varargin(2-cond);
    else
        val = nan(size(cond));
        for ii=1:nc, val(ii) = varargin{2-cond(ii)}; end
    end
    return;
end

assert(nc+1==nv,'length(cond)+1 should equal to length(vals)');
for ii = 1 : nc % ([cond1,cond2,...],val4true,val4false)
    if cond(ii)
        val = varargin{ii};
        return;
    end
end
val = varargin{nv};
%%

%% SUBFUNCTION
function subfcn_demo
%% builtin demo
verb(1,'run builtin demo of ',mfilename);
assert(bycond(0,1,2)==2,'test failed');
assert(bycond([0,1],'a','b','c')=='b','test failed');
assert(bycond([0,0],{'a','b','c'})=='c','test failed');
assert(bycond({0,1},{'a','b','c'})=='b','test failed');
verb(1,'...test passed');
%% EOF
