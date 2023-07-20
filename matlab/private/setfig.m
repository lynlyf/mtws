function setfig(varargin)
%% set figure properties
% usage:
%   setfig; % move current figure to screen center
%   setfig(hf); % move figure to screen center
%   setfig([hf,]'color')  % set figure color
%   setfig([hf,]wh[,xy],...); % set figure size/position
%   setfig(..,'name',val,...); % support property shortcuts
%
% [w,h]/[x,y] within (0,1] -> percent of screen size
%
% see also: mkfig, mkaxes, gchg, gcfa, pagesize
%%
if nargin == 0 % setfig;
    hf = gcf;
    subfcn_2center(hf);
    figure(hf); % bring to front
    return;
end

if nargin == 1
    hh = varargin{1};
    if ischar(hh) % setfig('color') 
        set(gcf,'color',hh);
        return;
    end
    if isscalar(hh) && isgraphics(hh,'figure') % setfig(hf)
        subfcn_2center(hh);
        return;
    end    
    subfcn_pos(gcf,hh,[]); % setfig([w,h])
    return;
end

if isscalar(varargin{1}) && isgraphics(varargin{1},'figure') % setfig(hf,[wh,xy,]'prop',value,...)
    [hf,varargin] = deal(varargin{1},varargin(2:end));
    if isscalar(varargin) && (ischar(varargin{1}) || ...
            isequal(size(varargin{1}),[1,3])) % setfig(hf,'color')
        set(hf,'Color',varargin{1});
        return;
    end
else  % setfig([wh,xy,]'prop',value,...)
    hf = gcf;
end

if isnumeric(varargin{1}) % note [] is also numeric
    if length(varargin)>1 && isnumeric(varargin{2})
        subfcn_pos(hf,varargin{1},varargin{2}); % setfig([hf,]wh,xy,...)
        varargin = varargin(3:end);
    else
        subfcn_pos(hf,varargin{1},[]); % setfig([hf,]wh,'prop',value,...)
        varargin = varargin(2:end);
    end
end

if isempty(varargin), return; end
args = hgargs('fig',varargin);
set(hf,args{:});
%%

%% SUBFUNCTIONS
function subfcn_2center(hf)
%% move figure to screen center
[spos,fpos] = subfcn_screen(hf);
xy = (spos(3:4)-fpos(3:4)) / 2;
fu = get(hf,'units');
set(hf,'units','pixels','position',[xy,fpos(3:4)]);
set(hf,'units',fu);
%%

function [spos,fpos] = subfcn_screen(hf,unit,mid)
%% get [x,y,w,h] for screen and figure
if nargin<2||isempty(unit), unit = 'pixels'; end
if nargin<3, mid = 1; end % indice of monitor containing fig
fu = get(hf,'units');
set(hf,'units',unit);
fpos = get(hf,'Position'); % [x,y,w,h] of fig
set(hf,'units',fu);
su = get(groot,'units');
set(groot,'units',unit);
spos = get(groot,'MonitorPositions'); % screen size in pixels by defaults
set(groot,'units',su);
mid = min(max(1,fix(mid)),size(spos,2));
spos = spos(mid,:); % in case of multiple monitors
if ~isequal(get(hf,'menubar'),'none')
    spos(4) = spos(4)-50; % menubar occupies some pixels
end
if ~isequal(get(hf,'toolbar'),'none')
    spos(4) = spos(4)-50; % toolbar occupies some pixels
end
%%

function subfcn_pos(hf,wh,xy)
%% set figure postion
fu = get(hf,'units');
if ~isscalar(wh)
    fpos = subfcn_xywh(hf,wh,xy);    
    set(hf,'units','pixels','position',fpos,'units',fu);
    return;
end
if wh==1 % full screen
    wh = [1,1];
    if isempty(xy), xy = [2,2]; end
elseif wh==2 % full width
    wh = [1,1/2];
    if isempty(xy), xy = [0,1/3]; end
elseif wh==3 % full height
    wh = [1/3,1];
    if isempty(xy), xy = [1/3,0]; end
elseif wh<1 % part of screen
    wh = wh*[1,1];
    if isempty(xy), xy = [1/2-wh(1)/2,2/3-wh(2)/2]; end
else %
    if wh<20, error('figure size is too small'); end
    wh = wh*[1,1];
end
% set(hf,'position',subfcn_xywh(hf,wh,xy));
set(hf,'units','pixels','position',subfcn_xywh(hf,wh,xy),'units',fu);
%%

function fpos = subfcn_xywh(hf,wh,xy)
%% return new [x,y,w,h] in pixels
[spos,fpos] = subfcn_screen(hf);
if isempty(wh), wh = fpos(3:4); end % keep figure size
if wh(1)>0 && wh(1)<=1 % percent to pixels
    wh(1) = round(wh(1).*spos(3));
elseif wh(1)<50 % cm to pixels; 1 inch=2.54 cm=96 pixels, 1 cm = 38 px.
    wh(1) = round(wh(1).*37.8);
end
if wh(2)>0 && wh(2)<=1 % percent to pixels
    wh(2) = round(wh(2).*spos(4));
elseif wh(2)<50 % cm to pixels; A4=21cm x 29.7cm
    wh(2) = round(wh(2).*37.8);
end 
if isempty(xy), xy = fpos(1:2); end % keep figure pos
if xy(1)>0 && xy(1)<1, xy(1) = xy(1).*spos(3); end % percent to pixels
if xy(2)>0 && xy(2)<1, xy(2) = xy(2).*spos(4); end % percent to pixels
xy = [max(2,xy(1)), max(50,xy(2))]; % left-bottom corner in screen
if xy(1)+wh(1)>spos(3) % too wide
    xy(1) = 2; % move to left
    if xy(1)+wh(1)>spos(3), wh(1) = spos(3)-xy(1); end % still too wide
end
if xy(2)+wh(2)>spos(4) % too tall
    xy(2) = 50; % move to bottom
    if xy(2)+wh(2)>spos(4), wh(2) = spos(4)-xy(2); end % still too tall
end
fpos = [xy(1),xy(2),wh(1),wh(2)];
%% EOF
