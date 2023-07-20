function flag = isaxes(h,aflag)
%% flag = isaxes(h,aflag)
% Check if being axes handle(s)
%
% - `isaxes` is an alternative to `isgraphics(h,'axes')`, but with an
%   additional function to check if the input is a scalar
%
% see also: istype; isgraphics, ishghandle
%%
if nargin>1 && aflag
	flag = isscalar(h) & isa(h,'matlab.graphics.axis.Axes');
    return;
end

flag = arrayfun(@(x) isa(x,'matlab.graphics.axis.Axes'),h);
%% EOF
