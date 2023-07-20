%%
% a simple demo for the MTWS method
%%

dt = 0.1; % sampling interval
[T1,T2] = deal(20,40); % min and max cutoff periods
Tc = 1 / mean(1./[T1,T2]); % central period
t0 = 600; % location of signal peak
t = 0 : dt : 1200; % time axis
k = 0.05; % percentage of noise
npow = 1; % N-power envelope
td = 9*Tc; % width of the annotation dip line

%% make a trace with some noise
signal = gaussd(t-t0,Tc,50,'gp'); 
noise = preproc(rand(size(t)),[1/T2,1/T1]*2*dt,0.1);
s = signal + k*noise/std(noise);
s = preproc(s,[1/T2,1/T1]*2*dt,0.1);

%% determine the window
e = envelope(s);
[~,ipk] = max(e);
ep = e.^npow;
[i1,i2] = mtws(ep,t,ipk,td);

%% visualization
hf = mkfig('Name',['demo of ',mfilename]);
ha = mkaxes(1,1,hf,'ti',1,'color','none','box','off','fsz',12);
linemk(ha(1),t,s,'c',[1,1,1]*.5,'dnm','waveform'); 
linemk(ha(1),t,e,'c','r','dnm','envelope'); 
linemk(ha(1),t(ipk),e(ipk),'fro','dnm','peak');
[~,ppt] = point_line_distance([t(i1),ep(i1)],[t(ipk),ep(ipk)],[t(ipk)-td,0]);
line2p(ha(1),[t(ipk),ep(ipk)],[t(ipk)-td,0],'c',[0,0.2,0.6],'dnm','auxiliary line');
line2p(ha(1),[t(i1),ep(i1)],ppt,'c','k','ls','--','dnm','largest distance');
[~,ppt] = point_line_distance([t(i2),ep(i2)],[t(ipk),ep(ipk)],[t(ipk)+td,0]);
line2p(ha(1),[t(ipk),ep(ipk)],[t(ipk)+td,0],'c',[0,0.2,0.6],'dnm','auxiliary line');
line2p(ha(1),[t(i2),ep(i2)],ppt,'c','k','ls','--','dnm','largest distance');
ylabel(ha(1),'Amplitude'); legend(ha(1));

setprop(ha,'xl',t0+[-1,1]*1.25*td);
linkprop(ha,'xlim','xtick');

%% EOF
