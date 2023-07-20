function batchfun(fcn,x,varargin)
%% batchfun(fcn,x,...)
% similar to arrayfun/cellfun but without return values
% 
%   fcn: function handle | cell of function handles 
%   x: array | cell array to pass elements to `fcn`
%   varargin: other arrays|scalar
%
% example:
%   > batchfun(@(ii,jj)fprintf('%d\n',ii+jj),1:3,2); 
%   > batchfun(@(ii,jj)fprintf('%d\n',ii+jj),1:3,2:4); 
% see also: arrayfun, cellfun
%%
if iscell(fcn)
    for ii = 1:length(fcn), batchfun(fcn{ii},x,varargin{:}); end
    return;
end

if iscell(x)
    for ii = 1:length(x), fcn(x{ii},varargin{:}); end
    return;
end

n = length(x);
v = ziplist(x,varargin{:});
for ii = 1:length(x), fcn(v{ii}{:}); end
% for ii = 1:length(x), fcn(x(ii),varargin{:}); end
%% EOF