function N = cmnumber(h)
%% N = cmnumber(h)
% Return number of colors in the colormap of hghandle h
%%
if nargin<1, h = []; end
if isempty(h), h = get(0,'CurrentFigure'); end
if isempty(h)
    N = 64;
    return;
end
hc = cmobj(h);
assert(isprop(hc,'colormap'),'invalid handle');
N = size(get(hc,'colormap'),1);
%% EOF