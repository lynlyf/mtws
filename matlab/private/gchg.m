function h = gchg(varargin)
%% h = gchg(['parent',]'kind'[,num],'name',value,...)
% Return current hg handle of specified kind **if exists**
% 
%% input:
% parent: parent handle
% kind: '[f]ig|[a]xes|[i]mg|[s]urf|[l]ine|hg[g]roup|data[tip]|...'
% num: max number of hgobjects to return (default, 1)
%      if `num`<1, return all
% name-value pairs are passed to `findobj`
%% output: handle(s)
%
%% example:
% > gchg  % equivalent to `gcf`
% > gchg('ax',1)  % get all axes on current figure
% > gchg('line',1,'tag','taup_plot_line') % get all taup lines on gca
%
% see also: gcfa; findannobjs, allchild, ancestor, copyobj,
%           findall, findobj
%%

h = gobjects(0); % make an empty hg obj
[hp,kind,num,args] = subfcn_parse(varargin{:});

switch kind
    case {'f','fig','figure'}
        if num == 1
            h = get(groot,'CurrentFigure');
        else
            h = findobj(groot,'type','figure',args{:});
        end
    case {'a','ax','axes'}
        hf = subfcn_parfig(hp);
        if isempty(hf), return; end
        if num == 1
            h = get(hf,'CurrentAxes');
        else
            h = findobj(hf,'type','axes',args{:});
        end
    case {'g','group','hggroup'}
        hf = subfcn_parfig(hp);
        if isempty(hf), return; end
        if num == 1
            ha = gchg(hf,'ax');
            h = findall(ha,'type','hggroup');
        else
            h = findall(hf,'type','hggroup');
        end
    case {'dt','datatip'}
        hg = gchg('g',-1);
        c = arrayfun(@(a)class(a),hg,'uni',0);
        id = strcmp(c,'matlab.graphics.shape.internal.PointDataTip');
        h = hg(id);
    otherwise
        if isempty(hp), hp = gchg('ax'); end
        if isempty(hp), return; end
        kind = subfcn_type(kind);
        h = findobj(hp,'type',kind,args{:});
        if isempty(h)
            h = findobj(hp.Parent,'type',kind,args{:});
        end
end

if num<1, return; end
h = h(1:min(end,num));
%%

%% SUBFUNCTIONS
function [hp,kind,num,args] = subfcn_parse(varargin)
%% parse args
[hp,kind,num,args] = deal([],'fig',1,{});
if nargin == 0
    return;
else
    if ischar(varargin{1}) %('kind',...)
        [kind,args] = deal(varargin{1},varargin(2:end));
    elseif nargin > 1 %(hp,'kind',...)
        [hp,kind,args] = deal(varargin{1:2},varargin(3:end));
    else %(hp,[num,]'name',value,...)
        [hp,args] = deal(varargin{1},varargin(2:end));
    end
end

if mod(length(args),2) == 1 %(..,num,'name',value,...)
    [num,args] = deal(args{1},args(2:end));
    if ischar(num)
        assert(ismember(lower(num),{'a','all'}), ...
               '`num` should be "all" or a scalar integer');
        num = -1;
    else
        num = fix(num);
        assert(isnumeric(num) && isscalar(num), ...
               '`num` should be "all" or a scalar integer');
    end
end

args = hgargs(kind,args);
%%

function hf = subfcn_parfig(hp)
%% return a figure handle
if isgraphics(hp,'figure')
    hf = hp; 
else
    hf = gchg('fig');
end
%%

function kind = subfcn_type(kind)
%% return a figure handle
alias = {'line',{'l','ln'}, ...
         'scatter',{'s','sc'}, ... 
         'histogram',{'h','hist'}, ...
         'patch',{'p','area'}, ...
         'image',{'i','im','img'}, ...
         'surface',{'s','sf','surf'}, ...
         'colorbar',{'cb','cbar'}, ...
         'legend',{'lg','lgd','label'}};
kind = parse_alias(alias,kind);         
%% EOF
