function [s,t] = gaussd(dt,T,a,ord)
%% [s,t] = gaussd(dt|t,T,a,ord)
% Gaussian family
%
%% input:
%	dt|t: sampling interval|time vector
%	T: dominant period
%   a: default=14 (13.8629) for ord=0, (lowpass, -6db at T)
%              20 (2*pi^2=19.7392) for ord=1, peak at T, -6db width= 
%                                             1.93fc-0.32fc=1.6fc,
%                                             3.12Tc-0.52fc=2.6Tc
%              1/sqrt(2)=0.707 for ord=-1 (gausmono), (peak at T)
%              10 (pi^2=9.8696) for |ord|=2, peak at T, -6db width=
%                                            1.646fc-0.486fc=1.16fc,
%                                            2.06Tc-0.61Tc=1.45Tc
%              100 for gauspuls, (peak at T, -6db width=1.5fc-0.5fc=fc)
%     larger|smaller a -> narrower|broader waveform ->
%     broader|narrower spectrum and larger|smaller peak freq
%   ord: derivative order (default, 1)
%     0: Gaussian
%        larger a -> narrower waveform -> broader spectrum
%     1,2: first (sine-like) and second (autocorr-like) derivatives of Gaussian
%        larger a -> narrower waveform -> broader spectrum and higher peak freq
%        for gauss1d, a=20 looks great, making peak period at T; smaller a, larger Tp
%     -2|'rk|ricker': ricker wavelet (a=10 for peak at T)
%     -1|'gm|gausmono': gaussian pulse (-sine-like)
%     'gp|gauspuls': gaussian pulse, **better a>=60**
%        -6db bandwidth = fc*a/100=a/100/T
%        a is bandwidth percentage
%          smaller a -> approaching sine; narrower freq bandwidth
%          larger a -> approaching Gaussian; wider freq bandwidth
%        a=100 (default) -> small secondary peaks,
%            clear negative peaks, decay to 0 at ~2/T
%            mean is not zero (spec>0 at f=0); after demean, decay to 0 f=0
%        a=120 -> almost no secondary peaks
%        a=200 -> small negative peaks, nonsymmetric spectrum with peak shifted to lower freq
%        a=300 -> Gaussian shaped (low-pass)
%% output:
%	s: Gaussian (derivative) waveform
%	t: time axis (default, -2*T:dt:2*T)
%
% see also: gaussfilt; gauspuls, gausswin, window
%%
if nargin == 0
    subfcn_demo;
    return;
end

if nargin<4, ord = 1;  end
if isscalar(dt), t = -2*T:dt:2*T; else, t = dt; end

nT = length(T);
if nT > 1
    s = arrayfun(@(ii)gaussd(dt,T(ii),a,ord),1:nT,'uni',0);
    s = cat(2,s{:});
    return;
end

switch ord
    case {0,'gs'} % -6db: a=20*log(2)=13.8629
        if nargin<3 || isempty(a), a = 13.8629; end
        s = exp(-a*(t/T).^2);        
    case {1,'1d','g1d'} % 1-ord gaussian; related to gausmono: a=4*pi^2*a_gm^2=19.74
        if nargin<3 || isempty(a), a = 19.7392; end
        %s = - 2*a*t/T .* exp(-a*(t/T).^2);       
        s = -t .* exp(-a*(t/T).^2);        
    case {2,'2d','g2d'} % 2nd order derivative of Gaussian; a=pi^2=9.8696
        if nargin<3 || isempty(a), a = 9.8696; end
        x2 =(t / T).^2;
        s = (2*a*x2-1).*exp(-a*x2);     
    case {-1,'gm','gausmono'}
        if nargin<3 || isempty(a), a = 1/sqrt(2); end
        x = 2*a * t / T *2*pi;
        s = x .* exp(-(x/2).^2);           
    case {-2,'rk','ricker'} % Ricker wavelet
        if nargin<3 || isempty(a), a = 9.8696; end
        x2 =(t / T).^2;
        s = (1-2*a*x2).*exp(-a*x2);      
    case {'gp','gausspulse'} % similar to Ricker but with symmetric spectrum
        if nargin<3 || isempty(a), a = 100; end
        %t = -5*T : dt : 5*T; 
        fc = 1 / T; % center freq
        bw = a / 100; % bandwidth in percent
        bwr = -6; % db at the fractional bandwidth
        r = 10.^(bwr/20); % Ref level (fraction of max peak)
        fv = -(bw*fc)^2/(8*log(r)); % variance is fv, mean is fc
        tv = 1/(4*pi^2*fv); % variance is tv, mean is 0
        s = exp(-t.^2/(2*tv)) .* cos(2*pi*fc*t); % modulate envelope 
        %% other way
        %tpe = -40; % db to truncate
        %tc = gauspuls('cutoff',fc,bw,bwr,tpe); % Gaussian-modulated sinusoidal pulses
        %t = -1.5*tc : dt : 1.5*tc; 
        %s = gauspuls(t,fc,bw);        
    otherwise
        error('wrong ord');
end
s = s / max(abs(s)); %norm to unit
% s = s / abs(dot(s,exp(-1j*2*pi/T*t))); %norm by peak

if nargout==0
    ha = mkaxes(1,2);
    plot(t,s,'parent',ha(1));
    fftplot(s,1/(t(2)-t(1)),'y','db','ax',ha(2));
end
%%

%% SUBFUNCTION
function subfcn_demo
%% builtin demo
verb(1,'run builtin demo of ',mfilename);
[T,dt] = deal(10,0.5);
% [T,dt] = deal(1,0.1);

as = [5,10,14,20,40,80];
os = [0,1,-2];
for ord = os
    hf = mkfig('name',['demo of ',mfilename]);
    ha = mkaxes(1,2,[],hf,'ti',1);
    for ii = 1 : length(as)
        [s,t] = gaussd(dt,T,as(ii),ord);
        linemk(ha(1),t,s-ii+1,'lw',2); grid(ha(1),'on');
        fftplot(s,1/dt,'y','ndb','ax',ha(2),'lw',2); grid(ha(2),'on');
    end
    xlabel(ha(1),'t (s)');
    title(ha(1),sprintf('%d-ord Gaussian [Tc=%g]',abs(ord),T));
    set(ha(2),'YLim',[-6,0]); xlim(ha(2),'auto'); title(ha(2),'psd');
    hf.CurrentAxes = ha(1);
    legend(cstrcon('a=',as),'box','off','color','none');
end
title(ha(1),sprintf('ricker [Tc=%g]',T));
% gaussian monopulse
as = [0.25, 0.5, 1/sqrt(2), 1, 2];
t  = -2*T : dt : 2*T;
hf = mkfig('name',['demo of ',mfilename]);
ha = mkaxes(1,2,[],hf,'ti',1);
for ii = 1 : length(as)
    s = gaussd(t,T,as(ii),'gm');
    linemk(ha(1),t,s-ii+1,'lw',2); grid('on');
    fftplot(s,1/dt,'y','ndb','ax',ha(2),'lw',2); grid('on');
end
xlabel(ha(1),'t (s)'); 
title(ha(1),sprintf('gaussian monopulse [Tc=%g]',T));
set(ha(2),'YLim',[-6,0]); xlim(ha(2),'auto'); title(ha(2),'psd');
hf.CurrentAxes = ha(1);
legend(cstrcon('a=',as),'box','off','color','none');
% gaussian pulse
as = [10, 30, 50:25:150, 200, 300];
t  = -5*T : dt : 5*T;
hf = mkfig('name',['demo of ',mfilename]);
ha = mkaxes(1,2,[],hf,'ti',1);
for ii = 1 : length(as)
    s = gaussd(t,T,as(ii),'gp');
    linemk(ha(1),t,s-ii+1,'lw',2); grid('on');
    fftplot(s,1/dt,'y','ndb','ax',ha(2),'lw',2); grid('on');
end
xlabel(ha(1),'t (s)');
title(ha(1),sprintf('gaussian pulse [Tc=%g]',T));
set(ha(2),'YLim',[-6,0]); xlim(ha(2),'auto'); title(ha(2),'psd');
hf.CurrentAxes = ha(1);
legend(cstrcon('a=',as),'box','off','color','none');
%% EOF
