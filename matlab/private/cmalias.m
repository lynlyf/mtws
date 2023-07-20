function varargout = cmalias(name)
%% parse color name
% usage:
%   colorname = cmalias('c1[,c2,...]'|{'c1','c2',...})
%   cmalias list % list available names
%
% see also: cmstore, rgb, css2rgb, colornames
%%
if nargin == 0
    subfcn_demo;
    return;
end

if ischar(name) && ismember(lower(name),{'list','show'})
    subfcn_list;
    return;
end

if ismember(',',name), name = strsplit(strrep(name,' ',''),','); end
if iscell(name)
    varargout{1} = cellfun(@cmalias,name,'uni',0);
    return;
end

if isscalar(name)
    alias = subfcn_alias1;
    name = alias.(name);
elseif length(name)==2
    name = subfcn_alias2(name);
elseif length(name)==3
    alias = subfcn_alias3;
    if isfield(alias,name), name = alias.(name); end
else
    % return as it is
end
varargout = {name};
%%

%% SUBFUNCTIONS
function alias = subfcn_alias1
%% alias dict for the short name of single char
alias = struct( ...
        'a','aquamarine', 'b','blue', 'c','cyan', 'd','darkgray', ...
        'e','grey', 'f','firebrick', 'g','green', 'h','khaki', ...
        'i','pink', 'j','dodgerblue', 'k','black', 'l','lightgray', ...
        'm','magenta', 'n','brown', 'o','orange', 'p','purple', ...
        'q','turquoise', 'r','red', 's','springgreen', 't','tomato', ...
        'u','royalblue', 'v','violet', 'w','white', 'x','darksalmon', ...
        'y','yellow', 'z','goldenrod');
%%

function name = subfcn_alias2(name)
%% parse short name of two chars
a12 = subfcn_alias12;
a1 = subfcn_alias1;
if isfield(a12,name(1)), c1 = a12.(name(1)); else, c1 = a1.(name(1)); end
if isfield(a12,name(2)), c2 = a12.(name(2)); else, c2 = a1.(name(2)); end    
name = [c1,c2]; 
%%

function alias = subfcn_alias12
%% alias dict for the short name of one of two chars
alias = struct('b','blue', 'c','cyan', 'd','dark', 'g','green', ...
    'h','hot', 'i','dim', 'k','gray', 'l','light', 'm','medium', 'n','brown', ...
    'o','orange', 'p','pale', 'q','turquoise', 'r','red', 's','slate', ...
    'v','violet', 'w','white', 'y','yellow');
%%

function alias = subfcn_alias3
%% alias dict for the short name of three chars
alias = struct( ...
    'alb','aliceblue', 'azr','azure', 'chl','chocolate', 'cht','chartreuse', 'crl','coral', ...
    'dgr','darkgoldenrod', 'dkh','darkkhaki', 'doc','darkorchid', 'dog','darkolivegreen', ...
    'dpk','deeppink', 'dsb','deepskyblue', 'dsg','darkseagreen', 'fbk','firebrick', ...
    'frg','forestgreen', 'gdr','goldenrod', 'hpk','hotpink', 'idr','indianred', ...
    'lcr','lightcoral', 'lng','lawngreen', 'lpk','lightpink', 'lsb','lightskyblue', ...
    'lsg','lightseagreen', 'skb','skyblue', 'slv','silver','spg','springgreen');
%%

function subfcn_list
%% show alias
fprintf('=== colorname alias1:\n');
subfcn_print(subfcn_alias1);
fprintf('=== colorname alias12:\n');
subfcn_print(subfcn_alias12);
fprintf('=== colorname alias3:\n');
subfcn_print(subfcn_alias3);
fprintf('=== EOL\n');
%%

function subfcn_print(a)
%% print an alias dict
a = reshape(arg2cell(a),2,[]);
a(1,:) = cellfun(@(x)sprintf('%4s',x),a(1,:),'uni',0);
fprintf('%s\n',strjoin(strcat(a(1,:),{' : '},a(2,:)),'\n'));
%%

function subfcn_demo
%% Builtin demo
verb(1,'run builtin demo of ',mfilename);
assert(isequal(cmalias('z'),'goldenrod'),'...test failed');
assert(isequal(cmalias('abc'),'abc'),'...test failed');
verb(1,'...test passed');
%% EOF
%       SHORT   NAME             RGB
%       r       red              [1   0   0  ]
%       o       orange           [1   0.5 0  ]
%       y       yellow           [1   1   0  ]
%       l       lawngreen        [0.5 1   0  ]
%       g       green            [0   1   0  ]
%       s       springgreen      [0   1   0.5]
%       c       cyan             [0   1   1  ]
%       a       azure            [0   0.5 1  ]
%       b       blue             [0   0   1  ]
%       v       violet           [0.5 0   1  ]
%       m       magenta          [1   0   1  ]
%       f       flower or rose   [1   0   0.5]
%       k       black            [0   0   0  ]
%       w       white            [1   1   1  ]
%%