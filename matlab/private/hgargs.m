function args = hgargs(alias,varargin)
%% args = hgargs(alias,['xxx',]'prop',value,...)
% Parse args
%
% input:
%   alias: shortcut name | alias dict | a hghandle
% output: parsed args
% example:
%   > hgargs('ax','xl',[1,10],'col','b')
%   > hgargs('line',{'k-','mk','o','lw',3})
% see also: hgpropalias, parse_alias, cell2arg, arg2cell
%%
if isempty(varargin)
    %verb(1,'Usage: args = hgargs(alias,[linestyle,]prop,value,...)');
    %verb(1,'To get alias dict, call `hgpropalias(hgname)`');
    args = {};
    return;
elseif isscalar(varargin)
    if iscell(varargin{1})
        args = reshape(varargin{1},1,[]);
    elseif isstruct(varargin{1})
        args = arg2cell(varargin{1});
    else %
        args = varargin;
    end
else
    args = varargin;
end

if isempty(alias), alias = 'line'; end
if isscalar(alias)&&ishghandle(alias), alias = get(alias,'type'); end
if ischar(alias), alias = hgpropalias(alias); end

x = {}; % preceding shortcuts for color/linestyle, e.g. 'k-'
if mod(length(args),2)
    [x,args] = deal(args(1),args(2:end)); 
end
if isempty(args)
    args = x;
else
    args(1:2:end) = lower(args(1:2:end));
    args = fldren(args,alias);
    args = [x,arg2cell(args)];
end
%% EOF