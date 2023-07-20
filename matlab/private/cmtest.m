function cmtest(cm,flag)
%% cmtest(cmap[,flag])
% test performance of a colormap by view a peak, a direction image, the colorbar
% and its gray version, the gray level curve and its reverse version
% 
% cm: colormap [r,g,b;...]
% flag: -1, flip colormap; 1, in gray; 0 (default), do nothing
%
% see also: cmstore, cminterp, cmresamp, cmgray, cmdisp, plot_cbar
%%
if nargin == 0
    verb(1,'usage: ',mfilename,'(cmap,flip_flag)');
    return;
end

if ischar(cm), cm = cmstore(64,cm); end
if nargin<2, flag = 0; end
switch flag
    case {-1,'f','flip','r','reverse'}
        cm = flipud(cm); 
    case {'g','gray','grey'}
        cm = rgb2gray(cm); 
end
% new figure and axes
hf = mkfig([680,620],[1/3,1/3],'menubar','none','toolbar','none', ...
        'numbertitle','on','name','Test Colormap');
ha = mkaxes(9,2,{1:2:9,2:2:10,11:12,13:14,15:18},hf,'gap',0.01);
% Gaussian
t = -2.5 : 0.02 : 2.5;
x = exp(-t.^2);
y = -2.33*t .* exp(-t.^2); 
[X,Y] = meshgrid(x,y);
d = X.*Y; 
imagesc(d,'parent',ha(1)); caxis(ha(1),[-1,1]); colormap(ha(1),cm);
% baz directions
[x,y] = deal(-10:0.5:10,-10:0.5:10);
[X,Y] = meshgrid(x,y);
d = 180 + atan2d(X,Y);
imagesc(x,y,d,'parent',ha(2)); caxis(ha(2),[0,360]); colormap(ha(2),cm); 
set(ha(1:2),'DataAspectRatio',[1,1,1]); % axis(ha(1:2),'xy','tight','image');
% linear gradient (colorbar and its gray version)
n = size(cm,1);
g = cmgray(cm,'gcm');
hm = imagesc(1:256,'parent',ha(3)); caxis(ha(3),[1,256]); colormap(ha(3),cm); 
imagesc(1:256,'parent',ha(4)); caxis(ha(4),[1,256]); colormap(ha(4),g); 
set(hm,'ButtonDownFcn',@(src,evt)subfcn_pickcolor(cm(closest(1:n,ha(3).CurrentPoint(1)*n/256),:)));
axis(ha(1:end-1),'xy','tight'); set(ha,'xtick',[],'ytick',[]);
% gray variations
n = size(cm,1);
lc = [1,1,1]*0.85;
lineh(.1:.1:.9,[0,n+1],'color',lc,'parent',ha(end));
linev((1:21)/22*(1+n),[0,1],'color',lc,'parent',ha(end));
line([1,(n+1)/2,n,nan,1,n,nan,1,n],[0,1,0,nan,0,1,nan,1,0],'color',lc*0.9,'parent',ha(end));
hc = scatter(1:n,g(:,1),300,cm,'filled','markeredgecolor','none','parent',ha(end));
scatter(1:n,g(end:-1:1,1),300,cm(end:-1:1,:),'parent',ha(end));
set(hc,'ButtonDownFcn',@(src,evt)fprintf('selected rgb = [%.2f %.2f %.2f]\n', ...
    cm(round(ha(end).CurrentPoint(1)),:)));
%% another method using hidden handles
% args = hgargs('line',{'ls','none','mk','o','mksz',20,'mec','none','mfc','w','ax',ha(end)});
% hl = plot(1:n,g(:,1),args{:}); 
% hm = plot(1:n,g(end:-1:1,1),args{:},'markerfacecolor','none','markeredgecolor','w'); 
% um = cm2uint8(cm,1); drawnow;
% set(hl.MarkerHandle,'FaceColorBinding','interpolated','FaceColorData',um);
% set(hm.MarkerHandle,'EdgeColorBinding','interpolated','EdgeColorData',um(:,end:-1:1));
%% yet another method
% args = hgargs('line',{'lw',20,'mk','o','mksz',20,'mec','w','mfc','none','ax',ha(end)});
% hl = plot(1:n,g(:,1),args{:},'marker','none'); 
% hm = plot(1:n,g(end:-1:1,1),args{:},'linestyle','none'); 
% um = cm2uint8(cm,1); drawnow;
% set(hl.Edge,'ColorBinding','interpolated','ColorData',um);
% set(hm.MarkerHandle,'EdgeColorBinding','interpolated','EdgeColorData',um(:,end:-1:1));
set(ha(end),'xlim',[0,n+1],'ylim',[0,1]); 
% tightfig(hf);
%%

%% SUBFUNCTIONS
function subfcn_pickcolor(c)
%%
assignin('base','CMTEST_COLOR',c);
fprintf('$ %s: picked rgb = [%.2f %.2f %.2f]\n',mfilename,c);
%% EOF