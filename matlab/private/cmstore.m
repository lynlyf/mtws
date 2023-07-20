function varargout = cmstore(n,name)
%% a collection of colormaps
% usages:
%   cmap = cmstore([n,]name); % colormap shortcut name
%   cmstore(ha,name); % apply a colormap to an axes
%   cmstore('demo') % view examples
%   cmstore('list|view') % list all colormaps
%
% builtin matlab colormaps: matlabroot/help/matlab/ref/colormap_<name>.png
%
% n: [], the same ncolor as current figure colormap
%    >0, number of colors in colormap
%    0|nan, return key colors only
%    <0, reverse colormap
% name: shortcut of colormap
%
% sequential: b, blue; c, cyon; g, green; k, gray; m, mageta; o, orange;
%             r, red; v, voilet; w, gray; y, yellow
%
% see also: brewermap, cmexpand, cmocean, cptcmap, cubehelix, hslcolormap,
%           setcmap, rgb, cssname2rgb, colornames
%%
if nargin==1 && ischar(n), [n,name] = deal(64,n); end
if ~exist('n','var') || isempty(n), n = cmnumber; end
if ~exist('name','var') || isempty(name), name = 'vjetng'; end

if isscalar(n)
    if ~isnumeric(n) && ishghandle(n)
        colormap(n,cmstore(name));
        return;
    end
    if ismember('-',name)
        cmap = cminterp(n,name);
    else
        cmap = subfcn_base(name,abs(n));
    end
else % use `cminterp(n,'colors',grays)` for transitions between colors
    cmap = abs(n(:)) * mean(cminterp(length(name),name),1);
    cmap(cmap>1) = 1;
end

if isempty(cmap)
    switch(lower(name))
        case {'demo','example'}
            subfcn_demo('all');
            return;
        case {'get','list','view'}
            opts = subfcn_opts('all');        
            fprintf(' -- %d valid options --\n%s\n ------\n', ...
                length(opts),strcon(', ',opts{:})); 
            return;
        otherwise
            opts = subfcn_opts(name);
            if isempty(opts)
                %verb(1,'**WARNING: Unknown colormap shortcut ', ...
                %     name,'; return defaults**');
                cmap = cmstore(linspace(0.05,1,abs(n)),name);
            else
                subfcn_demo(name);
                return;
            end
    end
end

if n<0, cmap = cmap(end:-1:1,:); end

if nargout == 0
    ha = gchg('ax');
    if ~isempty(ha)
        colormap(ha,cmap);
        return;
    end
end
varargout = {cmap};
%%

%% SUBFUNCTIONS
function opts = subfcn_opts(group)
%% options
if nargin==0, group = 'all'; end
% option groups
opts_vivid = {'sea','land','topo','rainbow','spec','specng','specv', ...
    'kspec','wspec','kspecw','specw','spectral','cb', ...
    'jetw','jetwng','vjet','vjetng', ...
    'wjet','wjetk','wjetk','wjetng','wvjet','wvjetng', ...
    'djet','djetng','djetwng','djetw','haxby','khaxby', ...
    'kjet','kjetng','kvjetw','kvjetng','kjetwng','kvjetwng','kmjetng', ...
}; % vivid
opts_circ = {'hsv','cspec','cspecng','cjetng','cjet','phase','ltph'}; % circular
opts_scatter = {'ls','lc','abc'}; % line colors
opts_seq = {'blue','cyan','green','magenta','orange','red', ...
    'violet','yellow','light','dark','cool','cold','vcold', ...
    'warm','hot','vhot'}; % sequential
opts_div = {'bcwor','bcwyr','bwr','bwo','byr','ckg','lb','lbly','lblr', ...
    'sbfb','dkbr','dkbwr','dkb2r','esa','bluebrown','brwbg','grayblue', ...
    'fireice'}; % diverging
switch(lower(group))
    case {'vv','vivid'}
        opts = opts_vivid;
    case {'cc','circ','circular'}
        opts = opts_circ;
    case {'sc','scatter'}
        opts = opts_scatter;
    case {'seq','linear'}
        opts = opts_seq;
    case {'div','diverging'}
        opts = opts_div;
    case {'all'}        
        opts = [opts_vivid,opts_scatter,opts_circ,opts_seq,opts_div];
    otherwise
        opts = [];
end
%%

function cmap = subfcn_base(name,n)
%% return a colormap [r,g,b]
switch(lower(name))
    %% scattered
    case {'ls','line'} % distinguishable colors for lines
        cmap = [0.30 0.55 0.75; 1.00 0.55 0.10; 0.37 0.72 0.36;
                0.90 0.50 0.70; 0.55 0.55 0.55; 0.90 0.20 0.20; 
                0.80 0.80 0.40; 0.70 0.40 0.25; 0.60 0.35 0.65];
        if abs(n)>0, n = size(cmap,1); end
    case {'lc'} % line color set
        cmap = [0.33 0.33 0.33; 0.90 0.15 0.15; 0.00 0.60 0.80;
                0.95 0.48 0.13; 0.35 0.70 0.30; 0.86 0.20 0.57; 
                0.82 0.41 0.11; 0.85 0.05 0.00; 1.00 0.78 0.11;
                0.44 0.86 0.98; 1.00 0.38 0.27; 0.50 1.00 0.00;                 
                0.95 0.65 0.12; 0.66 0.66 0.66; 0.35 0.18 0.55; 
                1.00 0.50 0.30; 0.12 0.70 0.67; 0.15 0.20 0.55; 
                0.18 0.54 0.34; 0.26 0.77 0.95; 1.00 0.55 0.10;                 
                0.75 0.75 0.75; 0.20 0.40 0.70; 1.00 0.27 0.00;
                1.00 1.00 0.51; 1.00 0.50 0.00; 0.67 1.00 0.18]; 
        if abs(n)>0, n = size(cmap,1); end
    case {'abc','az','char'} % char(97:122) <-> a...z
        cmap = cminterp(26,'abcdefghijklmnopqrstuvwxyz');
        if abs(n)>0, n = size(cmap,1); end
    %% vivid
    case {'sea','land','sealand'} % topography
        cmap = sealand(abs(n),name);
    case {'topo'} % topography
        cmap = sealand(abs(n),'sealand');
    case {'rb','rainbow'} % rainbow (violet-indigo-blue-green-yellow-orange-red)
        cmap = [0.58 0 0.83; 0.3 0.0 0.5; 0.0 0.0 1.0; 0.0 1.0 0.0; 
                1.0 1.0 0.0; 1.0 0.5 0.0; 1.0 0.0 0.0]; 
    case {'krbw'} % black-rainbow-white
        cmap = [0.0 0.0 0.0; 0.3 0.0 0.5; 0.58 0.0 0.83; 0.0 0 1.0;
                0.0 1.0 1.0; 0.0 1.0 0.0; 1.0 1.0 0.0; 1.0 0.0 0.0; 
                1.0 0.5 0.0; 0.6 0.3 0.2; 1.0 0.95 0.95];
    case {'spectral'} % similar to brewermap
        cmap = [0.33 0.20 0.60; 0.20 0.53 0.74; 0.40 0.76 0.65;
                0.67 0.87 0.64; 0.90 0.96 0.60; 1.00 1.00 0.75; 
                1.00 0.88 0.55; 0.99 0.68 0.38; ...
                0.96 0.43 0.26; 0.84 0.24 0.31; 0.62 0.00 0.26];
    case {'cb','brewer','colorbrewer'} % similar to spectral
        % with lighter blue and darker red
        cmap = [0.37 0.31 0.64; 0.31 0.70 0.67; 0.76 0.91 0.63;
                0.95 0.95 0.71; 0.99 0.76 0.43; 0.93 0.36 0.27; 
                0.40 0.00 0.06];
    case {'spec','spectrum','rygcbm'} % visible light spectrum, rygcbm
        cmap = [1.0 0.0 0.0; 1.0 1.0 0.0; 0.0 1.0 0.0; 0.0 1.0 1.0;
                0.0 0.0 1.0; 1.0 0.0 1];
    case {'specng'} % rycbm; reduce green colors
        cmap = [1.0 0.0 0.0; 1.0 1.0 0.0; 0.0 1.0 1.0; 0.0 0 1.0;
                1.0 0.0 1];
    case {'specv','specgr'} % a variation of spec with deeper gray
        cmap = [0.75 0.25 0.0; 1.0 0.75 0.0; 0.25 1.0 0.5; 0.0 0.75 1.0;
                0.5 0.25 1.0; 0.75 0.0 1];
    case {'kspec'} % krygcbm
        cmap = [0.0 0.0 0.0; cmstore(6,'specv')];
    case {'wspec'} % wrygcbm
        cmap = [1,1,1; cmstore(6,'specv')];
    case {'specw'} % rygcbmw
        cmap = [cmstore(6,'specv'); 1.0 1.0 1];
    case {'speck'} % rygcbmk
        cmap = [cmstore(6,'specv'); 0.0 0 0.0];
    case {'wspeck'} % wrygcbmk
        cmap = [1.0 1.0 1.0; cmstore(6,'specv'); 0.0 0 0.0];
    case {'kspecw'} % krygcbmw
        cmap = [0.0 0.0 0.0; cmstore(6,'specv'); 1.0 1.0 1];
    case {'haxby','ltjetw'} % light jet-white
        cmap = [0.0 0.2 0.8; 0.2 0.5 1.0; 0.2 0.7 1.0; 0.4 0.9 1.0;      
                0.5 0.9 0.7; 0.8 1.0 0.6; 0.9 0.9 0.5; 1.0 0.6 0.3;
                1.0 0.7 0.5; 1.0 0.95 0.95];
    case {'khaxby'} % black-haxby
        cmap = [0.0 0.0 0.0; 0.0 0.2 0.8; 0.2 0.5 1.0; 0.2 0.7 1.0;            
                0.4 0.9 1.0; 0.5 0.9 0.7; 0.8 1.0 0.6; 0.9 0.9 0.5;
                1.0 0.6 0.3; 1.0 0.7 0.5; 1.0 0.95 0.95];
    case {'wjet'} % white-jet
        cmap = subfcn_wjet(n);
    case {'mjet'} % magenta-jet
        cmap = [0.494 0.184 0.556; 0.000 0.447 0.741; 0.301 0.745 0.933;
                0.466 0.674 0.188; 0.929 0.694 0.125; 0.850 0.325 0.098;
                0.635 0.078 0.184];
    case {'mjetng'} % magenta-jetng
        cmap = [0.9 0.2 0.7; 0.0 0.5 0.7; 0.3 0.7 1.0; 0.5 1.0 1.0;
                1.0 1.0 0.5; 1.0 0.5 0.2; 1.0 0.0 0.0; 0.5 0.0 0.0];
    case {'vjet'} % violet-jet
        cmap = [0.5 0.0 1.0; 0.3 0.5 0.8; 0.0 0.8 0.8; 0.5 0.8 0.5; 
                0.8 0.9 0.3; 1.0 1.0 0.2; 1.0 0.5 0.0; 1.0 0.0 0.0; 
                0.5 0.0 0.0];
    case {'vjetng'} % violet-jetng; default cmap
        cmap = [0.5 0.1 1.0; 0.2 0.5 1.0; 0.3 0.7 1.0; 0.5 1.0 1.0;
                1.0 1.0 0.5; 1.0 0.5 0.2; 1.0 0.0 0.0; 0.5 0.0 0.0];
    case {'wjetk'} % white-jet-black
        cmap = [1.0 1.0 1.0; 0.5 0.0 1.0; 0.3 0.5 0.8; 0.2 0.8 0.8;
                0.8 0.7 0.5; 1.0 0.5 0.0; 0.7 0.2 0.0; 0.3 0.0 0.0];
    case {'wjetng'} % white-jetng
        cmap = [1.0 1.0 1.0; 0.2 0.5 1.0; 0.3 0.7 1.0; 0.5 1.0 1.0;
                1.0 1.0 0.5; 1.0 0.5 0.2; 1.0 0.0 0.0; 0.5 0.0 0.0];
    case {'wvjet'} % white-violet-jet
        cmap = [1.0 1.0 1.0; 0.5 0.0 1.0; 0.3 0.5 0.8; 0.0 0.8 0.8; 
                0.5 0.8 0.5; 0.8 0.9 0.3; 1.0 1.0 0.2; 1.0 0.5 0.0;
                1.0 0.0 0.0; 0.5 0.0 0.0];
    case {'wmjet'} % white-magenta-jet
        cmap = [1.0 1.0 1.0; 1.0 0.0 1.0; 0.5 0.0 1.0; 0.0 0.5 1.0;
                0.0 1.0 1.0; 0.5 1.0 0.5; 1.0 1.0 0.5; 1.0 0.5 0.0;
                1.0 0.0 0.0; 0.5 0.0 0.0];
    case {'wvjetng'} % white-violet-jet_no_green
        cmap = [1.0 1.0 1.0; 0.5 0.0 1.0; 0.2 0.5 1.0; 0.2 0.7 1.0;
                0.5 1.0 1.0; 1.0 1.0 0.5; 1.0 0.5 0.0; 1.0 0.0 0.0;
                0.5 0.0 0.0];
    case {'wmjetng'} % white-magenta-jet_no_green
        cmap = [1.0 1.0 1.0; 1.0 0.0 1.0; 0.5 0.0 1.0; 0.0 0.5 1.0;
                0.0 1.0 1.0; 
                1.0 1.0 0.5; 1.0 0.5 0.0; 1.0 0.0 0.0; 0.5 0.0 0.0];
    case {'kjet'} % black-jet
        cmap = [0.0 0.0 0.0; 0.2 0.5 0.8; 0.3 0.7 1.0; 0.0 0.8 0.8;
                0.5 0.8 0.5; 0.8 0.9 0.3; 1.0 0.5 0.0; 1.0 0.0 0.0;
                0.5 0.0 0.0];
    case {'kjetng'} % black-jetng
        cmap = [0.0 0.0 0.0; 0.3 0.5 0.8; 0.0 0.8 0.8; 0.5 1.0 1.0; 
                0.8 1.0 0.5; 1.0 1.0 0.5; 1.0 0.6 0.0; 1.0 0.5 0.5];
    case {'kvjetng'} % black-violet-jet_no_green
        cmap = [0.0 0.0 0.0; 0.5 0.0 1.0; 0.2 0.5 1.0; 0.2 0.7 1.0; 
                0.5 1.0 1.0; 1.0 1.0 0.5; 1.0 0.5 0.0; 1.0 0.0 0.0;
                0.5 0.0 0.0];
    case {'kvjetwng','kvjetngw'} % black-violet-jetng-white
        cmap = [0.0 0.0 0.0; 0.5 0.0 1.0; 0.2 0.5 1.0; 0.2 0.7 1.0; 
                0.5 1.0 1.0; 1.0 1.0 0.5; 1.0 0.5 0.0; 1.0 0.5 0.5;
                1.0 0.95 0.95];
    case {'kmjetng'} % black-magenta-jet_no_green
        cmap = [0.0 0.0 0.0; 1.0 0.0 1.0; 1.0 0.5 1.0; 0.5 0.5 1.0; 
                0.5 1.0 1.0; 1.0 1.0 0.5; 1.0 0.5 0.0; 1.0 0.0 0.0;
                0.5 0.0 0.0];
    case {'kjetwng'} % black-jetng-white 
        cmap = [0.0 0.0 0.0; 0.3 0.5 0.8; 0.0 0.8 0.8; 0.5 1.0 1.0; 
                0.8 1.0 0.5; 1.0 1.0 0.5; 1.0 0.6 0.0; 1.0 0.5 0.5;
                1.0 0.95 0.95];
    case {'kjetw'} % black-jet-white
        cmap = [0.0 0.0 0.0; 0.3 0.5 0.8; 0.0 0.8 0.8; 0.1 0.8 0.5;
                0.5 0.8 0.5; 0.8 0.9 0.3; 1.0 1.0 0.2; 1.0 0.5 0.0;
                1.0 0.5 0.5; 1.0 0.95 0.95];
    case {'kvjetw'} % black-violet-jet-white
        cmap = [0.0 0.0 0.0; 0.5 0.0 1.0; 0.3 0.5 0.8; 0.0 0.8 0.8;
                0.5 0.8 0.5; 0.8 0.9 0.3; 0.9 0.9 0.5; 1.0 0.5 0.2;
                1.0 0.2 0.3; 1.0 0.95 0.95];
    case {'jetw'} % jet-white
        cmap = [0.3 0.5 0.8; 0.0 0.8 0.8; 0.5 0.8 0.5; 0.8 0.9 0.3; 
                0.9 0.9 0.5; 1.0 0.5 0.2; 1.0 0.2 0.3; 1.0 0.95 0.95];
    case {'jetwng','lbjetwng'} % lightblue-jetng-white
        cmap = [0.3 0.5 0.8; 0.0 0.8 0.8; 0.5 1.0 1.0; 
                0.9 0.9 0.5; 1.0 0.5 0.2; 1.0 0.2 0.3; 1.0 0.95 0.95];
    case {'djetw','dbjetw'} % darkblue-jet-white
        cmap = [0.0 0.1 0.2; 0.3 0.5 0.8; 0.0 0.8 0.8; 0.5 0.8 0.5; 
                0.8 0.9 0.3; 0.9 0.9 0.5; 1.0 0.5 0.2; 1.0 0.2 0.3;
                1.0 0.95 0.95];
    case {'djetwng','dbjetwng'} % darkblue-jetng-white
        cmap = [0.0 0.15 0.3; 0.3 0.5 0.8; 0.0 0.8 0.8; 0.5 1.0 1.0; 
                1.0 0.9 0.6; 1.0 0.5 0.3; 0.9 0.2 0.0; 1.0 0.95 0.95];
    case {'djetng','dbjetng'} % darkblue-jetng-darkred
        cmap = [0.0 0.2 0.5; 0.3 0.5 0.8; 0.0 0.8 0.8; 0.5 1.0 1.0; 
                0.9 0.9 0.5; 1.0 0.5 0.2; 1.0 0.2 0.3; 0.5 0.1 0.0];
    case {'djet','dbjet'} % darkblue-jet-darkred
        cmap = [0.0 0.1 0.2; 0.3 0.5 0.8; 0.0 0.8 0.8; 0.0 1.0 0.5; 
                0.5 1.0 0.4; 1.0 1.0 0.3; 1.0 0.6 0.0; 1.0 0.2 0.0;
                0.5 0.1 0.0];
    case {'djetm'} % darkblue-jet-darkred-magnet
        cmap = [0.0 0.1 0.2; 0.3 0.5 0.8; 0.0 0.8 0.8; 0.0 1.0 0.5; 
                0.5 1.0 0.4; 1.0 1.0 0.3; 1.0 0.6 0.0; 1.0 0.2 0.0;
                0.5 0.1 0.0; 1.0 0.1 1.0; 1.0 0.8 1.0];
    %% circular
    case {'hsv'} % circular;
        cmap = [1.0 0.0 0.0; 0.75 0.75 0.0; 0.25 0.5 0.25; 0.0 0.5 1.0;
                0.0 0.25 1.0; 0.75 0.0 0.75; 1.0 0.0 0.0];
    case {'cspec','circspec'} % rygcbmr; hslcolormap([0,1],1,0.5)
        cmap = [1.0 0.0 0.0; 1.0 1.0 0.0; 0.0 1.0 0.0; 0.0 1.0 1.0;
                0.0 0 1.0; 1.0 0.0 1.0; 1.0 0.0 0.0];
    case {'cspecng','circspecng'} % rycbmr
        cmap = [1.0 0.0 0.0; 1.0 1.0 0.0; 0.0 1.0 1.0; 0.0 0 1.0;
                1.0 0.0 1.0; 1.0 0.0 0.0];
    case {'cjetng'} % circular jetng; red-purple-jet
        cmap = [0.8 0.0 0.0; 0.6 0.1 0.7; 0.3 0.5 1.0; 0.5 1.0 1.0;
                1.0 1.0 0.5; 1.0 0.5 0.0; 1.0 0.0 0.0; 0.79 0.0 0.0];
    case {'cjet'} % circular jet (red-pink-jet); too many red colors
        cmap = [1.0 0.0 0.01; 1.0 0.0 0.5; 1.0 0.0 1.0; 0.5 0.5 1.0;
                0.0 1.0 1.0; 0.5 1.0 0.5; 1.0 1.0 0.0; 1.0 0.5 0.0;
                1.0 0.0 0.0];
    case {'ph','phase','phasemap'} % circular;
        cmap = [0.9 0.4 0.4; 0.6 0.3 0.8; 0.2 0.6 0.9; 0.0 0.7 0.6; 
                0.4 0.7 0.2; 0.8 0.6 0.0; 0.9 0.4 0.4];
    case {'ltph','lightphase','lightphasemap'} % circular; light colors
        cmap = [1.0 0.4 0.4; 0.8 0.5 0.7; 0.3 0.6 1.0; 0.2 0.8 0.6; 
                0.6 0.6 0.3; 0.9 0.3 0.2; 1.0 0.4 0.4];
    %% sequential
    case {'cool'} % blue-cyan-lightgreen
        cmap = [0.0 0.0 1.0; 0.0 0.5 1.0; 0.2 1.0 0.8; 0.5 1.0 0.7];
    case {'cold'} % black-blue-cyan-white
        cmap = [0.0 0.0 0.05; 0.0 0.25 0.95; 0.0 0.95 1.0; 0.95 0.95 1];
    case {'vcold'} % cold with variable limits
        cmap = subfcn_cold(abs(n));
    case {'warm'} % yellow-orange-red
        cmap = [1.0 0.0 0.0; 1.0 0.5 0.0; 1.0 1.0 0.5; 1.0 1.0 0.8];
    case {'hot'} % balck-red-yellow-white
        cmap = [0.05 0.0 0.0; 0.95 0.25 0.0; 1.0 0.95 0.0; 1.0 0.95 0.95];
    case {'vhot'} % hot with variable limits
        cmap = subfcn_hot(abs(n));
    case {'lb','lightblue'} % Light-Bertlein colormap Blue
        cmap = [0 0.48 0.75; 0 0.56 0.8; 0.14 0.62 0.84; 0.45 0.71 0.88; 
                0.67 0.82 0.93; 0.88 0.91 0.94; 0.95 0.96 0.97];
    case {'b','blue'} % Black-Blue-White
        cmap = [0.0 0.0 0.05; 0.0 0.6 0.95; 0.85 1.0 1];
    case {'c','cyan'} % black-cyan-white
        cmap = [0.0 0.05 0.05; 0.05 0.75 0.7; 0.95 1.0 1];
    case {'g','green'} % black-green-cyan-white
        cmap = [0 0.05 0; 0.0 0.45 0.05; 0.25 1.0 0.25; 0.95 1.0 0.95];
    case {'k','dark'} % white-darkgray
        cmap = [1.0 1.0 1.0; [1,1,1]*0.1];
    case {'m','magenta'} % black-magenta-white
        cmap = [0.05 0.0 0.05; 1.0 0.1 1.0; 1.0 0.95 1.0];
    case {'o','orange'} % black-orange-white
        cmap = [0.05 0.02 0.0; 0.95 0.45 0.2; 1.0 0.95 0.9];
    case {'r','red'} % Black-MidRed-LightYellow
        cmap = [0.05 0.0 0.0; 1.0 0.3 0.3; 1.0 1.0 0.85];
    case {'v','violet'} % black-violet-white
        cmap = [0.03 0.0 0.05; 0.75 0.2 0.95; 0.95 0.85 1];
    case {'w','light'} % black-lightgray
        cmap = [0.0 0.0 0.0; [1,1,1]*0.95];
    case {'y','yellow'} % black-yellow-white
        cmap = [0.05 0.03 0.0; 0.8 0.5 0.0; 1.0 0.95 0.85];
    %% diverging 
    case {'grbu','grayblue','bluegray'} % Light-Bertlein colormap BlueGray
        cmap = [0.25 0.31 0.32; 0.43 0.48 0.51; 0.57 0.63 0.67; 0.85 0.9 0.9;
                0.75 0.9 0.95; 0.5 0.8 0.9; 0.2 0.77 0.93; 0.0 0.7 0.9];
    case {'bubr','bluebrown'} % Light-Bertlein colormap BlueBrown
        cmap = [0.09 0.31 0.64; 0.27 0.39 0.68; 0.43 0.6 0.81; 
                0.63 0.75 0.88; 0.81 0.89 0.94; 0.95 0.96 0.96;
                0.96 0.85 0.78; 0.97 0.72 0.55; 
                0.88 0.57 0.25; 0.73 0.47 0.21; 0.56 0.39 0.17];
    case {'burd','bluered'} % Light-Bertlein colormap BlueRed
        cmap = [0.0 0.45 0.74; 0.0 0.67 0.9; 0.27 0.78 0.94;
                0.6 0.85 0.93; 0.85 0.93 0.95; 0.95 0.93 0.77; 
                0.98 0.85 0.66; 0.96 0.7 0.55; 
                0.94 0.52 0.48; 0.85 0.32 0.35; 0.7 0.2 0.3];
    case {'lbly'} % lightblue-white-lightyellow
        cmap = [0.12 0.64 0.88; 1.0 1.0 1.0; 0.9 0.8 0.5];
    case {'lblr'} % dodgerblue-white-coral
        cmap = [0.12 0.6 1.0; 1.0 1.0 1.0; 1.0 0.5 0.3];
    case {'sbfb','gbgr'} % steelblue-w-firebrick
        cmap = [0.27 0.51 0.7;1 1.0 1.0;0.7 0.13 0.13];       
    case {'brwbg','br-w-bg'} % brown-white-bluegreen; light bwr
        cmap = [0.33 0.2 0.0; 1.0 1.0 1.0; 0.0 0.2 0.2];
    case {'ckg'} % cyan-black-green
        cmap = [0.0 0.8 1.0; 0.0 0.3 0.7; 0.0 0 0.0; 0.3 0.6 0.0; 0.7 1.0 0.0];
    case {'fireice','cbkry'} % cyan-blue-black-red-yellow
        % equivalent to cmstore('c-b-k-r-y')
        cmap = [0.0 1.0 1.0; 0.0 0 1.0; 0.0 0 0.0; 1.0 0.0 0.0; 1.0 1.0 0.0];
    case {'b2r','bwr'} % blue-white-red
        cmap = [0.0 0.0 0.5; 0.0 0.38 0.83; 1.0 1.0 1.0;
                0.83 0.38 0.0; 0.5 0.0 0.0];
    case {'byr'} % blue-yellow-red; similar to burd  
        cmap = [0.00 0.45 0.74; 0.00 0.67 0.89; 0.27 0.78 0.94; 
                0.60 0.85 0.93; 0.85 0.93 0.95; 0.95 0.93 0.77;
                0.98 0.85 0.66; 0.96 0.69 0.55;
                0.94 0.52 0.48; 0.85 0.32 0.35; 0.69 0.21 0.28];
    case {'dkbwr'} % darkblue-blue-white-red-darkred; high saturation colors
        cmap = [0.03 0.0 0.2; 0.045 0.065 1.0; 1.0 1.0 1.0;
                1.0 0.065 0.045; 0.2 0.0 0.03];
    case {'dkb2r','dkbcwor'} % darkblue-cyan-orangered-darkred
        % with more bright red than dkbr
        cmap = [0.0 0.0 0.3; 0.02 0.7 1.0; 0.3 0.9 1.0; 0.8 1.0 0.9; 
                1.0 1.0 1.0; 1.0 0.9 0.8; 1.0 0.6 0.2; 0.9 0.2 0.02;
                0.3 0.0 0.0];
    case {'dkbr','dkbcor'} % darkblue-cyan-gray-orangered-darkred
        % with linearly up/down gray gradients
        cmap = [0.0 0.2 0.3; 0.22 0.46 0.65; 0.48 0.71 0.91; 
                0.73 0.97 1.0; 1.0 1.0 1.0; 1.0 0.89 0.62; 
                1.0 0.54 0.27; 0.91 0.18 0.0; 0.3 0.1 0.0];
    case {'bcwor'} % steelblue-cyan-white-orangered-darkred
        % almost the same as dkb2r
        cmap = [0.0 0.2 0.4; 0.2 0.5 0.6; 0.5 0.7 0.9; 0.7 0.9 1.0; 
                1.0 1.0 1.0; 1.0 0.9 0.6; 1.0 0.6 0.3; 0.9 0.2 0.0; 
                0.5 0.1 0.0];
    case {'bcwyr'} % darkblue-cyan-white-yellow-darkred
        cmap = [0.0 0.2 0.4; 0.2 0.5 0.6; 0.3 0.9 1.0; 1.0 1.0 1.0; 
                1.0 0.9 0.3; 0.9 0.2 0.0; 0.5 0.1 0.0];
    case {'bwo'} % blue-white-orange; similar to esa
        cmap = [0.0 0.44 1.0; 1.0 1.0 1.0; 1.0 0.44 0.0];
    case {'byo'} % blue-yello-orange
        cmap = [0.0 0.44 1.0; 0.97 0.92 0.90; 1.0 0.44 0.0];
    case {'esa','bwyo','ltbyr'} % blue-white-yellow-orange
        cmap = [0.46 0.47 1.0; 0.71 0.74 0.93; 1.0 1.0 1.0; 
                1.0 0.75 0.16; 1.0 0.37 0.16];
    otherwise
        cmap = [];
end

if isempty(cmap) || isnan(n) || n==0
    return;
end

m = size(cmap,1);
cmap = interp1(1:m,cmap,linspace(1,m,abs(n)));
%%

function cmap = subfcn_wjet(m)
%% white-jet
if isnan(m), m = 12; end
cmap = jet(max(12,m));
n = find(cmap(:,3)==1,1) - 1.0;
cmap(1:n,1:2) = repmat((n:-1:1)'/n, [1.0 2]);
cmap(1:n,3) = 1.0;
%%

function cmap = subfcn_cold(m)
%% black-blue-cyan-white
% Example:
%   > imagesc(peaks(500)); cmstore('cold'); colorbar
%   > load topo; imagesc(0:360,-90:90,topo); axis xy; cmstore('cold');
% See also: hot, cool, jet, hsv, gray, copper, bone, vivid
%%
if isnan(m), m = 4; end
n = fix(3/8*m);
r = [zeros(2*n,1); (1:m-2*n)'/(m-2*n)];
g = [zeros(n,1); (1:n)'/n; ones(m-2*n,1)];
b = [(1:n)'/n; ones(m-n,1)];
cmap = [r g b];
%%

function cmap = subfcn_hot(m)
%% black-rd-yelow-white 
if isnan(m), m = 4; end
n = fix(3/8*m);
r = [(1:n)'/n; ones(m-n,1)];
g = [zeros(n,1); (1:n)'/n; ones(m-2*n,1)];
b = [zeros(2*n,1); (1:m-2*n)'/(m-2*n)];
cmap = [r g b];
%%

function subfcn_demo(varargin)
%% buitin demo
verb(1,'run builtin demo of ',mfilename);
ncol = 4; % number of columns
n = 32; % number of colors of a colormap
opts = subfcn_opts(varargin{:}); % list of colormaps
ncm = length(opts); % number of colormaps
hf = mkfig([0.9,0.9]);
ha = mkaxes(ceil(ncm/ncol),ncol,1:ncm,hf,'fsz',9, ...
    'sp',{[.001,.005],[0,0],[.0,.0]});
for ii = 1.0 : length(opts)
    if ismember(opts{ii},{'lc','ls'})
        cm = cmstore(opts{ii});
    else
        cm = cmstore(n,opts{ii}); 
    end
    imagesc(linspace(0,1,size(cm,1)),'parent',ha(ii)); 
    colormap(ha(ii),cm); 
    axis(ha(ii),'tight'); %ylabel(ha(ii),opts{ii});
    textcell(ha(ii),mean(xlim(ha(ii))),mean(ylim(ha(ii))),opts{ii}, ...
        'c',[1,1,1]*.3,'fsz',13,'va','middle','ha','center');
    set(ha(ii),'xtick',[],'ytick',[]);
end
setfig(hf);
%% EOF
