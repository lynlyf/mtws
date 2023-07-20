function h = linev(varargin)
%% add vertical lines to axes and return the handles
% usage:
%    h = linev; % add vertical line to current axes
%    h = linev([ha,]x[,linestyle],'name',value,...); % y=ylim(ha)
%    h = linev([ha,]x,[ylo,yhi][,linestyle],...);
%    h = linev([ha,]x,{ylo_pct,yhi_pct}[,linestyle],...);
%    linev('get|del|rm')
%
% - color: nan for random color | 'a' to 'z' | [r,g,b]
%
% example:
%  > linev(1:5,'r');
%  > linev(1:5,[0,1]);
%  > linev(1:2,[0,1;1,2],'lw',2);
%  > linev(1:2,{0.4,0.8});
%
% see also: lineh, lined, liner, linec, line2p, linemk
%%
if hgdel(mfilename,'line',varargin), return; end
if 1<=nargin && nargin<=2 && isequal(varargin{end},'get') % ([hf|ha,]'get')      
    h = hgfind(varargin{1:end-1},'tag',mfilename,'type','line');
    return;
end
   
[ha,x,y,args] = subfucn_parse(varargin{:});
[nx,ny] = deal(numel(x),numel(y));
xs = [x(:),x(:),nan(nx,1)].';
if ny == 2
    ys = [y(1)*ones(1,nx); y(2)*ones(1,nx); nan(1,nx)];
else
    assert(ny==2*nx,'wrong y');
    if size(y,1)==nx, ys = [y,nan(nx,1)].'; else, ys = [y;nan(1,nx)]; end
end
h = plot(xs(:),ys(:),args{:},'Parent',ha);
%%

function [ha,x,y,args] = subfucn_parse(varargin)
%% parse args
ha = [];
hasax = nargin>0 && isscalar(varargin{1}) && isaxes(varargin{1});
if hasax % linev(ha,...)
    [ha,varargin] = deal(varargin{1},varargin(2:end));
end
if isempty(ha), ha = gca; end % linev(x,...)
set(ha,'nextplot','add');

[x,y,args] = deal(varargin{1},[],varargin(2:end));
assert(isnumeric(x),'wrong input');
if ~isempty(args) && ~ischar(args{1}) % ([ha,]x,y,...)
    [y,args] = deal(args{1},args(2:end));
end
if isempty(y)
    y = ylim(ha);
elseif iscell(y) % ([ha,]x,{ylo,yhi},...)
    yl = ylim(ha);
    y = yl(1) + (yl(2)-yl(1))*[y{1}(:),y{2}(:)];
end
    
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
