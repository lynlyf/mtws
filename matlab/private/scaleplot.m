function yb = scaleplot(h,k,base,extag)
%% scaleplot(h,k,base);
% scale the ydata on a plot
% input: 
%   h, axes handle
%   k, zoom factor
%   base, a number as or a function handle to calculate the fixed base
%   extag, if not empty, skip data with extag
% output:
%   yb, each row contains the lower and upper limits of the ydata of a line handle
%%
if nargin<2, k = 2; end
if nargin<3, base = @mean; end
if nargin<4, extag = ''; end
yb = nan(length(h),2);
for ii = 1:length(h)
    if ~ishandle(h(ii)), continue; end
    if ~isempty(extag) && isequal(get(h(ii),'Tag'),extag), continue; end
    y = get(h(ii),'YData');
    y = subfcn_proc(y,k,base);
    set(h(ii),'YData',y);
    yb(ii,:) = getbound(y);
end
yb(isnan(yb(:,1)),:) = [];
%%

function b = subfcn_proc(a,k,base)
%%
b   = a;
nid = find(isnan(a));
nid = [0; nid(:); length(a)+1];
for ii = 1 : length(nid)-1
    id = nid(ii)+1 : nid(ii+1)-1;
    if length(id)<=1
        continue;
    else
        if isnumeric(base)
            am = base;
        else
            am = base(a(id));
        end
        b(id) = am + k*(a(id)-am);
    end
end
%%