function cmap = cminterp(n,c,x)
%% cmap = cminterp([n,]c[,x])
% make colormap by interpolate colors
% 
% input:
%   n: number of colors
%   c: node colors; 'c1-...-cN'|'c1,...,cN'|[r,g,b;...]|{'c1'|[r,g,b],...}
%      supported short names: 'roygcbmvwk'
%      for a single full colorname, use 'name'|{'name'}
%   x: empty (default) or node values (at least 3 values)
%   gray interpolation is not provided; use `cmgray` to adjust gray.
% output: colormap
%
% example:
%   > cminterp('w') % gray colormap from white to black
%   > cminterp('k') % gray colormap from black to white
%   > cminterp(32,'ww') % colormap with white colors only
%   > cminterp(64,'bwr') % blue-white-red
%   > cminterp(64,'roygcbm') % light spectrum
%   > cminterp(256,cmstore('dkbwr'),[clim(1),0,clim(2)]) % make zeros white
%   > cminterp(8,'steelblue-w-firebrick')
%   > cminterp(12,'dodgerblue-white-coral')
%
% see also: cmexpand, cmgray, cmnumber, cmocean, cmresample, cm2uint8, setcmap,
%           hslcolormap, css2cmap, rgbmap, rgb, css2rgb, colornames
%%
if nargin == 0
    subfcn_demo;
    return;
end

%% parse inputs
if nargin == 1 % cminterp(c)
    [n,c,x] = deal(cmnumber,n,[]); 
elseif nargin == 2 
    if isscalar(n) && isnumeric(n) % cminterp(n,c)
        x = [];
    else % cminterp(c,x)
        [n,c,x] = deal(cmnumber,n,c); 
    end
end
assert(isscalar(n),'wrong n');
c = subfcn_nodes(c);
n = fix(n);
if n==0
    return;
elseif n<0 % flipud
    n = -n; 
    c = c(end:-1:1,:); 
end 
if n == 1
    cmap = c(1,:);
    return;
end
m = size(c,1);
if m == 1 % extend a single color to white or black
    if cmgray(c,'g')<0.9, c = [c; 1,1,1]; else; c = [0,0,0; c]; end
    m = 2;
end
if m~=n, c = interp1(1:m,c,linspace(1,m,n)); end
nseg = length(x) - 1;
if nseg < 2
    cmap = c;
    return;
end
%% interp according to x
n1 = splitbypct(n,ones(1,nseg)/nseg); % uniform segments
n2 = splitbypct(n,diff(x)/(x(end)-x(1))); % segment npts
id = [0,cumsum(n1)];
cmap = cell(1,nseg);
for ii = 1 : nseg % interp each segment
    cmap{ii} = interp1(1:n1(ii),c(id(ii)+1:id(ii+1),:),linspace(1,n1(ii),n2(ii)));
end
cmap = cat(1,cmap{:});
%%

%% SUBFUNCTIONS
function c = subfcn_nodes(c)
% parse node colors
if ischar(c)
    if ismember('-',c) % 'c1-c2-...-cN'
        c = strsplit(strrep(c,' ',''),'-');
    elseif ismember(',',c) % 'c1,c2,..,cN'
        c = strsplit(strrep(c,' ',''),',');
    else % 'roygcbmwk'
        c = cellstr(c(:));
    end
    c = c(~cellfun(@isempty,c));
    assert(~isempty(c),'no colors specified');
end
if iscell(c) % {'colorname'|[r,g,b],...}
    for ii = 1 : length(c)
        if isnumeric(c{ii})
            if isscalar(c{ii}) % gray
                c{ii} = c{ii}*[1,1,1];
            else % [r,g,b]
                c{ii} = reshape(c{ii},1,3);
            end
        else
            c{ii} = cmalias(c{ii});
            try
                c{ii} = css2rgb(c{ii});
            catch
                c{ii} = rgb(c{ii});
            end
        end
    end
    c = cat(1,c{:});
end 
%%

function x = subfcn_adjust(n,pct)
%% split n samples to length(pct) segments
% sum(pct)=1, sum(x)=n
%%
x = n * pct;
y = fix(x);
r = x - y;
for ii = 1 : length(r)-1
    [r(ii),r(ii+1)] = deal(fix(r(ii)),r(ii+1)+r(ii)-fix(r(ii)));    
end
x = y + r;
%%

function subfcn_demo
%% Builtin demo
verb(1,'run builtin demo of ',mfilename);
c = {'b-w-w-r', 'cbkry', {'brown',[1,1,1],'skyblue'}, ...
     [0 0.2 1; 1 1 1; 0.2 1 0], 'djjuuswvtd', ...
     'djaswvmd', 'djqshvmd', 'dqjswvmd', 'duqhvrd', 'djaswvyrd', ...
     {'bwr',[-1,0,5]}, {'blue,'}};
k = length(c)+1;
hf = mkfig('name',['demo of ',mfilename]);
ha = mkaxes(k,1,hf,'gap',0.01,'ti',1,'xt',[],'yt',[]);
for ii = 1 : k-3
    plot_cbar(cminterp(128,c{ii}),'ax',ha(ii),'orient','h');
end
plot_cbar(cminterp(128,c{k-2}{:}),'ax',ha(k-2),'orient','h');
plot_cbar(cmgray(cminterp(64,c{k-1}{:}),[0,0.1,0.3,0.7,1]),'ax',ha(k-1),'orient','h');
cm = reshape(cmexpand(cminterp(6,'ejsyor'),10,[0.2,0.9]),[],3);
plot_cbar(cm,'ax',ha(k),'ori','h');
%% EOF