function cm2 = cmexpand(cm,n,l)
%% cm2 = cmapex(cm,n,l); 
% expand a colormap of size [m,3] to size [n,m,3] by changing lightness 
%
% input:
%   cm: colormap [r,g,b;...] in size of [m,3]
%   n: number of gray gradients
%   l: [lo,hi] of lightness (default, [0,1])
%       0, black; 0.5, color in `cm`; 1, white
% output: colormap in size of [n,m,3], where n/m is the number of lightness/hues
% example:
%   > imshow(cmexpand(hsv(256),128,[0,0.5])); axis xy tight;
%   > imshow(cmexpand(jet(256),128,[1,0.5])); axis xy tight;
% see also: cmindex, cmstore, cmtest
%%
if nargin == 0
    subfcn_demo;
    return;
end

m = size(cm,1);
if nargin<2 || isempty(n), n = m; end
if nargin<3, l = [0,1]; end

% dim1/colors,dim2/[r,g,b],dim3/[k,color,w] => dim1/[k,color,w],dim2/colors,dim3/[r,g,b]
cm2 = shiftdim(cat(3,zeros(m,3),cm,ones(m,3)),2); 
lts = interp1(1:length(l),l,linspace(1,length(l),n));
cm2 = interp1([0,0.5,1],cm2,lts);

if nargout == 0
    ha = mkaxes(1,1,[],'ti',1,'gap',0);
    subfcn_plot(ha,cm2);
end
%%

%% SUBFUNCTION
function subfcn_plot(ha,cm2)
%% plot colormap as image
imshow(cat(2,repmat(rgb2gray(cm2),1,1,3),cm2),'parent',ha); 
axis(ha,'xy','tight');
%%

function subfcn_demo
%% Builtin demo
verb(1,'run builtin demo of ',mfilename);
[m,n,l] = deal(512,256,[0,0.9]); 
orient = 'v'; % horizontal/vertical orientation
cms = {@(n)cmstore(n,'spec'),@(n)cmstore(n,'spec'),@hsv, ...
       @(n)cmstore(n,'vjet'),@(n)cmstore(n,'vjet'),@(n)cmstore(n,'cb')};
if orient == 'h'
    ha = mkaxes(2,length(cms)/2,[],'ti',1,'gap',0);
else
    ha = mkaxes(2,length(cms)/2,[],'ti',1,'gap',0);
end
for ii = 1 : length(cms)
    cm = cms{ii}(m); % dim1/colors,dim2/[r,g,b]
    cm2 = cmexpand(cm,n,l); % dim1/lightness,dim2/colors,dim3/[r,g,b]
    if ii==1, cm2 = cmexpand(cmgray(cm2,0.5),n,l); end
    if ii==4, cm2 = cmexpand(cm,n,[0,.5]); end
    if ii==5, cm2 = cmexpand(cmgray(cm2,0.5),n,l); end
    if orient=='v', cm2 = permute(cm2,[2,1,3]); end
    subfcn_plot(ha(ii),cm2); 
end
set(ha,'box','on','visible','on','xtick',[],'ytick',[]);
%% EOF