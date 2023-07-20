function obj = cmobj(h,kind)
%% obj = cmobj(h)
% returns object containing the Alphamap/Colormap property 
% see also: .../graphy3d/priviate/getMapContainer.m
%%
obj = [];
if nargin==0, h = gchg('axes'); end
if isempty(h), return; end
assert(isscalar(h));

if isprop(h,'ColorSpace') && isa(get(h,'ColorSpace'),'matlab.graphics.axis.colorspace.ColorSpace')
    obj = get(h,'ColorSpace'); % ColorSpace has the AlphaMap/ColorMap property
    return;
end

if nargin < 2 || isempty(kind) % cmobj(h)
    if isprop(h,'Colormap')||isprop(h,'Alphamap'), obj = h; end
else % cmobj(h,kind)
    assert(ischar(kind),'wrong kind');
    alias = {'Colormap',{'cm','cmap','color'}, 'Alphamap',{'am','alpha','amap'}};
    kind = parse_alias(alias,lower(kind));
    if isprop(h,kind), obj = h; end
end
%% EOF