function arg = fldupdate(arg,varargin)
%% Update struct
% usage:
%   newstruct = fldupdate(struct[,neonly],'name',value,...)
%   newstruct = fldupdate(struct[,neonly],{'name',value,...})
%   newstruct = fldupdate(struct[,neonly],struct2)
%
% input:
%   arg: old struct
%   neonly: update non-existing fields only (default,false)
% output: new struct
% 
% example:
%   > fldupdate({'a',1},1,{'a',2,'b',2}) % used to set defaults
% see also: fldcopy, fldren, fldget
%%
if nargin == 0
    subfcn_demo;
    return;
end

if isempty(arg), arg = struct(); end
arg = cell2arg(arg);
neonly = false; 
if isnumeric(varargin{1})||islogical(varargin{1})
    [neonly,varargin] = deal(varargin{1},varargin(2:end));
end
kwdict = cell2arg(varargin);
keys = fieldnames(kwdict);
for ii = 1 : length(keys)  
    if neonly&&isfield(arg,keys{ii}), continue; end
    arg.(keys{ii}) = kwdict.(keys{ii});
end
%% 

%% SUBFUNCTIONS
function subfcn_demo
%% Builtin demo
verb(1,'run builtin demo of ',mfilename);
a = struct('a',1);
b = {'b',2};
assert(isequal(fldupdate(a,1,a),a),'test failed');
assert(isequal(fldupdate(a,b),struct('a',1,'b',2)),'test failed');
verb(1,'...test passed');
%% EOF