function alias = hgpropalias(name,ascell)
%% alias = hgpropalias(hgname,ascell|'prop')
% return alias dict for properties of hgobject
%
% input:
%   name:   name of alias dict. 
%           '[f]ig,[a]xes,[l]ine,[m]ark,[i]mg,[s]urf,[t]ext'
%   ascell: output `alias` dict as cellstr (default) or struct
% output: alias dict
%
% example:
%   > parse_alias(hgpropalias('ax'),'col')
%
% see also: hgargs, parse_alias, hgrevert
%%
if nargin==0 || isempty(name)
    help(mfilename);
    return;
end

if nargin<2
    ascell = true; 
elseif ischar(ascell) % hgpropalias(hgname,'prop')
    p = lower(ascell);
    ad = hgpropalias(name,0);
    if isfield(ad,p)
        alias = strjoin(ad.(p),', ');
    else
        alias = [];
        verb(1,p,' is not a valid propname in alias dict');
    end
    return;
end

if isscalar(name) && ishghandle(name)
    try
        name = get(name,'type');
    catch
        name = class(name);
    end
end

switch lower(name)
    case {'b','basic'}
        alias = subfcn_basic;
    case {'c','classic'}
        alias = subfcn_classic;
    case {'f','fig','figure'}
        alias = subfcn_figure;
    case {'a','ax','axes'}
        alias = subfcn_axes;
    case {'lg','legend'}
        alias = subfcn_legend;
    case {'l','ln','line'}
        alias = subfcn_line;
    case {'st','stair'}
        alias = subfcn_line;
    case {'m','mk','marker','sc','scatter'}
        alias = subfcn_scatter;
    case {'p','patch','area'}
        alias = subfcn_patch;
    case {'i','im','img','image'}
        alias = subfcn_img;
    case {'s','sf','surf','surface'}
        alias = subfcn_surf;
    case {'h','hist','histogram'}
        alias = subfcn_patch;
    case {'t','txt','text','textboxshape'}
        alias = subfcn_text;
    case {'cb','cbar','colorbar'}
        alias = subfcn_cbar;
    case {'q','qv','quiver'}
        alias = subfcn_quiver;
    case {'bc','boxchart'}
        alias = subfcn_boxchart;
    case {'list','lsopt','options','opts'}
        verb(1,['available options: [b]asic, [c]lassic, ', ...
            '[f]igure, [a]xes, [l]ine, [m]arker, ', ...
            '[i]mage, [s]urface, [q]uiver, [t]ext, ', ...
            'boxchart, boxplot, colorbar']);
    otherwise
        error('unknown alias type');    
end
alias = cell2arg(alias); 
if ascell, alias = arg2cell(alias); end
%%

%% SUBFUNCTIONS
function alias = subfcn_reject(alias,varargin)
%% reject some name-alias pairs
if isscalar(varargin)
    rejectlist = str2cell(varargin{1},',',1);
else
    rejectlist = str2cell(varargin,',',1);
end
id = ~ismember(lower(alias(1:2:end)),lower(rejectlist));
alias = alias(repelem(id,2));
%%

function alias = subfcn_classic
%% alias dict of usual props
alias = {'alphadata',{'ad','adata'}, 'alphamap',{'am','amap'}, ...
    'ambientlightcolor',{'alc','lightcol'}, ...
    'box',{'b'}, 'buttondownfcn',{'bdf','btndown','btnfcn'}, ...
    'children',{'kid','child'}, ...
    'color',{'c','col'}, 'colormap',{'cm','cmap'}, ...
    'colororder',{'co','colord'}, 'colororderindex',{'coi','colordidx'}, ...
    'closerequestfcn',{'close','crf','closefcn'}, 'createfcn',{'cf','cfcn'}, ...
    'currentaxes',{'ca','cax','curax'}, 'currentobject',{'cobj','curobj'},'currentpoint',{'cpt','curpt'}, ...
    'dataaspectratio',{'dar','dataar'}, 'dataaspectratiomode',{'darm','dataarm'}, ...
    'deletefcn',{'df','dfcn','delfcn'}, ...
    'handlevisibility',{'hvis','hdvis'}, ...
    'linestyle',{'ls'}, 'linestyleorder',{'lso','lsord'},'linewidth',{'lw'}, ...
    'keypressfcn',{'kpf','kpfcn','keydown','keypress'}, 'keyreleasefcn',{'krf','krfcn','keyup'}, ...
    'marker',{'mk','mark'}, 'markeredgecolor',{'me','mec','mecol'}, ...
    'nextplot',{'next','np'}, ...
    'outerposition',{'op','outpos'}, 'position',{'p','pos'}, 'size',{'sz'}, ... 
    'userdata',{'usd'}, 'visible',{'vis'}, ...
    'windowbuttondownfcn',{'wbd','wbdf'}, ...
    'xaxislocation',{'xal','xap','xloc'}, 'xtick',{'xt'}, 'xticklabel',{'xtl','xtlbl'}, ...  
    'yaxislocation',{'yal','yap','yloc'}, 'ytick',{'yt'}, 'yticklabel',{'ytl','ytlbl'}, ...  
    'zaxislocation',{'zal','zap','zloc'}, 'ztick',{'zt'}, 'zticklabel',{'ztl','ztlbl'}, ...  
    'xdata',{'x','xd'}, 'ydata',{'y','yd'}, 'zdata',{'z','zd'}, ...
    'xlim',{'xl'}, 'ylim',{'yl'}, 'zlim',{'zl'}, ...
    'zoom',{'zm','scal','scale'}};
%%

function alias = subfcn_basic
%% alias dict of basic hg obj
alias = {'children',{'cld','child'}, 'clipping',{'clip'}, 'color',{'c','col'}, ...
    'box',{'b'}, 'buttondownfcn',{'bdf','bdfcn','btnfcn'}, ...
    'createfcn',{'cfcn'}, 'deletefcn',{'dfcn'}, ...
    'displayname',{'dn','dnm','disp'}, 'handlevisibility',{'hv','hvis'}, ...
    'position',{'p','pos'}, 'type',{'tp'}, ...
    'units',{'u','unit'}, 'userdata',{'usd'}, 'visible',{'vis'}, ...
    'xliminclude',{'xinc'}, 'yliminclude',{'yinc'}, 'zliminclude',{'zinc'}, ...
    'climinclude',{'cinc'}, 'aliminclude',{'ainc'}, ...
    'busyaction',{'ba','bact'}, 'beingdeleted',{'delfcn'}, 'deletefcn',{'df','delfcn'}, ...
    'interruptible',{'itb'}, 'hittest',{'hit'}, 'pickableparts',{'pick'}, ...
    'selected', {'sel'}, 'selectionhighlight',{'selhl'}, ...
    'uicontextmenu',{'ucm','context','menu'}};
%%

function alias = subfcn_figure
%% alias dict of figure
alias = [{'colormap',{'cm','cmap'}, 'alphamap',{'am','amap'}, ...
    'closerequestfcn',{'close','crf','closefcn'}, ...
    'currentaxes',{'ca','cax','curax'}, 'currentobject',{'cobj','curobj'},'currentpoint',{'cpt','curpt'}, ...
    'createfcn',{'cf','cfcn'},'deletefcn',{'df','dfcn','delfcn'}, ...
    'markeredgecolor',{'me','mec','mecol'}, ...
    'name',{'n','nm'}, 'number',{'nb','num'}, 'numbertitle',{'nt','numttl'}, ...
    'innerposition',{'ip','ipos','inpos'}, 'outerposition',{'op','opos','outpos'}, ...
    'paperorientation',{'po','pori'}, 'paperposition',{'pp','ppos'}, 'paperpositionmode',{'ppm'}, ...
    'papersize',{'psz'}, 'papertype',{'pt','ptp'}, 'paperunits',{'pu','punit'}, ...
    'keypressfcn',{'kpf','kpfcn','keydown','keypress'}, 'keyreleasefcn',{'krf','krfcn','keyup'}, ...
    'windowbuttondownfcn',{'wbd','wbdf'}},subfcn_basic];
%%

function alias = subfcn_axes
%% alias dict of axes
alias = [{'colormap',{'cm','cmap'}, 'colororder',{'co','colord'}, 'colororderindex',{'coi'},  ...
    'dataaspectratio',{'dar'}, 'dataaspectratiomode',{'darm'}, ...
    'fontsize',{'fsz'}, 'fontname',{'fnm'}, 'fontweight',{'fw','fwt'}, ...
    'linestyle',{'ls'}, 'linestyleorder',{'lso','lsord'}, 'linewidth',{'lw'}, ...
    'ambientlightcolor',{'alc','light'}, 'nextplot',{'next','np'}, ...
    'currentpoint',{'cp','cpt','curpt'}, 'outerposition',{'op','outpos'}, ...    
    'sortmethod',{'sm','sort'}, ...
    'tickdir',{'tkd','td','tkdir'}, 'ticklength',{'tl','tkl','tklen'}, ...
    'xaxislocation',{'xal','xaloc','xloc'}, ...
    'xtick',{'xt','xtk'}, 'xtickmode',{'xtm'}, 'xticklabel',{'xtl','xtlb','xtklb'}, ...
    'xticklabelmode',{'xtlm','xtlbm','xtklbm'}, 'xticklabelrotation',{'xtr','xtlr','xtlbrot'}, ...  
    'yaxislocation',{'yal','yaloc','yloc'}, ...
    'ytick',{'yt','ytk'}, 'ytickmode',{'ytm'}, 'yticklabel',{'ytl','ytlb','ytklb'}, ...
    'yticklabelmode',{'ytlm','ytlbm','ytklbm'}, 'yticklabelrotation',{'ytr','ytlr','ytlbrot'}, ...   
    'zaxislocation',{'zal','zaxloc','zloc'}, ...
    'ztick',{'zt','ztk'}, 'ztickmode',{'ztm'}, 'zticklabel',{'ztl','ztlb','ztklb'}, ...
    'zticklabelmode',{'ztlm','ztlbm','ztklbm'}, 'zticklabelrotation',{'ztr','ztlr','ztlbrot'}, ...
    'xminortick',{'xmt'}, 'xminortickmode',{'xmtm'}, ...
    'yminortick',{'ymt'}, 'yminortickmode',{'ymtm'}, ...
    'xlim',{'xl'}, 'ylim',{'yl'}, 'zlim',{'zl'}, ...
    'xlimmode',{'xlm'}, 'ylimmode',{'ylm'}, 'zlimmode',{'zlm'} ...
    'xscale',{'xs','xsc'}, 'yscale',{'ys','ysc'}, 'zscale',{'zs','zsc'}, ...
    'xcolor',{'xc','xcol'}, 'ycolor',{'yc','ycol'}, 'zcolor',{'zc','zcol'}, ...
    'xaxis',{'xax'}, 'yaxis',{'yax'}, 'zaxis',{'zax'}, ...
    'xgrid',{'xg'}, 'ygrid',{'yg'}, 'zgrid',{'zg'}, ...
    'gridalpha',{'ga'}, 'gridalphamode',{'gam'}, ...
    'gridcolor',{'gc'}, 'gridcolormode',{'gcm'}, ...    
    'gridlinestyle',{'gls'}, 'minorgridlinestyle',{'mgls'}, ...
    'xminorgrid',{'xmg'}, 'yminorgrid',{'ymg'}, 'zminorgrid',{'zmg'}, ...
    'minorgridalpha',{'mga'}, 'minorgridalphamode',{'mgam'}, ...
    'minorgridcolor',{'mgc'}, 'minorgridcolormode',{'mgcm'}, ...
    }, ...
    subfcn_basic];
%%

function alias = subfcn_legend
%% alias dict of legend
alias = [{'autoupdate',{'au'}, 'edgecolor',{'ec','ecol'}, 'fontangle',{'fa'}, ...
    'interpreter',{'i','it','int'}, 'itemhitfcn',{'ihf'}, 'linewidth',{'lw'}, ...
    'location',{'l','loc'}, ...
    'numcolumns',{'nc','ncol'}, 'numcolumnsmode',{'ncm','ncolmode'}, ...
    'orientation',{'o','ori'}, 'string',{'s','str'}, ...
    'title',{'t','ttl'}, 'textcolor',{'tc','tcol'}}, ...
    subfcn_axes];
%%

function alias = subfcn_line
%% alias dict of line-type objs
alias = [{'xdata',{'x','xd'}, 'ydata',{'y','yd'}, 'zdata',{'z','zd'}, ...
    'displayname',{'dnm','name'}, ...
    'linestyle',{'ls'}, 'linewidth',{'lw'}, ...
    'marker',{'m','mk'}, 'markersize',{'msz','mksz','sz'}, ...
    'markerfacecolor',{'mfc'}, 'markeredgecolor',{'mec'},...
    'parent',{'ax','axes'}}, subfcn_basic];
%%

function alias = subfcn_scatter
%% alias dict of scatter-type objs
alias = [{'cdata',{'cd','c','col'}, 'sizedata',{'sz','sd','msz'}, ...
    'markeredgealpha',{'ea','mea'}, 'markerfacealpha',{'a','fa','mfa'}},  ...
    subfcn_reject(subfcn_line,'color','markersize')];
%%

function alias = subfcn_img
%% alias dict of image-type objs
alias = [{'xdata',{'x','xd'}, 'ydata',{'y','yd'}, ...
    'cdata',{'cd'}, 'cdatamapping',{'cdm','cdmap'}, ...
    'alphadata',{'a','ad','alpha'}, 'alphadatamapping',{'adm','alphamap'}}, ...
    subfcn_basic];
%%
    
function alias = subfcn_patch
%% alias dict of patch-type objs
alias = [{'cdata',{'cd'}, 'cdatamapping',{'cdm','cdmap'}, ...
    'alphadatamapping',{'adm','admap'}, 'edgealpha',{'ea','ealpha'}, 'edgecolor',{'ec','ecol'}, ...
    'facealpha',{'fa','falpha'}, 'facecolor',{'c','col','fc'}, ...
    'edgelighting',{'el','elight'}, 'facelighting',{'fl','flight'}}, ...
    subfcn_reject(subfcn_line,'color','markerfacecolor','markeredgecolor')];
%%

function alias = subfcn_quiver
%% alias dict of quiver-type objs
alias = [{'udata',{'u','ud'}, 'vdata',{'v','vd'}, 'wdata',{'w','wd'}, ...
    'autoscale',{'as','asc'}, 'autoscalefactor',{'asf'},  ...
    'showarrowhead',{'arrow','sah'}, 'maxheadsize',{'mhsz'}}, ...
    subfcn_line];
%%

function alias = subfcn_surf
%% alias dict of surface-type objs
alias = [{'cdata',{'cd'}, 'cdatamapping',{'cdm','cdmap'}, ...
    'alphadata',{'a','ad','alpha'}, 'alphadatamapping',{'adm','alphamap'}, ...
    'edgealpha',{'ea','ealpha'}, 'edgecolor',{'ec','ecolor'}, ...
    'facealpha',{'fa','falpha'}, 'facecolor',{'fc','fcolor'}, ...
    'meshstyle',{'ms','mesh','mstyle'}},subfcn_line];
%%
    
function alias = subfcn_boxchart
%% alias dict of surface-type objs
alias = [{'boxfacealpha',{'fa','bfa'}, 'boxfacecolor',{'fc','bfc'}, ...
    'boxfacecolormode',{'fcm','bfcm'}, 'boxwidth',{'bw'}, ...
    'jitteroutliers',{'jo'}, 'linewidth',{'lw'}, ...
    'markercolor',{'mc'}, 'markercolormode',{'mcm'}, ...
    'markersize',{'msz'}, 'markerstyle',{'mk','mst'}, ...
    'notch',{'nt'}, 'orientation',{'ori'}, 'seriesindex',{'si'}, ...
    'whiskerlinecolor',{'wlc','lc'}, 'whiskerlinestyle',{'wls','ls'}, ...
    'xdata',{'xd'}, 'ydata',{'yd'}},subfcn_basic];
%%

function alias = subfcn_text
%% alias dict of text-type objs
alias = [{'backgroundcolor',{'bgc','bgcol'}, 'edgecolor',{'ec','ecol'}, ...
    'string',{'s','str'}, 'fontangle',{'fa','fang'}, ...
    'fontsize',{'fsz','sz','fsize'}, 'fontname',{'fnm','nm','font','fname'}, ...
    'fontweight',{'fw','wt','fwt'}, 'rotation',{'r','rot'}, 'interpreter',{'i','it','int','itp'}, ...  
    'linewidth',{'lw'}, 'linestyle',{'ls'}, 'margin',{'mg'}, 'parent',{'ax','axes'}, ...
    'horizontalalignment',{'ha','halign'}, 'verticalalignment',{'va','valign'}}, ...
    subfcn_basic];
%%

function alias = subfcn_cbar
%% alias dict of colorbar
alias = [{'axislocation',{'al','axl','axloc'}, 'axislocationmode',{'alm','almode'}, ...
    'direction',{'dir'}, ...
    'fontangle',{'fa','fang'},'fontsize',{'fsz','ftsz'}, 'fontname',{'fnm','font','fname'}, ...
    'fontweight',{'fw','fwt'}, 'limits',{'li','lim'}, 'limitsmode',{'lm','lmm','lmode'}, ...
    'linewidth',{'lw'}, 'location',{'loc'}, 'parent',{'hf','hfig'}, ...  
    'ticks',{'tk','tks'}, 'ticklength',{'tlen','tklen'}, ...
    'ticklabels',{'tl','tkl','tklb'}, 'ticklabelsmode',{'tlm','tklm','tklbm'}, ...
    'tickdirection',{'tkd','tdir','tkdir'}, 'ticks',{'tk'}, 'ticksmode',{'tm','tkm'}}, ...
    subfcn_basic];
%% EOF
