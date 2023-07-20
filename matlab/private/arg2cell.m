function c = arg2cell(a,flag_chkvnm,flag_sort)
%% c = arg2cell(a,flag_chkvnm,flag_sort)
% Convert struct|container.Map to cell array, namely,
% struct('name',value,...} => {'name',value,...}
%
%% input:
%   a: struct(.name=value)
%      if already {'name',value,...}, check if 'name's are valid varnames.
%   flag_chkvnm: check validity of varnames or not (default, false)
%   flag_sort: sort name-value pairs by fieldnames or not (default, false)
%      if not sorted, 'name's are in the creation order of filednames.
%      if `a` is a containers.Map, `a.keys` have been sorted
%% output: {'name',value,...}
%
% see also: cell2arg, releasevar, parse_alias, fldren, fldupdate
%%
if nargin == 0
    subfcn_demo;
    return; 
end

if nargin<2||isempty(flag_chkvnm), flag_chkvnm = false; end
if nargin<3, flag_sort = false; end

if isa(a,'containers.Map')
    keys = a.keys;
    %if flag_sort, keys = sort(keys); end
    n = length(keys);
    c = cell(1,2*n);
    for ii = 1 : n
        c{2*ii-1} = keys{ii};
        c{2*ii} = a(keys{ii});
    end
    if flag_chkvnm, subfcn_check(c); end    
    return;
end

if iscell(a) % already a cell array
    if flag_chkvnm, subfcn_check(a); end
    c = a;
    if flag_sort
        [c(1:2:end),id] = sort(a(1:2:end));
        c(2:2:end) = a(2*id);
    end
    return;
end

assert(isscalar(a)&&isstruct(a),'`a` should be a struct'); 
c = {};
if isempty(a), return; end
names = fieldnames(a);
if flag_sort, names = sort(names); end
n = length(names);
c = cell(1,2*n);
for ii = 1 : n    
    c{2*ii-1} = names{ii};
    c{2*ii}   = a.(names{ii});
end
%%

%% SUBFUNCTION
function subfcn_check(c)
%% check the validity of variable names
if isodd(length(c)), error('c should be in pairs, {name, value, ...}'); end
for ii = 1 : 2 : length(c)
    if ~ischar(c{ii})
        error('%s type cannot be a variable name', class(c{ii}));
    elseif ~isvarname(c{ii})
        error('%s is not a valid variable name',c{ii}); 
    end
end
%%

function subfcn_demo
%% builtin demo
verb(1,'run builtin demo of ',mfilename);
d = {'c','cc','a','aa','b','bb'};
assert(isequal(arg2cell(d,[],1),{'a','aa','b','bb','c','cc'}),'test failed');
d = struct('c','cc','a','aa','b','bb');
assert(isequal(arg2cell(d,1),{'c','cc','a','aa','b','bb'}),'test failed');
d = containers.Map({'c','a','b'},{'cc','aa','bb'});
assert(isequal(arg2cell(d),{'a','aa','b','bb','c','cc'}),'test failed');
verb(1,'...test passed');
%% EOF
