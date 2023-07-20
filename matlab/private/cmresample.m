function cmap = cmresample(cmap,m)
%% cmap = cmresample(cmap,m)
% resample a (2d) colormap
%
% input:
%   cmap: colormap of size [n,3] | 2d colormap of size [n1,n2,3]
%   m: resample colormap to size [m,3] | [m(1),m(2),3]
% output: resampled colormap
%
% see also: cminterp, cmindex, cmstore, cmtest
%%
if nargin == 0
    subfcn_demo;
    return;
end

if nargin == 1 % cmresample(m)
    assert(isscalar(cmap)&&isnumeric(cmap)&&cmap>1,'wrong input');
    ha = gchg('ax');
    assert(~isempty(ha),'no axes available');
    [cmap,m] = deal(ha,cmap);
end
if isaxes(cmap,1) % cmresample(ax,m)
    ha = handle(cmap);
    cmap = cmresample(colormap(ha),m);
    verb(1,sprintf('resample colormap to %d colors',m));
    colormap(ha,cmap);
    return;
end
% cmresample(cmap,m)
sz = size(cmap);
nd = ndims(cmap);
assert(sz(nd)==3,'invalid colormap');
m = fix(m);
assert(all(m>1)&&length(m)+1==nd,'wrong m');
cmap = interp1(1:sz(1),cmap,linspace(1,sz(1),m(1)));
if nd==2, return; end
% resample another dim
cmap = permute(cmap,[2,1,3]);
cmap = interp1(1:sz(2),cmap,linspace(1,sz(2),m(2)));
cmap = permute(cmap,[2,1,3]);
%% 

%% SUBFUNCTION
function subfcn_demo
%% Builtin demo
verb(1,'run builtin demo of ',mfilename);
cmap = cmstore(256,'spec');
cmim = cmexpand(cmap,128,[0,1]);
cm = cmexpand(cmgray(cmim,0.5),128,[0.1,0.9]);
ha = mkaxes(2,2,[],'ti',1);
image(reshape(cmap,[],1,3),'parent',ha(1));
image(reshape(cmresample(cmap,10),[],1,3),'parent',ha(2));
image(cm,'parent',ha(3));
image(cmresample(cm,[12,12]),'parent',ha(4));
axis(ha,'xy','tight');
%% EOF