function setprop(handles,varargin)
%% setprop(handles,prop,val,...)
% set obj properties
% 
% * as for x,y,w,h and scale, nan/0 means keeping old value/aspect ratio.
%
% inputs:
%   handles: (cell) array of handles
%   prop-value pairs: set obj property (if exists) to value
%   some customed pairs:
%   == position [x,y,w,h] related == 
% %   **NaN to retain old value; zero to retain w/h ratio**
%     'mv|move': [dx[,dy,w,h]]   
%     'xy': [x[,y]]; pass NaN to retain old value
%     'sz|wh': [w[,h]]
%     '[p]os': set [x[,y,w,h] or copy pos of another object
%     '[sc]ale|[zo]om': change [w,h], scale | [wscale[,hscale]]
%     'rot+|-': angle in deg
%   == x|y|zdata related ==
%     '(x|y|z)dmv|mv(x|y|z)d': chang x|y|zdata of gobject
%     'xymv|mvxy': chang xdata and ydata of gobject
%     '(x|y|z)proj|proj(x|y|z)': project x|y|zdata to given range
%     '(x|y|z)zoom|zoom(x|y|z)': scale x|y|zdata
%   == parent axes related ==
%     '(x|y|z)lsc|sc(x|y|z)l': change x|y|zlim by a factor
%     '(x|y|z)(lb|label)': x|y|zlabel of parent axes
%     'ttl|txt|title': title of parent axes
%     'a[x]t[k]m': make tick and ticklabel mode automatic; 'x|y|xy'
%     'inc': include mode
% 
% examples:
%   > setprop(hs,'col','r','lw',3); % set color to red and linewidth to 3
%   > setprop(hs,'mv',[0.1,0.1]); % move subplots by [0.1,0.1]
%   > setprop(hs,'pos',[0.1,nan,0.4,0.4]); % set x to 0.1 and w&h to 0.4
%   > setprop(hs,'sz',[0,0.4]); % set height=0.4 and scale width to keep w/h ratio
%   > setprop(hs,'zoom',[1.5,0.5]); % scale width by 1.5 and height by 0.5
%
% see also: getprop, axvis, gswitch, setfig, hgargs, hgpropalias
%%
if isempty(varargin)
    fprintf('$ no properties provided\n');
    return;
end
if iscell(handles)
    batchfun(@setprop,handles,varargin{:});
    return;
end

hid = arrayfun(@(h)ishghandle(h)&~isa(h,'matlab.graphics.GraphicsPlaceholder'),handles);
handles = handles(hid);
if isempty(handles)
    verb(1,'no valid hghandle');
    return;
end

if isscalar(varargin)&&iscell(varargin{1}), varargin = varargin{1}; end
if isempty(varargin)
    verb(1,'nothing to set');
    return;
end

alias = hgpropalias(handles(1));
narg = length(varargin);
assert(narg>0&&mod(narg,2)==0&&iscellstr(varargin(1:2:end)), 'wrong prop-val pairs');
for ii = 1 : 2 : narg
    [prop,val] = deal(lower(varargin{ii}),varargin{ii+1});
    switch lower(prop)
        %% position [x,y,w,h]
        case {'mv','move'} %  [dx[,dy,w,h]]
            subfcn_move(handles,val); 
        case {'xy'} % set [x,y]
            subfcn_xy(handles,val); 
        case {'sz','wh'} % set [w,h]
            subfcn_size(handles,val); 
        case {'sc','scale','zo','zoom'} % change [w,h] to scale.*[w,h]
            subfcn_zoom(handles,val);
        case {'r+','rot+','racw'} % rotate anti-clockwise
            subfcn_rot(handles,val);
        case {'r-','rot-','rcw'} % rotate clockwise
            subfcn_rot(handles,-val);
        case {'p','pos','position'} % set [x[,y,w,h]] or copy position of an object
            subfcn_pos(handles,val); 
        %% x|y|zdata
        case {'xdmv','mvxd'} % add xdata by given value
            subfcn_xmove(handles,val); 
        case {'ydmv','mvyd'} % add ydata by given value
            subfcn_ymove(handles,val); 
        case {'zdmv','mvzd'} % add zdata by given value
            subfcn_zmove(handles,val); 
        case {'xymv','mvxy'} % add xdata, ydata by given values
            subfcn_xymove(handles,val); 
        case {'xproj','projx'} % project xdata to given range
            subfcn_xproj(handles,val); 
        case {'yproj','projy'} % project ydata to given range
            subfcn_yproj(handles,val); 
        case {'zproj','projz'} % project zdata to given range
            subfcn_zproj(handles,val); 
        case {'xdsc','scxd','xzoom','zoomx'} % scale xdata by a factor
            subfcn_xdata_scale(handles,val); 
        case {'ydsc','scyd','yzoom','zoomy'} % scale ydata by a factor
            subfcn_ydata_scale(handles,val); 
        case {'zdsc','sczd','zzoom','zoomz'} % scale zdata by a factor
            subfcn_zdata_scale(handles,val); 
        %% axis limits, labels, ticklabels, title
        case {'xlsc','scxl'} % scale xlim w.r.t. the center by a factor
            subfcn_axlim_scale(handles,val,nan,nan); 
        case {'ylsc','scyl'} % scale ylim w.r.t. the center by a factor
            subfcn_axlim_scale(handles,nan,val,nan); 
        case {'zlsc','sczl'} % scale zlim w.r.t. the center by a factor
            subfcn_axlim_scale(handles,nan,nan,val); 
        case {'xlb','xlabel'} % axes xlabel
            subfcn_axlabel(handles,val,nan);
        case {'ylb','ylabel'} % axes ylabel
            subfcn_axlabel(handles,nan,val);
        case {'zlb','zlabel'} % axes ylabel
            zlabel(handles,val);
        case {'ttl','txt','title'} % axes title
            subfcn_title(handles,val); 
        case {'atm','axtm','atkm','axtkm'} % axes tick mode
            subfcn_axtkmode(handles,val);
            
        case {'inc'}
            subfcn_axinc(handles,val);
        otherwise
            prop = parse_alias(alias,prop);
            flag = isprop(handles,prop);
            hn = handles(~flag);
            if ~isempty(hn)
                if isscalar(hn)
                    hgnms = get(hn,'type'); 
                else
                    hgnms = strjoin(unique(get(hn,'type')),', '); 
                end
                verb(1,prop,' is not property of ',hgnms);
            end
            hs = handles(flag);
            if isempty(hs), continue; end
            set(hs,prop,val);
    end
end
%%

%% SUBFUNCTIONS
function subfcn_move(hs,v)
%% change [x[,y,w,h]]
% v = [dx[,dy,w,h]]; NaN retains old value; zero retains w/h ratio
%%
hs = hs(isprop(hs,'position'));
if isempty(hs) || isempty(v)
    verb(1,'nothing to do');
    return; 
end
v = reshape(v,1,[]);
n = length(v);
if n==1, v = [v,0]; end
for ii = 1 : length(hs)
    p = get(hs(ii),'position');
    ps = [p(1:2)+v(1:2), v(3:n), p((n+1):end)];
    ps(isnan(ps)) = p(isnan(ps));
    if ps(3)==0, ps(3) = p(3)/p(4)*ps(4); end
    if ps(4)==0, ps(4) = p(4)/p(3)*ps(3); end
    assert(ps(3)>0&&ps(4)>0,'wrong size');
    set(hs(ii),'position',ps);
end
%%

function subfcn_xy(hs,xy)
%% change x and y pos
% xy=[x[,y]] changes x and y position;
% xy=x changes x only;
% xy=[nan,y] changes y only
% if xy is a hgobj, change xy of hs to xy of given hgobj
%%
hs = hs(isprop(hs,'position'));
if isempty(hs) || isempty(xy)
    verb(1,'nothing to do');
    return; 
end
xy = reshape(xy,1,[]);
if isscalar(xy) && ishandle(xy) % copy xy position
    xy = bysub(get(xy,'position'),1:2);
end
n = length(xy);
for ii = 1 : length(hs)
    p = get(hs(ii),'position');
    ps = [xy,p((n+1):end)];
    ps(isnan(ps)) = p(isnan(ps));
    set(hs(ii),'position',ps);
end
%%

function subfcn_pos(hs,pos)
%% change [x,y,w,h]
% pos=[x[,y,w,h]] changes x[,y,w,h];
% NaN retains old value;
% zero retains w/h ratio
% if pos is a hgobj, change position of hs to position of given hgobj
%%
hs = hs(isprop(hs,'position'));
if isempty(hs) || isempty(pos)
    verb(1,'nothing to do');
    return; 
end
pos = reshape(pos,1,[]);
n = numel(pos);
if n==1 && ishandle(pos) % copy position
    set(hs,'position',get(pos,'position'));
    return;
end
for ii = 1 : length(hs)
    p = get(hs(ii),'position');
    ps = [pos,p((n+1):end)];
    ps(isnan(ps)) = p(isnan(ps));
    if length(p)>3&&ps(3)==0, ps(3) = p(3)/p(4)*ps(4); end
    if length(p)>3&&ps(4)==0, ps(4) = p(4)/p(3)*ps(3); end
    %assert(ps(3)>0&&ps(4)>0,'wrong size');
    set(hs(ii),'position',ps);
end
%%

function subfcn_size(hs,sz)
%% sz = [width[,height]]; 
% NaN means keeping old value; zero means keep w/h ratio
%%
hs = hs(isprop(hs,'position'));
if isempty(hs) || isempty(sz)
    verb(1,'nothing to do');
    return; 
end
if isscalar(sz)
    if isnumeric(sz)
        sz = [sz,nan];
    else % copy size
        p = get(sz,'position');
        for ii = 1 : length(hs)
            ps = get(hs(ii),'position');
            set(hs(ii),'position',[ps(1:2),p(3:4)]);
        end
        return;
    end
end
for ii = 1 : length(hs)
    p = get(hs(ii),'position');
    ps = [p(1:2),sz(1),sz(2)]; 
    if isnan(sz(1))
        ps(3) = p(3);
    elseif sz(1)==0
        ps(3) = p(3)/p(4)*ps(4);
    end
    if isnan(sz(2))
        ps(4) = p(4);
    elseif sz(2)==0
        ps(4) = p(4)/p(3)*ps(3);
    end
    assert(ps(3)>0&&ps(4)>0,'wrong size');
    set(hs(ii),'position',ps);
end
%%

function subfcn_zoom(hs,scal)
%% scal = [w_scal[,h_scal]]
hs = hs(isprop(hs,'position'));
if isempty(hs) || isempty(scal)
    verb(1,'nothing to do');
    return; 
end
if isscalar(scal), scal = scal*[1,1]; end % keep w/h ratio
for ii = 1 : length(hs)
    p = get(hs(ii),'position');    
    subfcn_pos(hs(ii),[p(1:2),p(3:4).*scal]);
end
%%

function subfcn_rot(hs,a)
%% rotate by given angle 
%%
hs = hs(isprop(hs,'rotation'));
if isempty(hs) || isempty(a), return; end
batchfun(@(h)set(h,'rotation',get(h,'rotation')+a),hs);
%%

function subfcn_axlabel(hs,xlb,ylb)
%% change axis label of (parent) axes
if ~iscell(xlb)
    xlb = {xlb};
end
if isscalar(xlb)
    xlb = repmat(xlb,size(hs));
end
if ~iscell(ylb)
    ylb = {ylb};
end
if isscalar(ylb)
    ylb = repmat(ylb,size(hs));
end
for ii = 1 : numel(hs)
    ax = ancestor(hs(ii),'axes');   
    if isempty(ax)
        continue;
    end
    if isempty(xlb{ii})
        delete(ax.XLabel);
    elseif ~isnan(xlb{ii})
        xlabel(ax,xlb{ii});
    end
    if isempty(ylb{ii})
        delete(ax.YLabel);
    elseif ~isnan(ylb{ii})
        ylabel(ax,ylb{ii});
    end
end
%%

function subfcn_title(hs,txt)
%% change title of (parent) axes
if ischar(txt), txt = {txt}; end
if isscalar(txt), txt = repmat(txt,size(hs)); end
for ii = 1 : numel(hs)
    ax = ancestor(hs(ii),'axes');   
    if isempty(ax), continue; end
    title(ax,txt{ii});
end
%%

function subfcn_xmove(hs,v)
%% set xdata to xdata+v
hs = hs(isprop(hs,'xdata'));
if isempty(hs) || isempty(v)
    verb(1,'nothing to do');
    return; 
end
batchfun(@(h)set(h,'xdata',get(h,'xdata')+v),hs);
%%

function subfcn_ymove(hs,v)
%% set ydata to ydata+v
hs = hs(isprop(hs,'ydata'));
if isempty(hs) || isempty(v)
    verb(1,'nothing to do');
    return; 
end
batchfun(@(h)set(h,'ydata',get(h,'ydata')+v),hs);
%%

function subfcn_zmove(hs,v)
%% set zdata to zdata+v
hs = hs(isprop(hs,'ydata'));
if isempty(hs) || isempty(v)
    verb(1,'nothing to do');
    return; 
end
batchfun(@(h)set(h,'zdata',get(h,'zdata')+v),hs);
%%

function subfcn_xymove(hs,v)
%% set xdata to xdata+v
hs = hs(isprop(hs,'xdata'));
if isempty(hs) || isempty(v)
    verb(1,'nothing to do');
    return; 
end
batchfun(@(h)set(h,'xdata',get(h,'xdata')+v(1), ...
                   'ydata',get(h,'ydata')+v(2)),hs);
%%

function subfcn_xproj(hs,v)
%% project xdata to given range
hs = hs(isprop(hs,'xdata'));
if isempty(hs) || isempty(v)
    verb(1,'nothing to do');
    return; 
end
batchfun(@(h)set(h,'xdata',proj2rng(get(h,'xdata'),v)),hs);
%%

function subfcn_yproj(hs,v)
%% project ydata to given range
hs = hs(isprop(hs,'ydata'));
if isempty(hs) || isempty(v)
    verb(1,'nothing to do');
    return; 
end
batchfun(@(h)set(h,'ydata',proj2rng(get(h,'ydata'),v)),hs);
%%

function subfcn_zproj(hs,v)
%% project zdata to given range
hs = hs(isprop(hs,'zdata'));
if isempty(hs) || isempty(v)
    verb(1,'nothing to do');
    return; 
end
batchfun(@(h)set(h,'zdata',proj2rng(get(h,'zdata'),v)),hs);
%%

function subfcn_xdata_scale(hs,v)
%% scale xdata to given range
hs = hs(isprop(hs,'xdata'));
if isempty(hs) || isempty(v)
    verb(1,'nothing to do');
    return; 
end
if isscalar(v)
    if iscell(v), v = {'min',v{1}}; else; v = {'min',v}; end
elseif ~iscell(v)
    v = {v(1),v(2)};
end
batchfun(@(h)set(h,'xdata',subfcn_scaledata(get(h,'xdata'),v{:})),hs);
%%

function subfcn_ydata_scale(hs,v)
%% scale ydata to given range
hs = hs(isprop(hs,'ydata'));
if isempty(hs) || isempty(v)
    verb(1,'nothing to do');
    return; 
end
if isscalar(v)
    if iscell(v), v = {'min',v{1}}; else; v = {'min',v}; end
elseif ~iscell(v)
    v = {v(1),v(2)};
end
batchfun(@(h)set(h,'ydata',subfcn_scaledata(get(h,'ydata'),v{:})),hs);
%%

function subfcn_zdata_scale(hs,v)
%% scale zdata to given range
hs = hs(isprop(hs,'zdata'));
if isempty(hs) || isempty(v)
    verb(1,'nothing to do');
    return; 
end
if isscalar(v)
    if iscell(v), v = {'min',v{1}}; else; v = {'min',v}; end
elseif ~iscell(v)
    v = {v(1),v(2)};
end
batchfun(@(h)set(h,'zdata',subfcn_scaledata(get(h,'zdata'),v{:})),hs);
%%

function y = subfcn_scaledata(x,ref,k)
%% scale x to ref+k*(x-ref)
assert(isvector(x),'only vector is supported');
if ischar(ref)
    switch(lower(ref))
        case {'min','bottom'}
            x0 = nanmin(x);
        case {'mean','middle','center'}
            x0 = nanmean(x);
        case {'med','median'}
            x0 = nanmedian(x);
        case {'max','top'}
            x0 = nanmax(x);
        otherwise
            error('unknown reference value option');
    end
elseif isa(ref,'function_handle')
    x0 = ref(x);
else
    x0 = ref;
end
assert(isscalar(x0)&&isnumeric(x0),'wrong reference value');
y = x0 + k*(x-x0);
verb(1,sprintf('scale from range [%g,%g] to [%g,%g]', ...
          getbound(x),getbound(y)));
%%

function subfcn_axinc(hs,v)
%% set X|Y|Z|A|CLimInclude
if ~ischar(v), v = bycond(v,'on','off'); end
setprop(hs,'XLimInclude',v,'YLimInclude',v,'ZLimInclude',v, ...
           'ALimInclude',v,'CLimInclude',v);
%%

function subfcn_axtkmode(hs,v)
%% set axes tick mode to auto
hs = hs(isaxes(hs));
if isempty(hs)
    verb(1,'no valid axes handles provided');
    return; 
end
v = bycond([strcmpi(v,'x'),strcmpi(v,'y')],'x','y','xy');
verb(1,'set ',v,' tick mode to auto');
if v(1)=='x'
    setprop(hs,'xtm','auto','xtlm','auto');
end
if v(end)=='y'
    setprop(hs,'ytm','auto','ytlm','auto');
end
%% EOF
