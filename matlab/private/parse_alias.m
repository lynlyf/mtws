function realname = parse_alias(alias,name)
%% realname = parse_alias(alias,name);
% Return the real name of an alias name
%
% - if name not in alias dict, return name itself
%
%% input:
%   alias: alias dict
%     {realname,{alias1,...},...} | struct.realname={alias1,...}
%   name: name to parse, str
%% output: real name
%
% see also: arg2cell, cell2arg, releasevar, setdefaults
%%
if nargin == 0
    subfcn_demo;
    return; 
end

realname = name;
if isempty(alias)
    return; 
end

%% {'realname',{'alias1',...},...}
if iscell(alias)
    if ~isvector(alias)
        [n1,n2] = size(alias);
        if n1==2 && n2>1
            alias = reshape(alias,1,[]);
        elseif n1>2 && n2==2
            alias = reshape(alias.',1,[]);
        else
            error('confusing alias cellarr');
        end
    end
    for ii = 1 : 2 : length(alias)
        if (iscell(alias{ii+1}) && ismember(name,alias{ii+1})) ...
                || isequal(name,alias{ii+1})
            realname = alias{ii};
            break;            
        end
    end
    return;
end

%% struct('realname',{'alias',...},...)
names = fieldnames(alias); 
for ii = 1 : length(names)
    a = alias.(names{ii});
    if (iscell(a) && ismember(name,a)) || isequal(name,a)
        realname = names{ii};
        break;
    end
end
%%

%% SUBFUNCTION
function subfcn_demo
%% builtin demo
verb(1,'run builtin demo of ',mfilename);
alias = {'a','aa', 1,{'1','1b','bb'}};
realname = parse_alias(alias,'aa');
assert(realname=='a','test failed');
realname = parse_alias(alias,'1');
assert(realname==1,'test failed');
verb(1,'...test passed');
%% EOF
