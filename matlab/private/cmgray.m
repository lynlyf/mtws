function acm = cmgray(cm,g)
%% acm = cmgray(cm,g)
% usage:
%   acm = cmgray(cm1d,gray_values) % adjust gray values
%   acm = cmgray(cm2d,gray_values) % extract a 1d colormap by tracking grays in a 2d colormap
%   acm = cmgray(cm,'g') % return gray values
%   acm = cmgray(cm,'gcm') % return gray colormap
%   acm = cmgray(cm,'s') % balance the gray values to be symmetric
%
% input:
%   cm: colormap [r,g,b;...] | 2d colormap
%   g: gray (scalar, [lo,hi]|vector) | [lo,hi] of gray (default, [0,1]) | str
%      NaNs in g will be filled by linear interp; the fist and last gray cannot be NaN
%      if g is 'g|gray|grey', return gray values; 
%      if g is 'gcm', return gray colormap (equivalent to rgb2gray)
%      if g is 's|sym|symmetric', adjust gray values to be symmetric
% output: adjusted|extracted colormap
%
% see also: cmexpand, cmstore, cmpermute, cmunique; colorcube, cmapeditor, brighten
%%
if nargin == 0
    subfcn_demo;
    return;
end

% gray = 0.2989 * R + 0.5870 * G + 0.1140 * B
togray = [0.2989; 0.5870; 0.1140];
if nargin < 2
    g = 0.5; 
elseif ischar(g) % convert to gray
    acm = cm * togray;
    switch lower(g)
        case {'g','gray','grey'} % return gray values
            return; 
        case {'s','sym','symmetric'} % make colormap gray symmetric
            g = (acm+acm(end:-1:1)) / 2;
        otherwise
            acm = repmat(acm,1,3); % return gray colormap
            return;
    end    
end
if isscalar(g), g = [g,g]; end
g(isnan(g)) = interp1(find(~isnan(g)),g(~isnan(g)),find(isnan(g)));
g = min(max(g,0),1);

% make an image of colormap of size [gray,color,3]
nd = ndims(cm);
assert(nd>=2&&nd<=3&&size(cm,nd)==3,'not a colormap')
if nd==2, cm = cmexpand(cm,128,[0,1]); end
% convert to gray map of size [gray,color]
sz = size(cm);
gray = reshape(reshape(cm,[],3)*togray,sz(1:2));
% look for colors of given grays; use `closest` rather than `--` to avoid empty index
gs = interp1(1:length(g),g,linspace(1,length(g),sz(2)));
acm = arrayfun(@(ii)reshape(cm(closest(gray(:,ii),gs(ii)),ii,:),1,3),1:sz(2),'uni',0);
acm = cat(1,acm{:});
%%

%% SUBFUNCTION
function subfcn_demo
%% Builtin demo
verb(1,'run builtin demo of ',mfilename);
cm = cmstore(64,'spec'); 
cmtest(cmgray(cm,[0.2,0.8,nan,0.3])); set(gcf,'name','piecewise spec');
cm = cmstore('byr'); 
cmtest(cmgray(cm,'s')); set(gcf,'name','symmetric byr');
%% EOF