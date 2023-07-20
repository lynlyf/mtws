function hcb = addcb(varargin)
%% A wrapper of `colorbar` to current axes, keeping axes position
% usages:
%    hcb = addcb([ha,]['location',]'name',value,...)
%    hcb = addcb([ha,][rw,rh],'name',value,...)
%    hcb = addcb([ha,][rx,ry,rw,rh],'name',value,...)
%
% customed args:
%   'p|pos': [x,y,w,h]
%   'rp|relpos': [rx,ry,rw,rh] relative to axes
%   'rxy|relxy': [rx,ry] relative to axes
%       rx=0|1, cbar left at axes left|right
%       ry=0|1, cbar bottom at axes bottom|top
%   'rsz|relsz|relsize': [rw,rh] relative to axes
%   '[xy]lb': label str
%   'txt|ttl|title': title str
%%
if nargin==0 || ischar(varargin{1}) || isnumeric(varargin{1})
    ax = gchg('ax');
else % (ax,...)
    [ax,varargin] = deal(varargin{1},varargin(2:end));
    ax = ax(isaxes(ax));
end
if isempty(ax)
    hcb = [];
    verb(1,'no available axes');
    return;
end

if iscell(ax), ax = [ax{:}]; end
if length(ax) > 1 % multiple axes
    hcb = gobjects(size(ax));
    for ii = 1 : numel(ax)
        hcb(ii) = addcb(ax(ii),varargin{:});
    end
    return;
end

pos = [];
if ~isempty(varargin) && isnumeric(varargin{1})   
    if length(varargin{1})==2 % (..,[rw,rh],...)
        varargin = [{'rsz'},varargin];
    elseif length(varargin{1})==4 % (..,[rx,ry,rw,rh],...)
        varargin = [{'rpos'},varargin];
    else
    	error('usage: addcb([ha,][rw,rh]|rx,ry,rw,rh],...)');
    end
end

axunit = get(ax,'units');
set(ax,'units','normalized');

[clim,xlb,ylb,lbl,txt] = deal([]);
axpos = get(ax,'position'); % backup axes position
bnd = @(x,xl) min(xl(2),max(xl(1),x));
n = length(varargin);
flag = false(1,n);
if mod(n,2), flag(1) = true; end
for ii = 1+mod(n,2) : 2 : n
    switch lower(varargin{ii})
        case {'p','pos','position'} % [x,y,w,h]
            pos = varargin{ii+1};
        case {'rp','rpos','relpos'} % [rx,ry,rw,rh]
            rpos = varargin{ii+1};
            pos = [axpos(1:2)+axpos(3:4).*rpos(1:2), axpos(3:4).*rpos(3:4)];
        case {'rxy','relxy'} % [rx,ry]
            rxy = varargin{ii+1};            
            if ~isempty(pos)
                pos(1:2) = rxy(1:2) + axpos(1:2);
            else
                if rxy(1)<0 || rxy(1)>=axpos(3) % WO|EO
                    pos = [rxy(1:2)+axpos(1:2),bnd(0.03*axpos(3),[0.005,0.15]),axpos(4)];
                elseif rxy(2)<0 || rxy(2)>=axpos(4) % SO|NO
                    pos = [rxy(1:2)+axpos(1:2),axpos(3),bnd(0.03*axpos(4),[0.005,0.15])];
                else % bottom-right corner
                    pos = [rxy(1:2)+axpos(1:2),axpos(3)-rxy(1)-axpos(1),bnd(0.03*axpos(4),[0.005,0.15])];
                end
            end
        case {'rsz','relsz','relsize'} % [rw,rh]
            rsz = varargin{ii+1};
            if isscalar(rsz), rsz = [rsz,1]; end
            if ~isempty(pos)
                pos = [pos(1:2),rsz.*axpos(3:4)];
            else
                pos = [axpos(1)+axpos(3)+0.05,axpos(2),rsz.*axpos(3:4)];
            end
        case {'cl','clim'}
            clim = varargin{ii+1};
        case {'xlb','xlabel'}
            xlb = varargin{ii+1};
        case {'ylb','ylabel'}
            ylb = varargin{ii+1};
        case {'lb','lbl','label'}
            lbl = varargin{ii+1};
        case {'ttl','txt','title'}
            txt = varargin{ii+1};
        otherwise
            flag(ii:ii+1) = true;
    end
end
args = hgargs('cb',varargin(flag));

hcb = colorbar('peer',ax,args{:});
if ~isempty(clim), caxis(ax,clim); end
if ~isempty(xlb), xlabel(hcb,xlb); end
if ~isempty(ylb), ylabel(hcb,ylb); end
if ~isempty(lbl), hcb.Label.String = lbl; end
if ~isempty(txt), title(hcb,txt); end
if ~isempty(pos)
    pos(1) = bnd(pos(1),[0,1-pos(3)]);
    pos(2) = bnd(pos(2),[0,1-pos(4)]);
    if pos(3)>pos(4) % horizontal
        set(hcb,'location','southoutside','position',pos); 
    else
        set(hcb,'location','eastoutside','position',pos); 
    end
end
set(ax,'position',axpos,'units',axunit); % put axes back to original position
%% EOF
