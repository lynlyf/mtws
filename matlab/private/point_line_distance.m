function varargout = point_line_distance(varargin)
%% calculate distances from points to a line defined by two points
% usage: [distance,projection] = ...
%    point_line_distance(x,y,x1,y1,x2,y2)
%    point_line_distance([x,y],[x1,y1],[x2,y2])
%
% * distance is positive/negative if a point is below/above the line
% * for a vertical line, 
%     y1<y2: -/+ distance for points at left/right
%     y1>y2: +/- distance for points at left/right
%     y1=y2: distance unavailable (return NaN)
% * regarding the formulae to calculate point-to-line distances, see
%   https://en.wikipedia.org/wiki/Distance_from_a_point_to_a_line
%
% input:
%   [x,y]: points to calculate the distances to the line
%   [x1,y1],[x2,y2]: two points define the line
% output: 
%   distance: distance from P=[x,y] to line P1P2
%   projection: projection of P onto line P1P2
%
% see also: 
%%
if nargin == 0
    subfcn_demo;
    return;
end

if nargin==3 %(pt=[x,y],pt1=[x1,y1],pt2=[x2,y2])
    assert(size(varargin{1},2)==2,'[x(:),y(:)] expected');
    assert(numel(varargin{2})==2,'[x1,y1] expected');
    assert(numel(varargin{3})==2,'[x2,y2] expected');
    [x,y] = deal(varargin{1}(:,1), varargin{1}(:,2));
    [x1,y1] = deal(varargin{2}(1), varargin{2}(2));
    [x2,y2] = deal(varargin{3}(1), varargin{3}(2));
elseif nargin==4 %(x,y,[x1,y1],[x2,y2])
    [x,y] = deal(varargin{1:2});
    assert(numel(varargin{3})==2,'[x1,y1] expected');
    assert(numel(varargin{4})==2,'[x2,y2] expected');
    [x1,y1] = deal(varargin{3}(1), varargin{3}(2));
    [x2,y2] = deal(varargin{4}(1), varargin{4}(2));
else %(x,y,x1,y1,x2,y2)
    [x,y,x1,y1,x2,y2] = deal(varargin{:});
end

if ~isequal(size(x),size(y))
    if isvector(x) && isvector(y)
        y = reshape(y,size(x));
    else
        error('x and y different size');
    end
end

% switch points on line to ensure dis>0 for points below line 
if x1 > x2 
    [x1,y1,x2,y2] = deal(x2,y2,x1,y1);
end

% distance = cross(pt2-pt1,pt-pt1)/norm(pt2-pt1)
%    = (a*x+b*y+c)/sqrt(a*a+b*b)
numerator = (x2-x1)*(y1-y) - (x1-x)*(y2-y1);
denominator = sqrt((x2-x1)^2 + (y2-y1)^2);
varargout{1} = numerator / denominator;
if nargout<2, return; end

%% projections of point onto line
if x1 == x2 % vertical line
    xp = x1 * ones(size(y));
    yp = y;
elseif y1 == y2 % horizontal line
    xp = x;
    yp = y1 * ones(size(x));
else
    k = (y2-y1) / (x2-x1);
    b = y1 - k*x1;
    kv = -1/k;
    bv = -kv*x + y;
    xp = (bv-b) / (k-kv);
    yp = kv*xp + bv;
end
varargout{2} = [xp(:),yp(:)];
%% 

%% SUBUNCTIONS
function subfcn_demo
%% builtin demo
verb(1,'run builtin demo of ',mfilename);
hf = mkfig('name',[mfilename,' demo']);
ha = mkaxes(1,1,hf,'ti',1,'dar',[1,1,1]);
% negative slope
pt = [-1,-2];
[pt1,pt2] = deal([0,3],[4,0]);
line2p(ha,pt1,pt2,'b-','mk','o','mfc','b');
[d,p] = point_line_distance(pt,pt1,pt2);
line2p(ha,pt,p,'k--','mk','o','mfc','r');
textcell(ha,p,sprintf('  d=%.2g',d));
pt = [-4,2; 4,3];
[d,p] = point_line_distance(pt,pt1,pt2);
arrayfun(@(ii)line2p(ha,pt(ii,:),p(ii,:),'k--','mk','o','mfc','r'),1:size(pt,1));
arrayfun(@(ii)textcell(ha,p(ii,:),sprintf('  d=%.2g',d(ii))),1:size(pt,1));
% positive slope
pt = [-1,-2];
[pt1,pt2] = deal([0,4],[-3,0]);
line2p(ha,pt1,pt2,'b-','mk','o','mfc','b');
[d,p] = point_line_distance(pt,pt1,pt2);
line2p(ha,pt,p,'k--','mk','o','mfc','r');
textcell(ha,p,sprintf('  d=%.2g',d));
pt = [-4,2; 4,3];
[d,p] = point_line_distance(pt,pt1,pt2);
arrayfun(@(ii)line2p(ha,pt(ii,:),p(ii,:),'k--','mk','o','mfc','r'),1:size(pt,1));
arrayfun(@(ii)textcell(ha,p(ii,:),sprintf('  d=%.2g',d(ii))),1:size(pt,1));
% horizontal
pt = [-1,-2];
[pt1,pt2] = deal([-4,-1],[4,-1]);
line2p(ha,pt1,pt2,'b-','mk','o','mfc','b');
[d,p] = point_line_distance(pt,pt1,pt2);
line2p(ha,pt,p,'k--','mk','o','mfc','r');
textcell(ha,p,sprintf('  d=%.2g',d));
pt = [-4,2; 4,3];
[d,p] = point_line_distance(pt,pt1,pt2);
arrayfun(@(ii)line2p(ha,pt(ii,:),p(ii,:),'k--','mk','o','mfc','r'),1:size(pt,1));
arrayfun(@(ii)textcell(ha,p(ii,:),sprintf('  d=%.2g',d(ii))),1:size(pt,1));
% vertical
pt = [-1,-2];
[pt1,pt2] = deal([-1,-3],[-1,6]);
line2p(ha,pt1,pt2,'b-','mk','o','mfc','b');
[d,p] = point_line_distance(pt,pt1,pt2);
line2p(ha,pt,p,'k--','mk','o','mfc','r');
textcell(ha,p,sprintf('  d=%.2g',d));
pt = [-4,2; 4,3];
[d,p] = point_line_distance(pt,pt1,pt2);
arrayfun(@(ii)line2p(ha,pt(ii,:),p(ii,:),'k--','mk','o','mfc','r'),1:size(pt,1));
arrayfun(@(ii)textcell(ha,p(ii,:),sprintf('  d=%.2g',d(ii))),1:size(pt,1));
grid(ha,'on');
%% EOF
