function [hcb,hax] = plot_cbar(cmap,varargin)
%% [hcb,hax] = plot_cbar(cmap[,k],'name',value,...)
% plot a standalone colorbar
%
% input:
%   cmap: colormap of size [m,3] or [n,m,3]
%   k: number of colors to display (default,64)
%   name-value args for axes except:
%     'f|hf|hfig|fig': figure handle
%     'a|ax|axes|parent': axes handle
%     't|txt|title|label': label str
%     'p|pos|position': [w,h] | [x,y,w,h]
%     'o|ori|orient': 'h|v' orientation
%     'c|col|color': color of axis and label
%     'x|xd|xdata': x data
%     'y|yd|ydata': y data
% output: handles of colorbar image and axes
% see also: cmdisp
% examples:
%   > hcb = plot_cbar('jet',32)
%   > hcb = plot_cbar(cmstore(64,'haxby'))
%%
if nargin == 0
    subfcn_demo;
    return;
end

[cmap,x,y,hax,orient,label,color,args] = subfcn_parse(cmap,varargin{:});
hcb = image(x,y,cmap,'parent',hax);    
axis(hax,'xy','tight');
if isempty(orient)
    if size(cmap,1)==1 % horizontal cbar
        subfcn_label(hax,label,'x');
    elseif size(cmap,2)==1 % vertical cbar
        subfcn_label(hax,label,'y');
    else % 2d colormap
        subfcn_label(hax,label,'xy');
    end
elseif orient == 'h'
    subfcn_label(hax,label,'x');
else
    subfcn_label(hax,label,'y');
end 
set(hax,args{:});
if ~isempty(color)
    set(get(hax,'xaxis'),'color',color);
    set(get(hax,'yaxis'),'color',color);
end
%% 

%% SUBFUNCTIONS
function [cmap,x,y,hax,orient,label,color,args] = subfcn_parse(cmap,varargin)
%% parse args
if ischar(cmap), cmap = eval(cmap); end
if mod(length(varargin),2) == 1
    cmap = cmresample(cmap,fix(varargin{1}));
    varargin = varargin(2:end);
end
% axes handle and args
[hf,hax,pos,orient,label] = deal([]);
color = [1,1,1]*0.3;
flag = true(size(varargin));
for ii = 1 : 2 : length(varargin)
    val = varargin{ii+1};
    switch lower(varargin{ii})
        case {'f','hf','hfig','fig','figure'}
            hf = val;
            flag(ii:ii+1) = false;
        case {'a','ax','axes','parent'}
            hax = val;
            flag(ii:ii+1) = false;
            assert(isscalar(hax)&&isaxes(hax),'invalid axes handle');
        case {'p','pos','position'} % [w,h] | [x,y,w,h] of axes
            pos = val;
            if length(pos)==2, pos = cat(2,[0,0],pos); end
            flag(ii:ii+1) = false;
            assert(isnumeric(pos)&&length(pos)==4,'wrong position');
        case {'o','ori','orient','orientation'} % orientation
            orient = lower(val);
            flag(ii:ii+1) = false;
            assert(ismember(orient,{'h','v'}),'orient = ''h|v''');
        case {'t','txt','label','title'}
            label = val;
            flag(ii:ii+1) = false;
        case {'x','xd','xdata'}
            x = val;
            flag(ii:ii+1) = false;
        case {'y','yd','ydata'}
            y = val;
            flag(ii:ii+1) = false;
        case {'c','col','color'}
            if isscalar(val) && isnumeric(val)
                color = val * [1,1,1]; 
            else
                color = val; 
            end
            flag(ii:ii+1) = false;
    end
end
args = hgargs('axes',varargin(flag));
if isempty(hax) % new axes on figure
    if isempty(hf), hf = gcf; end
    hax = axes('parent',hf,'units','pixel','box','on','nextplot','add');
end
if ~isempty(pos), set(hax,'position',pos); end
argdef = {'layer','top','xdir','normal','ydir','normal','yaxislocation','right'};
args = [argdef, args];
% colormap to image of size [n,m,3]
n = cmndims(cmap);
assert(n>0,'invalid colormap');
if n==1, cmap = reshape(cmap,[],1,3); end
x = 1 : size(cmap,2);
y = 1 : size(cmap,1);
if isequal(orient,'h') && size(cmap,2) == 1 % vertical to horizontal
    cmap = reshape(cmap,1,[],3);
elseif isequal(orient,'v') && size(cmap,2) == 1 % horizontal to vertical 
    cmap = reshape(cmap,[],1,3);
end 
%%

function subfcn_label(hax,label,dim)
%% axis label
if iscellstr(label)
    xlabel(hax,label{1});
    ylabel(hax,label{2});
    return;
end
if dim == 'x'
    set(hax,'ytick',[]);
    xlabel(hax,label);
elseif dim == 'y'
    set(hax,'xtick',[]);
    ylabel(hax,label);
end
%%

function subfcn_demo
%% Builtin demo
verb(1,'> run builtin demo of ',mfilename);
cm = cmstore(64,'haxby');
hf = mkfig;
plot_cbar(cm,12,'pos',[50,50,10,300],'txt','vertical colorbar','hf',hf,'yd',[0,1],'col','r');
plot_cbar(reshape(cm,1,[],3),'pos',[100,80,400,15],'txt','horizontal colorbar','hf',hf);
%% EOF