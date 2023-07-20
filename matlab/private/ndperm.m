function id = ndperm(varargin)
%% id = ndperm([n1,n2,...]);
% make complete set of index for ndarray
%
% n(k) means the length of the k-th vector, 1:n(k)
% each row of id consisits of one digit chosen from each vector
% the output is the cartesian prodect.
%
% e.g., 
%  > ndperm([2,3]) % [1,1; 1,2; 1,3; 2,1; 2,2; 2,3]
% see also: cartprod
%%
if nargin == 0
    subfcn_demo;
    return;
end

if nargin==1, n = fix(varargin{1}); else n = fix([varargin{:}]); end

assert(all(n>0),'n(i) must be positive integers');

len = length(n);
if len == 1
    id = 1 : n;
    return;
end

id = nan(prod(n), len);
for ii = 1 : len
    x = repelem(1:n(ii), 1, prod(n(ii+1:end)));
    id(:,ii) = repmat(x, 1, prod(n(1:ii-1))); % thanks to prod([])=1
end
%%

%% SUBFUNCTIONS
function subfcn_demo
%% builtin demo
verb(1,'run builtin demo of ',mfilename);
assert(isequal(ndperm([2,3]),[1,1;1,2;1,3;2,1;2,2;2,3]),'test failed'); 
verb(1,'...test passed');
%% EOF
