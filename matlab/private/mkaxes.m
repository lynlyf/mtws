function [ha,hcb,hf] = mkaxes(varargin)
%% create m*n axes
% usage: [ha,hcb,hf] = ...
%   mkaxes % make one axes
%   mkaxes(m,n[,r][,hf],'name',value,...)
%   mkaxes([m,n][,r][,hf],,...)
%   mkaxes([hf,]m,n[,r],,...)
%
%% input:
%   m,n: number of rows and columns
%   r: []|{range1,range2,...};
%   hf: figure handle
%   name-value pairs are passed to `subplot` except:
%     'ti|tight': call `subtightplot` if true or else `subplot`
%         if 'gap' or 'space' is specified, always call `subtightplot` 
%     'hf|fig|hfig|parent'; figure handle
%     'p|pos|axpos': axes positions [x,y,w,h;...] | {[x,y,w,h],...}
%     'cb[ar]|cbp[os]': positions of colorbars for every axes 
%         [x,y,w,h;...] | {['loc',][...],...}
%     'g|gap': [gap_v,gap_h] passed to `subtightplot`
%         margin_h and margin_v are set to the same value
%     's|sp|space', {gap,margin_h,margin_w} passed to `subtightplot`
%         gap: gaps between axes, gap|[v,h] gaps
%         margin_h: margin for height, margin_h|[lower,upper] margin_h
%         margin_w: margin for width, margin_w|[left,right] margin_w
%     'txt|ttl|title': axes title
%     '[xyz]l|[xyz]lim': axes limits
%     '[xyz]lb|[xyz]label': axes label
%     '[xyz][a][v|vis]': axes label
%% output: handles of axes and colorbars
%
%% example:
%  > ha = mkaxes(1,2,[],'ti',1,'gap',0.01,'xlb','x','txt','title');
%%
[ha,hcb,hf] = subfcn_parse(varargin{:});
%%

%% SUBFUNCTIONS
function [ha,hcb,hf] = subfcn_parse(varargin)
%% parse args
[m,n,r,hf] = deal(1,1,[],[]);
while ~isempty(varargin) && ~ischar(varargin{1}) % m,n,r,hf
    v = varargin{1};
    if isempty(v) % (m,n,[],hf,...)
        varargin = varargin(2:end);
    elseif isnumeric(v)
        if length(v)>2 % (..,r,..)
            [r,varargin] = deal(v,varargin(2:end));
        elseif isnumeric(varargin{2}) && isscalar(varargin{2}) % (..,m,n,...)
            [m,n,varargin] = deal(varargin{1:2},varargin(3:end));
        else % (..,[m,n],...)
            [m,n,varargin] = deal(v(1),v(2),varargin(2:end));
        end
    elseif isscalar(v) && ~isnumeric(v) && isgraphics(v,'figure') % (..,hf,...)
        [hf,varargin] = deal(v,varargin(2:end));
    elseif isempty(v) || iscell(v) % (..,r,...)
        [r,varargin] = deal(v,varargin(2:end));
    else
        break;
    end
end
if isempty(r), r = 1:m*n; end    
if isnumeric(r), r = num2cell(r); end
% prepare axes
flag = false(size(varargin));
[tight,axpos,cbpos] = deal(false,[],[]);
[xl,yl,zl,xlb,ylb,zlb,xav,yav,zav,txt] = deal([]);
space = {[0.02 0.05],[0.08 0.05],[0.08 0.02]};
for ii = 1 : 2 : length(varargin)
    val = varargin{ii+1};
    switch lower(varargin{ii})
        case {'tight','ti'} % subplot or subtightplot
            tight = val;
        case {'hf','fig','hfig','parent'} % parent figure handle
            if ~ishandle(val) || ~isequal(get(val,'Type'),'figure')
                error('wrong figure handle');
            end
            hf = val;
        case {'p','pos','axpos'} % axes positions [x,y,w,h;...]
            axpos = val;
        case {'cb','cbp','cbar','cbpos'} % colorbar positions
            cbpos = val;
        case {'g','gap'} % gap | [vertical,horizontal] gaps
            space = {val,val,val};
            tight = true;
        case {'s','sp','space'} % {gap,margin_h,margin_w}
            if iscell(val)
                space(1:length(val)) = val;
            else
                n = numel(val) / 2;
                assert(isnumeric(val)&&n<=6,'{gap,margin_h,margin_v} in percent expected');
                if n <= 3
                    space(1:length(val)) = num2cell(val);
                else
                    for jj = 1:n, space{jj} = val(2*jj+(-1:0)); end
                end
            end
            tight = true;
        case {'xl','xlim'}
            xl = val([1,end]);
        case {'yl','ylim'}
            yl = val([1,end]);
        case {'zl','zlim'}
            zl = val([1,end]);
        case {'xlb','xlbl','xlabel'}
            xlb = val;
        case {'ylb','ylbl','ylabel'}
            ylb = val;
        case {'zlb','zlbl','zlabel'}
            zlb = val;
        case {'xav','xv','xvis','xax'}
            xav = subfcn_onoff(val);
        case {'yav','yv','yvis','yax'}
            yav = subfcn_onoff(val);
        case {'zav','zv','zvis','zax'}
            zav = subfcn_onoff(val);
        case {'txt','ttl','title'}
            txt = val;
        otherwise
            flag(ii:ii+1) = true;
    end
end
args = hgargs('axes',varargin(flag));

if isempty(hf), hf = mkfig('units','normalized'); end
assert(isgraphics(hf,'figure'),'invalid figure hanle');
ha = subfcn_mkax(hf,m,n,r,tight,space);
subfcn_setax(hf,ha,args,axpos,xl,yl,zl,xlb,ylb,zlb,xav,yav,zav,txt);
hcb = subfcn_mkcb(ha,cbpos);
%%

function ha = subfcn_mkax(hf,m,n,r,tight,space)
%% make subplots
if tight
    spf = @(m,n,p,varargin)subtightplot(m,n,p,space{:},varargin{:});
else
    spf = @subplot;
end
nax = numel(r);
ha = gobjects(1,nax);
if isempty(hf.Children)
    for ii = 1:nax, ha(ii) = spf(m,n,r{ii},'Parent',hf); end
    return;
end
hf_tmp = figure('position',hf.Position,'units',hf.Units,'visible','off');
for ii = 1 : nax
    ha(ii) = spf(m,n,r{ii},'Parent',hf_tmp);
    set(ha(ii),'parent',hf);
end
close(hf_tmp);
%%

function subfcn_setax(hf,ha,args,axpos,xl,yl,zl,xlb,ylb,zlb,xav,yav,zav,txt)
%% set properties of axes
argdef = {'box','on', 'color','none', 'layer','top', 'nextplot','add', ...
          'units',get(hf,'units')}; % 'sortmethod','childorder'
set(ha,argdef{:},args{:});
% adjust subaxes positions
if ~isempty(axpos)    
    if iscell(axpos), axpos = cat(1,axpos{:}); end % [x,y,w,h;...]
    if ~isnumeric(axpos) || ~isequal(size(axpos),[length(ha),4])
        verb(1,'ignore wrong pos for axes');
    else
        for ii = 1 : length(ha)
            au = get(ha(ii),'units');
            %fu = get(hf,'units');
            if any(axpos(ii,:)<1)
                set(ha(ii),'units','normalized','position',axpos(ii,:));
            else
                set(ha(ii),'units','points','position',axpos(ii,:));
            end
        	set(ha(ii),'units',au);
        end
    end
end
% axis limits
if ~isempty(xl), subfcn_setprop(ha,'xlim',xl); end
if ~isempty(yl), subfcn_setprop(ha,'ylim',yl); end
if ~isempty(zl), subfcn_setprop(ha,'zlim',zl); end
% axis labels
if ~isempty(xlb), subfcn_setprop([ha.XLabel],'String',xlb); end
if ~isempty(ylb), subfcn_setprop([ha.YLabel],'String',ylb); end
if ~isempty(zlb), subfcn_setprop([ha.ZLabel],'String',zlb); end
% axis visibility
if ~isempty(xav), subfcn_setprop([ha.XAxis],'Visible',xav); end
if ~isempty(yav), subfcn_setprop([ha.YAxis],'Visible',yav); end
if ~isempty(zav), subfcn_setprop([ha.ZAxis],'Visible',zav); end
% axes title
if ~isempty(txt), subfcn_setprop([ha.Title],'String',txt); end
%%

function hcb = subfcn_mkcb(ha,cbpos)
%% add colorbars
hcb = [];
if isempty(cbpos), return; end
% verb(1,'add colorbars');
nax = length(ha);
if ischar(cbpos) % 'loc1,loc2,...'
    cbpos = strsplit(strrep(cbpos,' ',''),',');
elseif iscell(cbpos) && isnumeric(cbpos{1}) % {[x,y,w,h],...}
    cbpos = cat(1,cbpos{:});
end
if iscellstr(cbpos)  
    cbpos(cellfun(@isempty,cbpos)) = {'EO'}; 
    if isscalar(cbpos), cbpos = repmat(cbpos,1,nax); end 
end
if ~(iscellstr(cbpos)&&length(cbpos)==nax) && ~isequal(size(cbpos),[nax,4])
    verb(1,'ignore wrong args for colorbar');
    return;
end 
hcb = gobjects(1,nax);
for ii = 1 : nax
    try
        if iscellstr(cbpos) 
            if isnan(cbpos{ii}(1)), continue; end
            hcb(ii) = addcb(ha(ii),cbpos{ii});
        else            
            if isnan(cbpos(ii,1)), continue; end
            if cbpos(ii,3) > cbpos(ii,4) % horizontal colorbar
                hcb(ii) = addcb(ha(ii),'NO','position',cbpos(ii,:));
            else % vertical colorbar
                hcb(ii) = addcb(ha(ii),'EO','position',cbpos(ii,:));
            end
        end
    catch ME
        verb(1,sprintf('failed to add %d/%d colorbar because %s',ii,nax,ME.message));
    end
end
if isnumeric(cbpos), hcb = hcb(isfinite(cbpos(:,1))); end
%%

function subfcn_setprop(ha,p,v)
%% set property
% (ha(1:n),'prop',val|{val1,val2,...,valn}|[val1;val2;...valn])
%%
if isempty(v), return; end
n = length(ha);
if n == 1
    set(ha,p,v);
    return;
end

if n>1 && ischar(v)
    v = repmat({v},n,1); 
end
if iscell(v)
    if n>1&&isscalar(v), v = repmat(v,n,1); end
    batchfun(@(ii)set(ha(ii),p,v{ii}),1:n);
else
    if n>1&&size(v,1)==1, v = repmat(v,n,1); end
    batchfun(@(ii)set(ha(ii),p,v(ii,:)),1:n);
end
%%

function v = subfcn_onoff(v)
%% return 'on' or 'off'
if ~ischar(v)
    v = bycond(v,'on','off');
end
assert(ismember(v,{'on','off'}));
%% EOF
