function varargout = fftplot(s,fs,varargin)
%% [ha,hl,yf,f] = fftplot(s,fs[,nfft],'name',value,...);
% plot fft amplitude spectrum
%
% input:
%   s: signal, vector or colum-wise matrix
%   fs: sampling frequency
%   name-value pairs: 
%     'n|nfft': npts of fft (default, npts)
%        if nfft<npts, use welch's method with subtrace=nfft, step=nfft/2
%     'h|ha|ax|axes': parent axes handle
%     '[x]flag': x axis type, 'f(default)|t|flog|tlog'
%     '[y]flag': y axis type, 'amp(default)|[n]amp|log|db|ndb' 
%     '[xl]im,[yl]im': axes limits to show
%     '[w]aveform': plot waveform (neglect if parent axes are specified)
%     others are passed to `plot` function
% output:
%   ha: handle(s) of axes
%   hl: handle of amp spec | handles of [waveform,spec]
%   yf: spectrum magnitude normalized by N
%   f: frequency
%
% see also: fftspec, specplot, plotir
%%
if nargin == 0
    subfcn_demo;
    return;
end

rowflag = size(s,1)==1;
if rowflag, s = s.'; end
if nargin<2 || isempty(fs), fs = 1; end

[ha,nfft,xflag,yflag,xl,yl,pwvf,largs] = subfcn_parse(s,varargin{:});

%% fft data
[yf,f] = subfcn_fft(s,fs,nfft);
x = f(:);
tflag = ismember('t',xflag([1,end]));
if tflag, x = [nan; 1./x(2:end)]; end

%% plot
ha = subfcn_axes(ha,pwvf);
hh = ha(end); % for amp spec
switch(yflag)
    case {'db','decibel'}
        db = 20*log10(yf);
        hl = linemk(hh,x,db,largs{:});
        ylabel(hh,'db');
    case {'ndb'}
        db = 20*log10(yf/max(yf(:)));
        hl = linemk(hh,x,db,largs{:});
        ylabel(hh,'normalized db');
    case {'log'}
        hl = linemk(hh,x,log(yf),largs{:});
        ylabel(hh,'log10(|A|)');
    case {'n','namp','nmag'}
        hl = linemk(hh,x,yf/max(yf),largs{:});
        ylabel(hh,'normalized magnitude');
    otherwise            
        hl = linemk(hh,x,yf,largs{:});
        ylabel(hh,'magnitude');
end
if strmate(xflag,'log'), set(hh,'XScale','log'); end
if strmate(yflag,'log'), set(hh,'YScale','log'); end
if tflag
    if isempty(xl), xl = [x(end),min(x(2),5e2/fs)]; end
    xlim(hh,xl);
    xlabel(hh,'period [s]');       
else
    if isempty(xl), xl = [x(1),x(end)]; end
    xlim(hh,xl);
    xlabel(hh,'frequency [Hz]');
end
if ~isempty(yl), ylim(hh,yl); end

if length(ha) > 1 % plot waveform
    t = (0:size(s,1)-1) / fs;
    hl = [linemk(ha(1),t,s,'xl',t([1,end]),'dnm','waveform',largs{:}),hl];
end

if rowflag, yf = yf.'; end
varargout = {ha, hl, yf, f};
%%

%% SUBFUNCTIONS
function [ha,nfft,xflag,yflag,xl,yl,pwvf,largs] = subfcn_parse(s,varargin)
%% parse args
[ha,nfft,xflag,yflag,xl,yl,pwvf] = deal([],0,'f','abs',[],[],false);
if mod(length(varargin),2)
    [nfft,varargin] = deal(varargin{1},varargin(2:end)); 
end
flag = false(size(varargin));
for ii = 1 : 2 : length(varargin)
    [n,v] = deal(lower(varargin{ii}),varargin{ii+1});
    switch(n)
        case {'a','ha','ax','axes','parent'}
            ha = v;
            assert(all(isaxes(ha)),'invalid axes handle');
        case {'n','nfft'}
            nfft = fix(v);
        case {'x','xflag'}
            xflag = lower(v);
        case {'y','yflag'}
            yflag = lower(v);
        case {'xl','xlim'}
            xl = v([1,end]);
        case {'yl','ylim'}
            yl = v([1,end]);
        case {'w','waveform'} % plot waveform
            pwvf = logical(v);
        otherwise          
            flag(ii:ii+1) = true;
    end
end
largs = hgargs('line',varargin(flag));
npts = size(s,1+(size(s,1)==1));
if nfft <= 0
    nfft = npts;
elseif nfft < 100 % nsub
    nfft = ceil(npts/nfft);
end
nfft = max(512, 2*ceil(nfft/2));
%%

function [ha,hf] = subfcn_axes(ha,pwvf)
%% prepare axes
if isempty(ha)
    hf = mkfig; 
    ha = mkaxes(1+pwvf,1,hf,'box','on','xmt','on','ymt','on');
    xlabel(ha(1),'Time')
else
    hf = get(ha(end),'Parent');
end
set(ha,'NextPlot','add');
set(hf,'KeyPressFcn',{@keycb,ha(end)});
%%

function [yf,f] = subfcn_fft(s,fs,nfft)
%% fft data (use Welch's method if nfft<npts)
[npts,ns] = size(s);
yf = 0;
nsub = 0;
for ii = 1 : nfft/2 : max(npts-nfft/2, nfft/2)
    id = ii : ii+nfft-1;
    if id(end) <= npts
        s2 = s(id,:);
    else
        s2 = [s(id(1):npts,:); zeros(id(end)-npts,ns)];
    end
    [y,~,f] = fftspec(s2,nfft,[],false,1,fs); % abs of spec
    yf = yf + y/nfft;
    nsub = nsub + 1;
end
if nsub>1, yf = yf / nsub; end
%%

function subfcn_demo
%% builtin demo
verb(1,'run builtin demo of ',mfilename);
dt = 0.5;
Tc = 10;
[s,t] = gaussd(dt,Tc,100,'gp');
xas = 't';
ha = mkaxes(2,1);
% linemk(ha(1),t,s,'lw',2);
% fftplot(s,1/dt,'x',xas,'y','ndb','lw',2,'ax',ha(2), ...
%     'xl',bycond(xas=='f',[0,0.5],[0,30]),'yl',[-20,0]);
fftplot(s,1/dt,'x',xas,'y','ndb','lw',2,'ax',ha, ...
    'xl',bycond(xas=='f',[0,0.5],[0,30]),'yl',[-20,0]);
linev(ha(2),bycond(xas=='f',1/Tc,Tc),'r--');
legend(ha(2),sprintf('Tc=%gs',Tc));
%% EOF
