function b = num2cstr(a,fmt)
%% b = num2cstr(a[,fmt])
% convert numbers to cellstr
%%
if nargin == 0
    subfcn_demo;
    return;
end

b = cell(size(a));
for ii = 1 : numel(a)
    if nargin<2 || isempty(fmt)
        b{ii} = num2str(a(ii));
    else
        b{ii} = sprintf(fmt,a(ii));
    end
end
%%

%% SUBFUNCTION
function subfcn_demo
%% builtin demo
verb(1,'run builtin demo of ',mfilename);
b = num2cstr([32,234,132]);
assert(isequal(b,{'32','234','132'}),'test failed');
verb(1,'...test passed');
%% EOF