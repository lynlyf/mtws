function varargout = butterfilt(varargin)
%% butterworth filter
% usage:
%   [b,a] = butterfilt(wn[,ord]) % return a filter
%   [sf,b,a] = butterfilt(s,wn[,ord,zerophase|fcn_handle]) % filter signal
%
% * frequency response of digital filter:
%
%               jw               -jw              -jmw
%        jw  B(e)    b(1) + b(2)e + .... + b(m+1)e
%     H(e) = ---- = ------------------------------------
%               jw               -jw              -jnw
%            A(e)    a(1) + a(2)e + .... + a(n+1)e
%
% input:
%   s: signal to be filtered | []
%   wn: normalized cutoff frequencies
%     + lowpass, [0,fhi]
%     + highpass, [flo,inf]
%     + bandpass, [flo,fhi]
%     + bandstop, [0,f1,f2,inf]
%	ord: order of filter (default,3)
%	zerophase: zero-phase filtering (default,true)
%     + false, call `filter`
%     + true, call `filtfilt` (filter order is 2*ord)
% output: 
%   sf: filtered signal
%   b,a: coefficients of butterworth filter
%
% see also: preproc, taper, gaussfilt
%%
if nargin == 0
    subfcn_demo;
    return;
end

[ord,ffcn] = deal(2,@filtfilt);
if isscalar(varargin) %(wn)
    [b,a] = subfcn_coef(varargin{1},ord);
    varargout = {b,a};
    return;
elseif nargin == 2
    if isscalar(varargin{2}) %(wn,ord)
        [b,a] = subfcn_coef(varargin{:});
        varargout = {b,a};
        return;
    end    
    [s,wn] = deal(varargin{:}); %(s,wn)
else
    [s,wn,ord] = deal(varargin{1:3});
    if nargin>3
        if isa(varargin{4},'function_handle')
            ffcn = varargin{4};
        elseif ~varargin{4}
            ffcn = @filter;
        end
    end
end

[b,a] = subfcn_coef(wn,ord);
if isempty(s)
    sf = [];
else
    sf = ffcn(b,a,double(s));
end
varargout = {sf,b,a};
%% 

%% SUBFUNCTIONS
function [b,a] = subfcn_coef(wn,ord)
%% return coefficients for a butter filter
if nargin<2||isempty(ord), ord = 2; end

if wn(1)>0 % wn = [lo,hi|inf]
    if wn(2)==1 || isinf(wn(2)) % high pass
        [b,a] = butter(ord,wn(1),'high'); 
    else % band pass
        assert(wn(1)<wn(2),'wn = [lo,hi]');
        [b,a] = butter(ord,wn,'bandpass');
    end
else % wn = [0,hi|inf]
    if isinf(wn(end))
        if length(wn) == 2 % no filtering
            [b,a] = deal(1,1);
            return;
        elseif length(wn) == 4 % band stop
            [b,a] = butter(ord,wn(2:3),'stop');
        else
            error('wrong wn');
        end
    else % low pass
        [b,a] = butter(ord,wn(2),'low');
    end
end
%%

function subfcn_demo
%% Builtin demo
verb(1,'run builtin demo of ',mfilename);
fs = 100;
n = 207;
t = (7:n+6)/fs;
x = sin(2*pi*5*t) +rand(1,n) -1/2;
flim = [4.5,5.5];
wn = flim * 2/fs;
y1 = butterfilt(x,wn,6,false);
[y2,b,a] = butterfilt(x,wn,3,true);
y3 = filter(b,a,fliplr(filter(b,a,fliplr(x))));
y4 = fliplr(filter(b,a,fliplr(filter(b,a,x))));
y5 = butterfilt(x,[0,wn,inf]);
%%
% * `filter` tapers the heading samples
% * `filtfilt` tapers the tailing samples
% * `filtfilt` is similar to `flip(filter(flip(filter)))`, but not the same
%%
mkfig; freqz(b,a,1024,fs); 
hf = mkfig('name',['demo of ',mfilename]);
ha = mkaxes(3,1,hf,'ti',1);
hl = plot(ha(1),t,x,'k',t,[y1;y2]); setprop(hl,'lw',2); 
legend(ha(1),'original','butter-filter','butter-filtfilt');
hl = plot(ha(2),t,[y2;y3;y4]); setprop(hl,'lw',2); 
legend(ha(2),'filtfilt','filter(flip(filter(flip)))','flip(filter(flip(filter)))');
hl = plot(ha(3),t,x,'k',t,[x-y2;y5]); setprop(hl,'lw',2); 
legend(ha(3),'original','original - filtfilt','butter-bandstop');
xlabel(ha(3),'t (s)');
%% EOF
