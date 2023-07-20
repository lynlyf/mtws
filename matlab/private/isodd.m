function flag = isodd(n)
%% flag = isodd(n)
% check if n (scalar or array) is odd
%%%
if ~isnumeric(n)
    n = length(n);
end
flag = mod(n,2)==1;
%% EOF
