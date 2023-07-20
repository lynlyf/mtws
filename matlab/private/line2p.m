function h = line2p(varargin)
%% h = lined([ha,]pt1,pt2[,linestyle][,'prop',value,...]);
% plot a line segment bounded by two points
%    
% input:
%   ha: axes handle (default, gca)
%   pt1,pt2: two points, [x, y] (
%   see `lined` for other arguments
% output: line handle
%
% see also: linev, lineh, liner, lined, linemk
%%
if nargin == 0
    help(mfilename);
    return;
end

if hgdel(mfilename,'line',varargin), return; end
if 1<=nargin && nargin<=2 && isequal(varargin{end},'get') % ([hf|ha,]'get')      
    h = hgfind(varargin{1:end-1},'tag',mfilename,'type','line');
    return;
end

[ha,x,y,z,args] = subfcn_parse(varargin{:});
if isempty(z)
    h = linemk(ha,x,y,args{:});
else
    h = linemk(ha,x,y,z,args{:});
end
%%

%% SUBFUNCTIONS
function [ha,x,y,z,args] = subfcn_parse(varargin)
%% parse args
hasax = nargin>0 && length(varargin{1})==1 && ishghandle(varargin{1}) ...
        && isequal(get(varargin{1},'Type'),'axes');
if hasax % (ha,pt1,pt2,...)
    [ha,pt1,pt2,args] = deal(varargin{1:3},varargin(3:end));
else 
    ha = gca;
    if nargin>=3 && isnumeric(varargin{3}) % (pt1,len,ang,...)
        [pt1,l,a,args] = deal(varargin{1:3},varargin(4:end));
        pt2 = pt1 + reshape(l*ang2vec(a),size(pt1));
    else % (pt1,pt2,...)
        [pt1,pt2,args] = deal(varargin{1:2},varargin(3:end));
    end
end 
set(ha,'nextplot','add');
[x,y,z] = deal([pt1(1),pt2(1)],[pt1(2),pt2(2)],[]);
if length(pt1)>2, z = [pt1(3),pt2(3)]; end
%% EOF
