function flag = hgdel(Tag,Type,varargin)
%% flag = hgdel(Tag,Type,[ax,]'del');
% remove hgobjs from axes
%
%% examples:
% > hgdel('','line','del') % delete lines with empty tag from current axes
% > hgdel('*',{'text','line'},ax,'del') % delete all lines and text from axes
%%
flag = false;
if isscalar(varargin) && iscell(varargin), varargin = varargin{1}; end
n = length(varargin);
if n<1 || n>2 || ~ischar(varargin{end}) || ...
        ~any(strcmpi({'rm','del','clear','clean'},varargin{end}))
     return;
end

flag = true;
if n == 1
    ax = gchg('ax'); 
else
    ax = varargin{1};
    ax = ax(ishghandle(ax));
    %assert(isaxes(ax,1),'invalid axes handle');
end
if isempty(ax)
    verb(1,'no axes available');
    return; 
end
if isequal(Tag,'*')
    hp = findobj(ax);
else
    hp = findobj(ax,'Tag',Tag);
end
if ~isempty(Type), hp = hp(arrayfun(@(h)istype(h,Type),hp)); end
if isempty(hp)
    verb(1,'no ',Tag,' to remove');
    return; 
end
verb(1,'remove ',Tag,' from ',get(ax,'Type'));
delete(hp); 
%% EOF