function ht = textcell(varargin)
%% add a cell of text to an axes
% usage:
%   ht = textcell([ha,]x,y[,z],cstr,'name',value,...)
%   ht = textcell([ha,][x,y[,z]],cstr,'name',value,...)
%   ht = textcell([ha,]{xpct,ypct[,zpct]},cstr,'name',value,...)
%   ht = textcell([ha,]{xpct},{ypct}[,{zpct}],cstr,'name',value,...)
%   ht = textcell([ha,]x,y,[],vector,'name',value,...)
%   ht = textcell('text') % add a text to center of current axes
%
% name-value pairs are passed to `text`
%
% see also: bordertext, scattertext
%%
if nargin==1 || ischar(varargin{1})
    ht = subfcn_get(varargin{:});
    return; 
end

[ha,x,y,z,s,args] = subfcn_parse(varargin{:});
argdef = {'tag',[mfilename,'_text']};
ns = numel(s);
ht = gobjects(1,ns);
for ii = 1 : ns
    if isempty(z)
        ht(ii) = text(x(ii),y(ii),s{ii},argdef{:},args{:},'parent',ha);
    else
        ht(ii) = text(x(ii),y(ii),z(ii),s{ii},argdef{:},args{:},'parent',ha);
    end
end
%%

%% SUBFUNCTIONS
function [ha,x,y,z,s,args] = subfcn_parse(varargin)
%% parse inputs
[ha,z] = deal([]);
if isaxes(varargin{1},1) % (ha,...)
    [ha,varargin] = deal(varargin{1},varargin(2:end));
end
% look for text to add
found = false;
for ii = 1 : length(varargin)
    if ischar(varargin{ii}) || iscellstr(varargin{1})
        found = true;
        break;
    end
end
if found
    if mod(length(varargin(ii+1:end)),2)==0
        [d,s,args] = deal(varargin(1:ii-1),varargin{ii},varargin(ii+1:end));
    else % (...,num_vec,'prop',value,...)
        [d,s,args] = deal(varargin(1:ii-2),varargin{ii-1},varargin(ii:end));
    end
elseif ii==length(varargin) % (...,num_vec)
    [d,s,args] = deal(varargin(1:ii-1),varargin{ii},{});
else
    error('no text found');
end
% cellstr to add
if ischar(s)
    s = {s};
elseif isnumeric(s)
    s = cellstr(num2str(s(:)));    
end
assert(iscellstr(s),'[cell]str expected');

% text arguments
args = hgargs('text',args);
iax = find(strcmpi(args(1:2:end),'parent'),1,'last');
if ~isempty(iax), ha = args{2*iax}; end
if isempty(ha), ha = gca; end
assert(isaxes(ha),'invalid axes handle');

if isempty(d) % ([ha,]'text',...); add text to axes center
    [x,y] = deal(mean(ha.XLim),mean(ha.YLim));
elseif isscalar(d)
    p = d{1};
    if iscell(p) % ([ha,]{xpct,ypct[,zpct]},'text',...)        
        [xl,yl] = deal(double(get(ha,'xlim')),double(get(ha,'ylim')));
        x = xl(1) + (xl(2)-xl(1))*p{1};
        y = yl(1) + (yl(2)-yl(1))*p{2};
        if length(p) > 2
            zl = get(ha,'zlim');
            z = zl(1) + (zl(2)-zl(1))*p{3};
        end
    else % ([ha,][x,y[,z]],'text',...)
        if size(p,2)>3, p = p.'; end
        [x,y] = deal(p(:,1),p(:,2));
        if size(p,2)==3, z = p(:,3); end
    end
else
    [x,y] = deal(d{:});  % ([ha,]x,y,'text',...)
    if iscell(x)      
        xl = get(ha,'xlim');
        x = xl(1) + (xl(2)-xl(1))*[x{:}];
    end
    if iscell(y)      
        yl = get(ha,'ylim');
        y = yl(1) + (yl(2)-yl(1))*[y{:}];
    end
    if length(d)==3 % ([ha,]x,y,z,'text',...)
        z = d{3};
        if iscell(z)      
            zl = get(ha,'zlim');
            z = zl(1) + (zl(2)-zl(1))*[z{:}];
        end
    elseif length(d)>3
        disp(varargin);
        error('unable to parse inputs');
    end
end
if isscalar(x), x = x*ones(size(y)); end
if isscalar(y), y = y*ones(size(x)); end
if isscalar(z), z = z*ones(size(x)); end
if isscalar(s)
    s = repmat(s,size(x));
elseif isscalar(x)
    n = length(s);
    [x,y] = deal(x*ones(n,1),y*ones(n,1));
    if isscalar(z), z = z*ones(n,1); end
end
assert(length(x)==length(s),'wrong size of `x|str`'); 
%%

function ht = subfcn_get(varargin)
%% find text handles
ha = gchg('ax');
if isempty(ha)
    verb(1,'no valid axes');
    ht = [];
    return;
end

switch lower(varargin{1}) % ('opt')
    case {'get'} % find tag='textcell_text' on current axes
        ht = findobj(ha,'tag',[mfilename,'_text']);
    case {'gca'} % find text on current axes
        ht = findobj(ha,'type','text');
    case {'gcf'} % find text on current figure
        hf = get(ha,'Parent');
        ht = findobj(hf,'type','text');
    case {'getall'} % find text on all figures
        ht = findobj('type','text');
    otherwise % add text to center of current axes
        ht = textcell(ha,mean(xlim),mean(ylim),varargin{:});
end
%% EOF