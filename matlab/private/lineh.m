function h = lineh(varargin)
%% Add horizontal lines to axes and return the handles
% usage:
%    h = lineh; % ha=gca, y=0, x=xlim(ha)
%    h = lineh([ha,]y[,linestyle],'name',value,...); % x=xlim(ha)
%    h = lineh([ha,]y,x[,linestyle],...);
%    h = lineh([ha,]y,{xlo,xhi}[,linestyle],...);
%    lineh('get|del|rm')
%
% example:
%  > lineh(1,'r');
%  > lineh(1:5,[0,1]);
%  > lineh(1:2,[0,1;1,2],'lw',2);
%  > lineh(1:2,{0.4,0.8});
% see also: linev, liner, linec, linemk
%%
if hgdel(mfilename,'line',varargin), return; end
if 1<=nargin && nargin<=2 && isequal(varargin{end},'get') % ([hf|ha,]'get')      
    h = hgfind(varargin{1:end-1},'tag',mfilename,'type','line');
    return;
end

[ha,y,x,args] = subfucn_parse(varargin{:});
n  = numel(y);
ys = [y(:),y(:),nan(n,1)].';
ys = ys(:);
xs = [x(1)*ones(1,n); x(2)*ones(1,n); nan(1,n)];
xs = xs(:);
zid = find(strcmpi(args,'zdata'));
if ~isempty(zid)
    if isempty(args{zid+1})
        args(zid:zid+1) = [];
    elseif isscalar(args{zid+1})
        args{zid+1} = repmat(args{zid+1},size(x));
    else
        try
            args{zid+1} = reshape(args{zid+1},size(x));
        catch
            verb(1,'**WARNING: wrong size of zdata**');
            args(zid:zid+1) = [];
        end
    end
end
h = plot(xs,ys,args{:},'Parent',ha);
%%

%% SUBFUNCTION
function [ha,y,x,args] = subfucn_parse(varargin)
%% parse args
hasax = nargin>0 && length(varargin{1})==1 && isaxes(varargin{1});
if hasax % lineh(ha,...)
    [ha,varargin] = deal(varargin{1},varargin(2:end));
else
    id = find(strcmpi(varargin,'parent'),1,'first');
    if isempty(id) % lineh(y,...)
        ha = gca; 
    else % lineh(y,...,'parent',ax,...)
        [ha,varargin] = deal(varargin{id+1},varargin([1:id-1,id+2:end])); 
    end
end        
set(ha,'nextplot','add');

if length(varargin) <= 1
    x = xlim(ha);
    if isempty(varargin) % lineh
        y = 0;
    else % lineh([ax,]y)
        y = varargin{1};
    end
    varargin = {};
else % lineh([ax,]y[,x][,linestyle],'name',value,...)
    [y,varargin] = deal(varargin{1},varargin(2:end));
    if ischar(varargin{1}) % lineh(y,...)
        x = xlim(ha);
    else % lineh([ax,]y,x,...)
        [x,varargin] = deal(varargin{1},varargin(2:end));
    end
end

if isempty(x)
    x = xlim(ha);
elseif iscell(x) % ([ha,]y,{xlo,xhi},...)
    xl = xlim(ha);
    x = xl(1) + (xl(2)-xl(1))*[x{1}(:),x{2}(:)];
end

args = varargin;
argdef = {'XLimInclude','off','YLimInclude','off','ZLimInclude','off', ...
          'ALimInclude','off','CLimInclude','off','Color',0.5*[1,1,1], ...
          'LineWidth',1,'Tag',mfilename};
if mod(length(args),2)
    [argdef,args] = deal([args(1),argdef],args(2:end));
end
args = [argdef,subfcn_color(hgargs('line',args))];
%%

function c = subfcn_color(c)
%% color name to [r,g,b]
if isempty(c), return; end
if iscell(c) % {...,'color',x,...} to {...,'color',[r,g,b],...}
    ic = find(strcmpi(c(1:2:end),'color'));
    if isempty(ic), return; end
    c{2*ic(end)} = subfcn_color(c{2*ic(end)});
    c([2*ic(1:end-1)-1,2*ic(1:end-1)]) = [];    
    return;
end
if isscalar(c) && isnumeric(c) && isnan(c) % random color
    c = rand(1,3);
    return;
end
if ~ischar(c)||strcmpi(c,'none'), return; end
c = cminterp(1,c); % colorname to [r,g,b]
%% EOF
