function s = strcon(delimiter,varargin)
%% s = strcon(delimiter,s1,s2,...)
% join str using given delimiter
%% usage: s = ...
%   strcon(delimiter,s1,s2,...) % join s1, s2, ...
%   strcon(delimiter,{s1,s2,...}) % join s1, s2, ...
%   strcon(delimiter,s,{s1,s2,...},...) % join s with sX, ...
%   strcon(delimiter,{s11,s12,...},{s21,s22,...},...) % join s1X with s2X, ...
%
% * numbers can be handled automatically; or use `num2cstr` 
%   to convert number to cellstr
% * `strcon` is more flexible than `strjoin(cstr,'delimiter')`
% * `strjoin({},',')` returns ''; `strcon(',',{}|[])` raises error
%
%% input:
%   delimiter: delimiter | {delimiter, int_format, float_format}
%     default format: int, '%.0f'; float, '%.2f'
%   s1,s2,...: str | cellstr | numbers
%     - for str/scalar with cellstr/array, join str/scalar with
%       each element of cellstr/array
%     - for cellstr/array with cellstr/array, join corresponding elements
%% output: str or cellstr
%
%% example:
%   > strcon(',','a','',1:3) % {'a,,1', 'a,,2', 'a,,3'}
%   > strcon(',',1) % '1'
%   > strcon(',',1:3) % '1,2,3'
%   > strcon(',','a') % 'a'
%   > strcon(',','a','b') % 'a,b'
%   > strcon(',',{'a','b'}) % 'a,b'
%   > strcon(',',{'a'},1) % {'a,1'}
%   > strcon({',','%02d','%.2f'},[1,2-3j,5.5+2j]) % '01,02-3j,5.50+02j'
%   > strcon({' ','%d','%.1f'},1.1:2.1,'text') % {'1.1 text', '2.1 text'}
%   > strcon({'*','%d','%.1f'},[1.1:3.1;1.2:3.2],[1:3;4:6])
%       % {'1.1*1', '2.1*2', '3.1*3'; '1.2*4', '2.2*5', '3.2*6'};
%
%% see also: append, strcat, strjoin; cstrcon
%% 
if nargin==0
    subfcn_demo;
    return;
end

ifmt = '%.0f';
ffmt = '%.2f';
if iscell(delimiter)
    if length(delimiter)>1&&~isempty(delimiter{2}), ifmt = delimiter{2}; end
    if length(delimiter)>2&&~isempty(delimiter{3}), ffmt = delimiter{3}; end
    delimiter = delimiter{1};
end

s = subfcn_tostr(varargin{1},ifmt,ffmt);
if isscalar(varargin)
    if isscalar(s)
        s = s{1};
    elseif length(s)>1
        s = strcon({delimiter,ifmt,ffmt},s{:});
    end
    return;
end

for ii = 2 : length(varargin)
    s = subfcn_join(delimiter,s,subfcn_tostr(varargin{ii},ifmt,ffmt));
end

if isscalar(s) && iscell(s) && ~any(cellfun(@iscell,varargin))
    s = s{1}; 
end
%%

%% SUBFUNCTIONS
function s = subfcn_join(delimiter,s1,s2)
%% join the corresponding elements from two cells
if isscalar(s1)
    s = cellfun(@(s2_)[s1{1},delimiter,s2_],s2,'uni',0);
elseif isscalar(s2)
    s = cellfun(@(s1_)[s1_,delimiter,s2{1}],s1,'uni',0);
else % s1 and s2 must be of the same size
    assert(numel(s1)==numel(s2),'inconsistent size');
    s = cellfun(@(s1_,s2_)[s1_,delimiter,s2_],s1(:),s2(:),'uni',0);
end
%%

function s = subfcn_tostr(x,ifmt,ffmt)
%% convert to cellstr
if ischar(x)
    s = {x};
elseif isnumeric(x)
    assert(~isempty(x),'empty numeric array');
    s = arrayfun(@(x_)subfcn_num2str(x_,ifmt,ffmt),x,'uni',0);
elseif iscell(x)
    assert(~isempty(x),'empty cell');
    s = cellfun(@(x_)subfcn_tostr(x_,ifmt,ffmt),x);
else
    error('wrong type of input');
end
%%

function s = subfcn_num2str(x,ifmt,ffmt)
%% convert a complex/real number to a str
[xr,xi] = deal(real(x),imag(x));
if xi == 0 % real
    s = subfcn_real2str(xr,ifmt,ffmt);
elseif xr == 0 % pure imaginary
    s = [subfcn_real2str(xi,ifmt,ffmt),'j'];
else % complex
    s = [subfcn_real2str(xr,ifmt,ffmt), bycond(xi>0,'+',''), ...
         subfcn_real2str(xi,ifmt,ffmt), 'j'];
end
%%

function s = subfcn_real2str(x,ifmt,ffmt)
%% convert a real number to a str
s = sprintf(bycond(x==fix(x),ifmt,ffmt),x);
%%

function subfcn_demo
%% builtin demo
fprintf('run builtin demo of %s\n',mfilename);
assert(isequal('',strcon(',','')),'test failed');
assert(isequal('a',strcon(',','a')),'test failed');
assert(isequal('ab',strcon('',{'a','b'})),'test failed');
assert(isequal('1',strcon(',',1)),'test failed');
assert(isequal('1,2,3',strcon(',',1:3)),'test failed');
assert(isequal({'1:3','2:4'},strcon(':',1:2,3:4)),'test failed');
assert(isequal(strcon('',{'a','b'},1:2),{'a1','b2'}),'test failed');
assert(isequal(strcon('.','x',1:2),{'x.1','x.2'}),'test failed');
assert(isequal(strcon('',{'a','b'},'.',1:2),{'a.1','b.2'}),'test failed');
fprintf('...test passed\n');
%%