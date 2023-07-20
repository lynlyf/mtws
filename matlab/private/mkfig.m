function hf = mkfig(varargin)
%% make figure and return figure handle
% usage: hf = ...
%   mkfig; 
%   mkfig('color') 
%   mkfig(wh[,xy],'property',value,...);
%   mkfig(w,h[,xy],...);
%
%% tips
% - w/h in [0,1] is treated as percentages of 
%   w/h from 1 to 50 is assumed to be in cm
%   w/h larger than 50 is assumed to be in pixels
% - better to avoid passing 'position' args
% - all args are passed to `setfig`. see `setfig` for more details
% 
%% example:
%   > hf = mkfig(0|1|2|0.X); % full screen, full width, full height, pct
%   > hf = mkfig([1,1/2],[2,1/3]);
%
% see also: gcfa, gchg, mkaxes, setfig, pagesize
%%
argdef = {'color','w', 'colormap',jet, ...
          'nextplot','add', 'units','normalized', ....
          'PaperPositionMode','auto', 'InvertHardcopy','off'};
hf = figure(argdef{:});
if nargin>0 && isnumeric(varargin{1})
    if isequal(varargin{1},0) % mkfig(0,...)
        varargin{1} = [1,1]; 
    else
        k = length(varargin{1});
        assert(k<=2&&all(varargin{1}>0),'wrong inputs');
    end
end
if nargin >= 2
    if isnumeric(varargin{1}) && isscalar(varargin{1}) && ...
       isnumeric(varargin{2}) && isscalar(varargin{2}) % mkfig(w,h,...)
        varargin = [{[varargin{1},varargin{2}]},varargin(3:end)];
    end
end
setfig(hf,varargin{:}); % setfig(hf,wh[,xy],'prop',val,...)
%% EOF
