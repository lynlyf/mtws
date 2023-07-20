function x = splitbypct(n,pct,method)
%% x = splitbypct(n,pct)
% split n samples to segments occupy pct length
% 
% input:
%   n: total number to divide
%   pct: sum(pct)=1
% output: vector of length of segments; sum(x)=n
%
% see also: 
%%
if nargin == 0
    subfcn_demo;
    return;
end

assert(n==fix(n)&&n>=numel(pct),'n must be positive integer');
assert(abs(sum(pct)-1)<1e-3/n,'sum(pct) should be 1');
if nargin<3 || isequal(0,method)
    x = subfcn_loop(n,pct);
else
    x = subfcn_adjustmax(n,pct);
end
%%

%% SUBFUNCTIONS
function x = subfcn_loop(n,pct)
%% 
x = n * pct;
y = fix(x);
r = x - y;
for ii = 1 : length(r)-1
    [r(ii),r(ii+1)] = deal(fix(r(ii)),r(ii+1)+r(ii)-fix(r(ii)));    
end
x = fix(y + r);
%%

function x = subfcn_adjustmax(n,pct)
%% 
x = round(n.*pct) ;
d = sum(x) - n ;
if d ~= 0 % adjust the largest segment
    [~,id] = max(x) ; 
    x(id) = x(id) - d ;
end
%%

function subfcn_demo
%% Builtin demo
verb(1,'run builtin demo of ',mfilename);
assert(isequal(splitbypct(100,[1/3,1/4,5/12]),[33,25,42]),'test failed');
assert(isequal(splitbypct(100,[1/3,1/4,5/12],1),[33,25,42]),'test failed');
verb(1,'...test passed');
%% EOF