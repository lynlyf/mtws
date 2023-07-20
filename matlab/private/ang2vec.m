function u = ang2vec(ang,isdeg)
%% u = ang2vec(ang,isdeg); 
% make unit vector from azimuth and polar angle
% input:
%   ang: [azi[,pol]];
%     azi: azimuth angle, scalar or column vector
%     pol: polar angle, scalar or column vector
%   isdeg: 1 for degree (default), 0 for radian
%  output: row-wise unit vector(s)
%%
if nargin<2, isdeg = 1; end
if isdeg, ang = ang * pi/180; end
if size(ang,2)==1 % 2d
    u = [cos(ang),sin(ang)];
    return;
end
%% 3d
azi = ang(:,1);
pol = ang(:,2);
u   = [cos(azi).*sin(pol), sin(azi).*sin(pol), cos(pol)];
%%
