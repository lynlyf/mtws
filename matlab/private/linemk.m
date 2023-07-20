function h = linemk(varargin)
%% an wrapper of `plot`
% usage: h = ...
%    linemk([ha,]x,y[,z],...);
%    linemk([ha,]y,...);
%    linemk([ha,][xlo,xhi],y,...);
%    linemk([ha,]x,[ylo,yhi],...);
%    linemk([ha,][x,y[,z]],['mkstyle',]'name',value,...);
%    linemk([ha,]{xv1,xv2,...},{yv1,yv2,...}[,{zv1,zv2,...}],...); % multiple lines
%
% notes:
%  * for single point data, force to display as a red dot
%  * `linemk([],[])` returns a line with nan x|ydata; `plot([],[])` returns an empty line handle
%  * `linemk([x1,x2[,x3]])` plot data as one line; `plot([x1,x2,x3])` plots three lines
%
% input:
%   ha: axes handle
%   x,y,z: x, y, z vectors; feasible to input [lo,hi] of x|y|z
%   mkstyle: `plot`-supported linestyle str | 'f[e]<color><marker>'
%       'f' means filling makers, 'e' means ploting edges
%   name-value pairs for `plot` and `axes` are supported, with customed ones:
%     inc: if included in X|Y|Z|A|CAxisLim (default, true)
%     xlb,ylb,ttl: xlable, ylabel, title of axes
%     asone: join mutiple lines into one (default, false)
% output: handle
%
% see also: lineh, linev, lined, liner, linec
%%
if nargin == 0
    subfcn_demo;
    return;
end

if hgdel(mfilename,'line',varargin), return; end
if 1<=nargin && nargin<=2 && isequal(varargin{end},'get') % ([hf|ha,]'get')      
    h = hgfind(varargin{1:end-1},'tag',mfilename,'type','line');
    return;
end

[ha,x,y,z,args] = subfcn_parse(varargin{:});
if iscell(x)
    h = gobjects(size(x));
    for ii = 1 : length(x)
        if isempty(z)
            h(ii) = linemk(ha,x{ii},y{ii},args{:});
        else
            h(ii) = linemk(ha,x{ii},y{ii},z{ii},args{:});
        end
    end
    return;
end

if isempty(x)||isempty(y),[x,y] = deal(nan); end    
if isempty(z)
    if mod(length(args),2) == 0
        h = plot(x,y,'parent',ha); 
    else  % {linestyle,'name',value,...}
        h = plot(x,y,args{1},'parent',ha);
        args = args(2:end);
    end
else
    if mod(length(args),2) == 0
        h = plot3(x,y,z,'parent',ha); 
    else  % {linestyle,'name',value,...}
        h = plot3(x,y,z,args{1},'parent',ha);
        args = args(2:end);
    end
end
% set props of lines and axes
idlp = find(~cellfun(@(p)isprop(h(1),p),args(1:2:end)));
aargs = hgargs('ax',args([2*idlp-1;2*idlp])); 
idbad = find(~cellfun(@(p)isprop(ha,p),aargs(1:2:end)));
if ~isempty(idbad)
    verb(1,'unknown props: ',strjoin(aargs(2*idbad-1),', ')); 
    aargs([2*idbad-1,2*idbad]) = [];
end
if ~isempty(aargs), set(ha,aargs{:}); end
args([2*idlp-1,2*idlp]) = [];
if ~isempty(args), set(h,args{:}); end
% force to display single dot
for ii = 1 : length(h)
    if sum(isfinite(get(h(ii),'xdata')))==1 && isequal(get(h(ii),'marker'),'none')
        verb(1,'force to show single point as a dot');
        setprop(h(ii),'mk','o','msz',9);
        if isequal(getprop(h(ii),'mfc','mec'),{'none','none'})
            setprop(h(ii),'mfc','r','mec','k');
        end
    end
end
%%

%% SUBFUNCTIONS
function [ha,x,y,z,args] = subfcn_parse(varargin)
%% parse args
ha = [];
if isaxes(varargin{1},1) % (ha,...)
    [ha,varargin] = deal(varargin{1},varargin(2:end)); 
end
% x, y[, z]
[x,z,varargin] = deal(varargin{1},[],varargin(2:end));
if iscell(x) % ([ha,]{x1,x2,...},{y1,y2,...},...)
    [y,args] = deal(varargin{1},varargin(2:end));
    if ~isempty(args)&&~ischar(args{1})
        [z,args] = deal(varargin{1},varargin(2:end));
    end
    if isempty(ha), ha = gca; end
    return;
elseif isempty(varargin) || ischar(varargin{1})
    if isvector(x)% ([ha,]y,...)
        [x,y] = deal(1:length(x),x);
    elseif size(x,1)==2 && size(x,2)>2 % ([ha,][x;y],...)
        [x,y] = deal(x(1,:),x(2,:));
    elseif size(x,1)==3 && size(x,2)>3 % ([ha,][x;y;z],...)
        [x,y,z] = deal(x(1,:),x(2,:),x(3,:));
    elseif size(x,2) == 2 % ([ha,][x,y],...)
        [x,y] = deal(x(:,1),x(:,2));
    elseif size(x,2) == 3 % ([ha,][x,y,z],...)
        [x,y,z] = deal(x(:,1),x(:,2),x(:,3));
    else % ([ha,]y,...), column-wise y data
        [x,y] = deal((1:size(x,1)),x);
    end
else % ([ha,]x,y,...)
    [y,varargin] = deal(varargin{1},varargin(2:end));
    [x,y] = subfcn_expand(x,y);
    if ~isempty(varargin) && isnumeric(varargin{1}) % ([ha,]x,y,z,...)
        [z,varargin] = deal(varargin{1},varargin(2:end));
        [x,z] = subfcn_expand(x,z);        
        [y,z] = subfcn_expand(y,z);        
    end
end
% name-value pairs
arginc = {'XLimInclude','off','YLimInclude','off','ZLimInclude','off',...
          'ALimInclude','off','CLimInclude','off'};
argdef = {'tag',mfilename};
m = mod(length(varargin),2);
iin = find(strcmpi(varargin(1+m:2:end),'inc'));
if ~isempty(iin)
    inc = varargin{2*iin(end)+m};
    if ischar(inc), inc = strcmpi(inc,'on'); else, inc = logical(inc); end
    varargin([2*iin+m-1,2*iin+m]) = [];
    if ~inc, argdef = [arginc,argdef]; end
end

if mod(length(varargin),2) == 0 % (...,'name',value,...)
    varargin = [argdef,varargin];
else % (...,'line|mkstyle','name',value,...)
    if varargin{1}(1) ~= 'f' % (...,'linestyle',...)
        varargin = [varargin(1),argdef,varargin(2:end)]; 
    else
        mkarg = {'ls','none','mk','o','mfc','k'};
        if length(varargin{1}) > 1 % (...,'f???',...)
            if varargin{1}(2) == 'e' % (...,'fe??',...), filled markers with edges
                varargin{1} = varargin{1}([1,3:end]);
            else
                mkarg = [mkarg,{'mec','none'}];
            end
            if length(varargin{1})>=2, mkarg = [mkarg,{'mfc',varargin{1}(2)}]; end
            if length(varargin{1})>=3, mkarg = [mkarg,{'mk',varargin{1}(3)}]; end
        end
        varargin = [argdef,varargin(2:end),mkarg];
    end
end
% axes handle and properties
alias = [hgpropalias('line'),{'xlb',{'xlabel'},'ylb',{'ylabel'},'ttl', ...
           {'title','txt'},'asone',{'one','as1'}}];
args = hgargs(alias,varargin);
m = mod(length(args),2);
iax = find(strcmpi(args(1+m:2:end),'parent'),1,'last');
if ~isempty(iax)
    ha = args{2*iax+m};
    args = args([1:2*iax+m-2,2*iax+m+1:end]);
end
if isempty(ha), ha = gca; end
assert(isaxes(ha),'invalid axes handle');
set(ha,'nextplot','add');
ixl = find(strcmpi(args(1+m:2:end),'xlb')); % xlabel of axes
if ~isempty(ixl)
    xlabel(ha,args{2*ixl(end)+m});
    args(2*ixl+m+[-1,0]) = [];
end
iyl = find(strcmpi(args(1+m:2:end),'ylb')); % ylabel of axes
if ~isempty(iyl)
    ylabel(ha,args{2*iyl(end)+m});
    args(2*iyl+m+[-1,0]) = [];
end
itl = find(strcmpi(args(1+m:2:end),'ttl')); % title of axes
if ~isempty(itl)
    title(ha,args{2*itl(end)+m});
    args(2*itl+m+[-1,0]) = [];
end
ione = find(strcmpi(args(1+m:2:end),'asone'));
asone = ~isempty(ione) && args{2*ione(end)+m};
if asone % join data and return a unique handle
    args(2*ione+m+[-1,0]) = [];
    if isvector(x) && ~isvector(y)
        sz = size(y);
        if length(x) == sz(1)
            x = repmat([x(:); nan],sz(2),1);
            y = reshape([y;nan(1,sz(2))],[],1);
        else
            x = repmat([x(:); nan],sz(1),1);
            y = reshape([y,nan(sz(1),1)],[],1);
        end
    end
    if ~isvector(x) && isvector(y)
        sz = size(x);
        if length(y) == sz(1)
            x = reshape([x;nan(1,sz(2))],[],1);
            y = repmat([y(:); nan],sz(2),1);
        else
            x = reshape([x,nan(sz(1),1)],[],1);
            y = repmat([y(:); nan],sz(1),1);
        end
    end
end
%%

function [a,b] = subfcn_expand(a,b)
%% expand a/b to the same size as b/a
% a0, b -> dot or vertical line
% a, b0 -> dot or horizontal line
% [a_lo,a_hi], b -> linspace(a_lo,a_hi,length(b)), b
% a, [b_lo,b_hi] -> a, linspace(b_lo,b_hi,length(a))
%%
if isscalar(a)
    a = a * ones(size(b));
elseif isscalar(b)
    b = b * ones(size(a));
elseif numel(a) == 2 % ([a_lo,a_hi],b)
    if isvector(b), n = length(b); else; n = size(b,1); end
    if n>2, a = linspace(a(1),a(2),n).'; end
elseif numel(b) == 2 % (a,[b_lo,b_hi])
    if isvector(a), n = length(a); else; n = size(a,1); end
    if n>2, b = linspace(b(1),b(2),n).'; end
end
%%

function subfcn_demo
%% builtin demo
verb(1,'run builtin demo of ',mfilename);
hf = mkfig('name',['demo of ',mfilename]);
ha = mkaxes(1,1,hf,'dar',[1,1,1]);
[x,y] = meshgrid(-10:5:10,0:5:20);
linemk(ha,[x(:),y(:)],'fk^','xl',[-12,12],'yl',[-2,22],'dnm','marker');
[x,y] = deal([8,-8],2);
linemk(x,y,'ax',ha,'lw',2,'mk','p','msz',20,'mfc','r','dnm','line+marker');
linemk([-10,10],10,'lw',10,'c',[0,1,0,.5],'mk','o','dnm','transparent line');
hl = linemk(-8:4:8,15,'mk','o','lw',10,'dnm','colored line','xlb','x','ylb','y');
legend(ha);
drawnow; % necessary to make ColorData effective
cd = uint8([255*rand(3,5);linspace(255,0,5)]);
% cd = uint8([255 0; 0 0; 0 255; 255 50]);
set(hl.Edge,'ColorBinding','interpolated','ColorData',cd); drawnow;
set(hl.MarkerHandle,'FaceColorBinding','interpolated','FaceColorData',cd);
%% EOF
