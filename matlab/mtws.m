function varargout = mtws(e,t,ipeak,walkaway)
%% determine the left and right locations of windows aroun peaks
% usage: 
%   [ileft,iright] = mtws(e,t,ipeak,walkaway[,balance])
%   [ileft,ipeak,iright] = mtws(e,t,{wsz[,base,k_med]},walkaway[,balance])
%
%% input:
%  e: envelope
%  t: time axis | time interval
%  ipeak: peak locations [ipk1,...]
%| {wsz,base,k_median}: 
%    wsz: moving window size of max filter (the same unit as `t`)
%    base: reject if a peak is lower than `base` (the same unit as `e`)
%    k_med: reject if a peak if lower than `k_med*median(e)`
%  walkaway: auxiliary line across [t(ipk),e(ipk)] and [t(ipk)+/-walkaway,0]
%  balance: scale peak to walkaway (default, false)
%    the dimension equalization is not necessary
%% output: locations of the left and right edges of windows
% 
%%

assert(isvector(e),'only vector is supported)');
e = e(:);
if isscalar(t) % (e,dt,...)
    t = (1:length(e)) * t;
end
t = t(:);
dt = t(2) - t(1);
%assert(walkaway>10*dt,'wrong walkaway');

maxfilted = false;
if iscell(ipeak) %(e,t,{wsz[,base,k_med]},walkaway[,balance])
    k = ipeak; % {wsz,base,k_med}
    b = movmax(e,fix(k{1}/dt));
    b([1,end]) = e([1,end]) + eps(e([1,end])); % fix ends
    ipeak = find(e==b); % max extrema
    % filter maxima with hard threshold
    if length(k)>1 && ~isempty(k{2})
        ipeak(e(ipeak)<k{2}) = [];
    end
    if length(k)>2 && ~isempty(k{3})
        ipeak(e(ipeak)<k{3}*median(e)) = [];
    end
    maxfilted = true;
end
ipeak = ipeak(:);

[ileft,iright] = deal(nan(size(ipeak)));
for ii = 1 : length(ipeak) % loop over peaks
    ipk = ipeak(ii);
    %% left side    
    [x,sid] = subvec(t,t,t(ipk)+[dt-walkaway,-dt]); % [-walkaway,0] relative to peak
    dis = point_line_distance([x,e(sid)],[t(ipk),e(ipk)],[t(ipk)-walkaway,0]);
    [~,mid] = max(dis); % find max dis to the dip line
    ileft(ii) = sid(mid); % left bound at t(i1)
    %% right side
    [x,sid] = subvec(t,t,t(ipk)+[dt,walkaway-dt]); % [0,walkaway] relative to peak
    dis = point_line_distance([x,e(sid)],[t(ipk),e(ipk)],[t(ipk)+walkaway,0]);
    [~,mid] = max(dis); % max dis to the dip line
    iright(ii) = sid(mid); % right bound at t(i2)
end

if nargout > 1
    if maxfilted
        varargout = {ileft,ipeak,iright};
    elseif nargout == 2
        varargout = {ileft,iright};
    else
        varargout = {ileft,ipeak,iright};
    end
else
    if maxfilted
        varargout = {[ileft,ipeak,iright]};
    else
        varargout = {[ileft,iright]};
    end
end

%% EOF
