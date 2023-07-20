function a = fldren(s,varargin)
%% change fieldnames of a struct
% usage: s = fldren(s,newname,oldname,...)
%        s = fldren(s,alias_dict)
%
% if an alias name appears more than once, only the first match is considered.
%
% input:
%   s: struct(.name=value) | {'name',value,...}
%   alias_dict: {'name',{'aliasname1',...},...}
% output: struct with new fieldnames
%
% examples:
%   > fldren(struct('a2','aa','b1',2),'a','a1,a2','b','b1') 
%   > fldren({'a2','aa','b1',2},{'a','a1,a2','b','b1'}) 
% see also: fldlist, fldupdate, fldvalue, renameStructField
%%    
if nargin == 0
    subfcn_demo;
    return; 
end

c = arg2cell(s); % {'fld1',val1,'fld2',val2,...}
alias = cell2arg(varargin); % alias.name={'alias1',...}
assert(isstruct(alias)&&isscalar(alias),'wrong alias dict');
names = fieldnames(alias);
for ii = 1 : length(names) % loop over each alias       
    if ischar(alias.(names{ii})) % make alias names a cell array
        alias.(names{ii}) = strsplit(strrep(alias.(names{ii}),' ',''),',');
    end
    for jj = 1 : length(alias.(names{ii})) % look for alias names
        id = find(strcmp(c(1:2:end),alias.(names{ii}){jj}));
        if isempty(id), continue; end
        c(2*id-1) = {names{ii}};
    end
end
a = cell2arg(c);
%%

%% SUBFUNCTION
function subfcn_demo
%% builtin demo
verb(1,'run builtin demo of ',mfilename);
d = struct('a2','aa','b1',2);
c = fldren(d,'a','a1,a2','b','b1') ;
assert(isequal(arg2cell(c,1),{'a','aa','b',2}),'test failed');
verb(1,'...test passed');
%% EOF
