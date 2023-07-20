function a = fldcopy(a,varargin)
%% copy fields of source struct to new struct
% usage: newstruct = ...
%   fldcopy([],st,{'fld1','fld2',...}) % extract fields from struct
%   fldcopy([[],]st,'fld1','fld2',...)
%   fldcopy(st_dest,st_src,'fld1','fld2',...) % copy from st_src to st_dest
%   fldcopy(st_dest,st_src,{'fld1','fld2',...})
%
% note:
%  * (struct,{'fld1',...}) is not supported
% 
% input:
%   a,b: struct to and from
%   flds: fieldnames to copy, comma-separated str | cellstr
%     if not specified, copy all fields of b
%   id: slice the properties of b by index and assign into a if specified
% output: struct with new fields added
%
% example:
%   > fldcopy([],{'a',1,'b',2'},'a')
% see also: fldclean, fldjoin, fldopr, fldslice
%%
if nargin == 0
    subfcn_demo;
    return;
elseif nargin == 1
    a = struct(a);
    return;
end

if isempty(a) % ([],struct,...)
    [a,b,flds] = deal(struct(),varargin{1},varargin(2:end));
    %if isscalar(flds)&&iscellstr(flds{1}), flds = flds{1}; end   
elseif ischar(varargin{1}) % (struct1,'fld1','fld2',...)
    [a,b,flds] = deal(struct(),a,varargin);
else % (struct1,struct2,...})
    [a,b,flds] = deal(cell2arg(a),varargin{1},varargin(2:end));
end
b = cell2arg(b);
if isscalar(flds)&&(ischar(flds{1})||iscellstr(flds{1})), flds = flds{1}; end
if isempty(flds)
    flds = fieldnames(b); 
elseif ischar(flds)
    flds = strsplit(strrep(flds,' ',''),','); 
end
% if ~isvector(flds)
%     assert(size(flds,2)==2,'wrong alias dict');
% end
for ii = 1 : length(flds)
    a.(flds{ii}) = b.(flds{ii});
end
%%

%% SUBFUNCTION
function subfcn_demo
%% Builtin demo
verb(1,'run builtin demo of ',mfilename);
a = struct('x',1,'y',2);
assert(isequal(fldcopy(a,'y'),struct('y',2)),'test failed');
assert(isequal(fldcopy(a,'x,y'),a),'test failed');
assert(isequal(fldcopy(a,'x','y'),a),'test failed');
assert(isequal(fldcopy([],a,'y'),struct('y',2)),'test failed');
assert(isequal(fldcopy([],a,'x,y'),a),'test failed');
assert(isequal(fldcopy([],a,{'x','y'}),a),'test failed');
assert(isequal(fldcopy(a,{'x',0,'z',3}),struct('x',0,'y',2,'z',3)),'test failed');
assert(isequal(fldcopy(a,struct('x',0,'z',3),'z'),struct('x',1,'y',2,'z',3)),'test failed');
verb(1,'...test passed');
%% EOF
