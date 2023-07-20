function c = str2cell(s,delimiter,nospace)
%% c = str2cell(s,delimiter,nospace)
% str to cellstr
%
% input:
%   s: [cell]str
%   delimiter: delimiter (default, ',') 
%      if empty, process given str according to `nospace` (similar to `strtrim|strrep`)
%   nospace: flag for processing spaces
%       if <0, trim strs in cellstr (default)
%       if =0|false, no process
%       if >0, remove all spaces in input str and empty elements in ouput cellstr
% output: cellstr
%
% see also: strsplit
%% 
if nargin == 0
    subfcn_demo;
    return;
end

if nargin<2, delimiter = ','; end
if nargin<3, nospace = -1; end

if ischar(s), cs = {s}; else cs = s; end
assert(iscellstr(cs),'wrong s');
if isempty(delimiter) % (s,[],nospace)
    c = cellfun(@(x)subfcn_proc(x,nospace),cs,'uni',0);
    c = c(~cellfun(@isempty,c));
    return;
end

r = cell(size(cs));
for ii = 1 : length(cs)
    r{ii} = cellfun(@(x)subfcn_proc(x,nospace),strsplit(cs{ii},delimiter),'uni',0);
end
c = cat(2,r{:});
c = c(~cellfun(@isempty,c));
%%

%% SUBFUNCTIONS
function c = subfcn_proc(s,nospace)
%% process spaces in str
if nospace < 0 % trim
    c = strtrim(s);
elseif nospace > 0 % remove spaces
    c = strrep(s,' ','');
end
%%

function subfcn_demo
%% builtin demo
verb(1,'run builtin demo of ',mfilename);
a = ' a,  b c ';
assert(isequal(str2cell(a,',',1),{'a','bc'}),'test failed');
assert(isequal(str2cell(a,',',-1),{'a','b c'}),'test failed');
assert(isequal(str2cell(str2cell({'a,' ,'b,c'},',',1),',',1),{'a','b','c'}),'test failed');
verb(1,'...test passed');
%% EOF