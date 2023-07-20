function keycb(src,evt,ax)
%% keyboard callback function for figures
% usage: set(hfig,'KeyPressFcn',{@keycb,ax});
%%
if nargin<3
    verb(1,'not enough input');
    return;
end

for ii = 1 : length(ax)
    if ~isequal(get(ax(ii),'type'),'axes')
        fprintf('  ** %f is not a valid axes handle\n',ax(ii));
        return;
    end
end

switch(upper(evt.Key))
    case 'E'  % export, CTRL+E
        if any(strcmpi(evt.Modifier,'CONTROL'))
            [fnm,pnm] = uiputfile({'*.tif'},'save as...');
            if isequal(fnm,0) || isequal(pnm,0),  return; end
            print('-dtiff','-r200',fullfile(pnm,fnm));
        end
        
    case 'G'  % toggle grid lines
        for ii = 1 : length(ax)
            for prop = {'XGrid','YGrid'}
                if isequal('on',get(ax(ii),prop{1}))
                    set(ax(ii),prop{1},'off');
                else
                    set(ax(ii),prop{1},'on');
                end
            end
        end        
        
    case 'X'  % set xlim
        if any(strcmpi(evt.Modifier,'SHIFT')) % tight x axis
            for ii = 1 : length(ax)
                yl = get(ax(ii),'YLim');
                axis(ax(ii),'tight');
                set(ax(ii),'YLim',yl);
            end
            return;
        end
        % set xlim
        xx = inputdlg(sprintf('input xlim: (e.g. 150, 300)\n'),'XLim',1);
        if isempty(xx), return; end % cancel
        if isempty(xx{1}) % auto
            xlim(ax,'auto');
            return;
        end
        xx = textscan(xx{1},'%f','delimiter',',; ');
        if isempty(xx), return; end
        xx = xx{1};
        if length(xx)==2
            if isequal(get(gco,'type'), 'axes')
                set(gco,'xlim',xx);
            else
                set(ax,'xlim',xx); 
            end
        end
        
    case 'Y'  % set ylim
        if any(strcmpi(evt.Modifier,'SHIFT')) % tight y axis
            for ii = 1 : length(ax)
                xl = get(ax(ii),'XLim');
                axis(ax(ii),'tight');
                set(ax(ii),'XLim',xl);
            end
            return;
        end
        yy = inputdlg(sprintf('input ylim: (e.g. -1e4, 1e4)\n'),'YLim',1);
        if isempty(yy), return; end % cancel
        if isempty(yy{1}) % auto
            ylim(ax,'auto');
            return;
        end
        yy = textscan(yy{1},'%f','delimiter',',; ');
        if isempty(yy), return; end
        yy = yy{1};
        if length(yy)==2
            if isequal(get(gco,'type'), 'axes')
                set(gco,'ylim',yy);
            else
                set(ax,'ylim',yy); 
            end
        end
        
    case {'ADD','EQUAL'}  % y zoom in  
        if any(strcmpi(evt.Modifier,'CONTROL')) % CTRL
            k = 4/3;
        else
            k = 2;
        end % zoom times
        for n = 1:length(ax)
            yy = get(ax(n),'ylim');
            if any(strcmpi(evt.Modifier,'SHIFT'))
                if any(strcmpi(evt.Modifier,'ALT')) % zoom against y=0
                    yy = yy/k;
                else % zoom against screen y center
                    yy = mean(yy) + 0.5/k*diff(yy)*[-1 1];
                end
            elseif any(strcmpi(evt.Modifier,'ALT')) % zoom ydata upward
                h = getchildren(ax(n),'type','line');
                scaleplot(h,k,@min,'ad');
            else % zoom ydata
                h  = getchildren(ax(n),'type','line');
                yb = scaleplot(h,k,@mean,'ad');
%                 yb = [min(yb(:,1)),max(yb(:,2))];
%                 yy(1) = min(yy(1),yb(1));
%                 yy(2) = max(yy(2),yb(2));
            end
            set(ax(n),'ylim',yy);
        end
        

    case {'HYPHEN','SUBTRACT'} % y zoom out
        if any(strcmpi(evt.Modifier,'CONTROL')) % CTRL
            k = 0.75;
        else
            k = 0.5;
        end
        for n = 1:length(ax)
            yy = get(ax(n),'ylim');
            if any(strcmpi(evt.Modifier,'SHIFT')) 
                if any(strcmpi(evt.Modifier,'ALT')) % zoom against y=0
                    yy = yy/k;
                else % zoom against screen y center
                    yy = mean(yy) + 0.5/k*diff(yy)*[-1 1];
                end
            elseif any(strcmpi(evt.Modifier,'ALT')) % zoom ydata upward
                h = getchildren(ax(n),'type','line');
                scaleplot(h,k,@min,'ad');
            else % zoom ydata
                h  = getchildren(ax(n),'type','line');
                yb = scaleplot(h,k,@mean,'ad');
%                 yb = [min(yb(:,1)),max(yb(:,2))];
%                 yy(1) = max(yy(1),yb(1));
%                 yy(2) = min(yy(2),yb(2));
            end
            set(ax(n),'ylim',yy);
        end

    case 'PAGEDOWN' % scroll down
        k = 0.25;
        if isequal(evt.Modifier,{'alt'})
            k = 1;
        elseif isequal(evt.Modifier,{'control'})
            k = 0.125;
        elseif isequal(evt.Modifier,{'shift'})
            k = 0.5;
        end
        for ii = 1 : length(ax)
            yy = get(ax(ii),'ylim');
            dy = k * (yy(2)-yy(1));
            set(ax(ii),'ylim',yy-dy);
        end
        
    case 'PAGEUP' % scroll up
        k = 0.25;
        if isequal(evt.Modifier,{'alt'})
            k = 1;
        elseif isequal(evt.Modifier,{'control'})
            k = 0.125;
        elseif isequal(evt.Modifier,{'shift'})
            k = 0.5;
        end
        for ii = 1 : length(ax)
            yy = get(ax(ii),'ylim');
            dy = k * (yy(2)-yy(1));
            set(ax(ii),'ylim',yy+dy);
        end
        
    case 'LEFTARROW'  % move to left
        k = 0.25;
        if isequal(evt.Modifier,{'alt'})
            k = 1;
        elseif isequal(evt.Modifier,{'control'})
            k = 0.125;
        elseif isequal(evt.Modifier,{'shift'})
            k = 0.5;
        end
        xx = get(ax(1),'XLim');
        xx  = xx - k*(xx(2)-xx(1));
        set(ax,'XLim',xx);
        
    case 'RIGHTARROW'  % move to tright
        k = 0.25;
        if isequal(evt.Modifier,{'alt'})
            k = 1;
        elseif isequal(evt.Modifier,{'control'})
            k = 0.125;
        elseif isequal(evt.Modifier,{'shift'})
            k = 0.5;
        end
        xx = get(ax(1),'XLim');
        xx = xx + k*(xx(2)-xx(1));
        set(ax,'XLim',xx); 
        
    case 'UPARROW'  % x-zoom in (UP or CTRL+UP) or move up (SHIFT+UP)
        if any(strcmpi(evt.Modifier,'SHIFT')) % move up
            yy = get(ax(1),'YLim');
            yy = yy + 0.125*(yy(2)-yy(1));
            set(ax,'YLim',yy); 
            return;
        end
        
        % x-zoom in
        if any(strcmpi(evt.Modifier,'CONTROL'))
            k = 0.375;
        else
            k = 0.25;
        end
        xx   = get(ax(1),'XLim');
        tmp  = mean(xx);
        tmp2 = k*(xx(2)-xx(1));
        xx   = [tmp-tmp2 tmp+tmp2];
        set(ax,'XLim',xx);
        
    case 'DOWNARROW'  % x-zoom out or move down 
        if any(strcmpi(evt.Modifier,'SHIFT')) % move down
            yy = get(ax(1),'YLim');
            yy = yy - 0.125*(yy(2)-yy(1));
            set(ax,'YLim',yy); 
            return;
        end
        
        % x-zoom out
        if any(strcmpi(evt.Modifier,'CONTROL'))
            k = 1.25;
        else
            k = 1;
        end
        xx   = get(ax(1),'XLim');
        tmp  = mean(xx);
        tmp2 = k*(xx(2)-xx(1));
        xx   = [tmp-tmp2 tmp+tmp2];
        set(ax,'XLim',xx);        
        
    otherwise
        if isempty(evt.Modifier), commandwindow; end
        return;
end
%%
