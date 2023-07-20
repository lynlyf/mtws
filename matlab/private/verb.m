function verb(varargin)
%% verb([v|[v,ge_val]|{v,eq_val},]str1,str2,...);
% print verbosity
%
% '%T', leading '[yyyy-mm-ddTHH:MM:SS]'
% '%D', leading '[yyyy-mm-dd]'
% '%H', leading '[HH:MM:SS]'
% '%C', leading caller '<main_fcn>[LXX]: ' if v==1
%       leading function stack if v>1
% '%F{outfile}', print to file
%
% example:
%   > verb(1,'%D%Csome info')
%   > verb([2,1],'%D%Csome info')
%   > verb({2,2},'%D%Csome info')
%%
v = 1;
if islogical(varargin{1}) || isnumeric(varargin{1}) || iscell(varargin{1})
    [v,varargin] = deal(varargin{1},varargin(2:end)); 
end
if isempty(varargin), varargin = {''}; end
if iscell(v) % ({vb,exact_value},...)
    v = v{1}==v{2};
elseif ~isscalar(v) % ([vb,threshold],...)
    v = v(1)>=v(2);
end
if ~v, return; end

outfile = '';
if ischar(varargin{1}) && length(varargin{1})>=2
    [a,b,ii] = deal(varargin{1},'',1);
    while ii < length(a) % '%X%Y...'
        if strncmp('%T',a(ii:end),2)
            b = sprintf('%s%s',b,datestr(now,'[yyyy-mm-ddTHH:MM:SS] '));
        elseif strncmp('%D',a(ii:end),2)
            b = sprintf('%s%s',b,datestr(now,'[yyyy-mm-dd] '));
        elseif strncmp('%H',a(ii:end),2)
            b = sprintf('%s%s',b,datestr(now,'[HH:MM:SS] '));
        elseif strncmp('%C',a(ii:end),2) % caller
            c = subfcn_caller(dbstack,v);
            if ~isempty(c), b = [b,c,' ']; end
        elseif strncmp('%F',a(ii:end),2) % '%F{outfile}...', output to file            
            if a(ii+2)=='{'
                outfile = a(ii+2+(1:find(a(ii+3:end)=='}',1)-1));
            end
            if isempty(outfile)
                outfile = 'verb.output';
            else
                ii = ii + length(outfile) + 2;
            end
        else
            break;
        end
        ii = ii + 2;
        varargin{1} = [b,a(ii:end)];
    end
end

for ii = 1 : length(varargin)
    x = varargin{ii};
    if isnumeric(x)
        nd = ndims(x);
        if isvector(x)
            if length(x) <= 16
                varargin{ii} = strcon(',',x);
            else
                varargin{ii} = [strcon(',',x(1:8)),' ... ',strcon(',',x(end-7:end))];
            end
        else
            varargin{ii} = sprintf(['[%d array of size [',repmat('%d',1,nd),']]'],nd,size(x));
        end
    end
end

fmt = [repmat('%s',1,length(varargin)),'\n'];
if v>0, fmt = ['$ ',fmt]; end
s = sprintf(fmt,varargin{:});
if isempty(outfile)
    fprintf('%s',s);
else
    txtsave(outfile,s,'a');
end
%%

%% SUBFUNCTION
function c = subfcn_caller(st,v)
%% caller function stack
v = abs(fix(v)); 
nf = length(st);
if nf <= 1 % only `verb` in stack 
    c = '';
elseif v<2 || nf==2
    c = sprintf('%s(L%d):',st(nf).name,st(nf).line);
else
    n = min(v,nf);
    c = strcon('(L', {st(n:-1:2).name}, [st(n:-1:2).line]);
    c = [strjoin(c,'):'), '):'];
end
%% EOF