function [vs,ps] = getprop(hs,varargin)
%% similar to get(h,'prop') but returns '__invalid_prop__' for non-existing props
% usage:
%   getprop(h,'-re[gexp]',regexp,...)
%   [vs,ps] = getprop(hs,prop1,prop2,...)
%
%% notes:
%   get(h,'prop') returns the value of prop
%   get(h,{'prop1','prop2',...}) returns a cell array of props
% 
%% input:
%   hs: handles
%   propX: 'prop1,prop2,...'|'prop1','prop2',...|{prop1,prop2,...}
%% output:
%   vs: {val1,val2,...} or {{val1,val2,...},...}
%   ps: {prop1,prop2,...}
%
% see also: setprop
%%

if isscalar(varargin)
    if ischar(varargin{1}) % (hs,'prop1,prop2,...')
        ps = strsplit(strrep(varargin{1},' ',''),',');
    elseif iscellstr(varargin{1}) % (hs,{prop1,prop2,...})
        ps = varargin{1};
    end
else
    assert(~isempty(varargin),'no prop specified');
    assert(iscellstr(varargin),['usage: ',mfilename,'(hs,prop1,prop2,...)']);
    if ismember(varargin{1},{'-re','-reg','-regex','-regexp'})
        % getprop(hs,'-regexp','regexp',...)
        pv = get(hs);
        ps = fieldnames(pv);
        id = ~cellfun(@isempty,regexp(ps,varargin{2:end}));
        mypv = fldcopy([],pv,ps(id));
        mypv = arg2cell(mypv);
        [vs,ps] = deal(mypv(2:2:end),mypv(1:2:end));
        return;
    end
    ps = varargin;
end 
% now ps = {'prop1','prop2',...}

%% get properties
if isstruct(hs)
    vs = subfcn_struct(hs,ps,'__invalid_field__');
elseif isa(hs,'containers.Map')
    vs = subfcn_map(hs,ps,'__invalid_key__');
else
    vs = subfcn_handle(hs,ps,'__invalid_prop__');
end

if isscalar(hs)    
    if isscalar(ps)
        vs = vs{1,1};
    else
        vs = reshape(vs,1,[]);
    end
end
%%

%% FUNCTIONS
function vs = subfcn_struct(hs,ps,missing)
%% from struct
np = length(ps);
nh = length(hs);
vs = cell(nh,np);
for ih = 1 : nh
    for ip = 1 : np
        if isfield(hs(ih),ps{ip})
            vs{ih,ip} = hs(ih).(ps{ip});
        else
            vs{ih,ip} = missing;  
        end
    end
end
%%

function vs = subfcn_map(m,ps,missing)
%% from map
np = length(ps);
vs = cell(1,np);
for ip = 1 : np
    if isKey(m,ps{ip})
        vs{ip} = m(ps{ip});
    else
        try
            vs{ip} = m.(ps{ip});
        catch
            vs{ip} = missing;  
        end
    end
end
%%

function vs = subfcn_handle(hs,ps,missing)
%% from handle (prop is case insensitive)
props = ps;
np = length(ps);
nh = length(hs);
vs = cell(nh,np);
for ih = 1 : nh
    h = hs(ih);
    if ishghandle(h)
        alias = hgpropalias(h);
        ps = cellfun(@(x)parse_alias(alias,x),props,'uni',0);
    end
    for ip = 1 : np
        if isprop(h,ps{ip})
            vs{ih,ip} = get(h,ps{ip});
        else
            vs{ih,ip} = missing;
        end
    end
end
%% EOF
