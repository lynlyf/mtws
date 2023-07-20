function h = hgfind(varargin)
%% h = hgfind([hp,]'name',value,...)
% find hgobjs 
%
% see also: hgdel
%%
if nargin==1 && ischar(varargin{1})
    varargin = {'tag',varargin{1}};
end
narg = length(varargin);
if mod(narg,2) % (hp,'name',value,...)
    [hp,varargin] = deal(varargin{1},varargin(2:end));
    hp = hp(ishghandle(hp));
else % ('name',value,...)
    hp = gchg('ax');
end
if isempty(hp)
    verb(1,'no parent handle specified');
    return;
end
args = hgargs(hp,varargin{:});
h = findobj(hp,args{:});
%% EOF