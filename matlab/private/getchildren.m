function h = getchildren(parent,varargin)
%% h = getchildren(parent,prop,val);
% Get handles of children by given property and value.
%%
if nargin<2
    if isequal(get(parent,'type'),'figure')
        varargin = {'type','axes'};
    elseif isequal(get(parent,'type'),'axes')
        varargin = {'type','line'};
    else
        error('wrong inputs');
    end
end
h = get(parent,'Children');
flag = true(size(h));
for ii = 1 : length(h)
    for jj = 1 : 2 : length(varargin)
        flag(ii) = flag(ii) && isequal(get(h(ii),varargin{jj}),varargin{jj+1});
    end
end
h = h(flag);
%%
