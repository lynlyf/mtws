function a = cell2arg(c,def,alias)
%% a = cell2arg(c,def,alias)
% Convert cell array to argument struct, and/or set defaults
%
% notes:
%   * matlab struct keeps filednames by their creation order so that
%         cellarr = arg2cell(cell2arg(cellarr))
%   * isempty(struct()) returns false
%
% input:
%   c: {'name',value,...} | {{...}} | struct
%      if being a struct, return with defaults set and alias parsed
%      if being {'name',value,...}, convert to a.name=value
%      if being {struct}|{{'name',value,...}}, process c{1}
%   def: defaults, {'name',defval,...} | struct(.name=defval)
%      it is valid to use alias in defaults
%   alias: alias dict; see `fldren` and `parse_alias`
% output: struct
%
% example:
%   > arg2cell(cell2arg({'b',2,'a','aa'}))
% see also: arg2cell, fldset; cell2struct, struct2cell
%%
if nargin == 0
    subfcn_demo;
    return; 
end

if isempty(c), c = struct(); end
if nargin<2, def = []; end % don't use `struct()` for which isempty(..) is false
if nargin<3, alias = []; end

if isa(c,'containers.Map'), c = map2struct(c); end
if isstruct(c) % [] | struct
    if nargin == 1
        a = c;
    else
        a = subfcn_update(c,def,alias);
    end
    return;
end

assert(iscell(c),'c should be a {struct} or {''name'',value,...}');
if isscalar(c) % {{'name', value, ...}} | {struct}
    a = subfcn_update(c{1},def,alias);
    return;
end

%% cell array {'name',value,...} to struct(.name=value)
a = subfcn_update(c,def,alias);
%%

%% SUBFUNCTIONS
function [a,def,alias] = subfcn_update(c,def,alias)
%% defaults and alias
if ~isvector(c)
    assert(ismatrix(c),'wrong size of cell');
    [n1,n2] = size(c);
    if n1==2 && n2>2 % c = {names;values}
        c = reshape(c,1,[]);
    elseif n1>2 && n2==2 % c = {names,values}
        c = reshape(c.',1,[]);
    else
        error('wrong shape of cell');
    end
end
if ~isempty(alias) % alias in both args and defaults are parsed
    if ~isempty(def), def = fldren(def,alias); end 
    c = fldren(c,alias); 
end
if ~isempty(def), c = fldupdate(c,1,def); end
if isstruct(c)
    a = c;
else
    a = struct();
    for ii = 1:2:length(c), a.(c{ii}) = c{ii+1}; end
end
%%

function subfcn_demo
%% builtin demo
verb(1,'run builtin demo of ',mfilename);
a = struct('a1',1);
c = {'a1',1};
assert(isequal(a,cell2arg(a)),'test failed');
assert(isequal(a,cell2arg({a})),'test failed');
assert(isequal(a,cell2arg({c})),'test failed');
assert(isequal(struct('a1',1,'a2',0),cell2arg(a,{'a1',0,'a2',0})),'test failed');
assert(isequal(struct('a',1,'b',0),cell2arg(c,{'a1',0,'a2',0},{'a','a1','b','a2'})),'test failed');
verb(1,'...test passed');
%% EOF
