function [id,err] = closest(A,b,flag)
%% [id,err] = closest(A,b,flag);
% return the indice of the first closest point in A to b
%
% input:
%   A: array
%   b: value(s) to find
%   flag: if flag=0 (default), choose the one with smallest abs(diff)
%         if flag<0, choose the closest one <= b, or nan if all > b
%         if flag>0, choose the closest one >= b, or nan if all < b
% output: 
%   id: index, size(id)=size(b)   
%   err: min absolute error
%
% see also: gridx
%%
if nargin == 0
    subfcn_demo;
    return;
end

A = A(:);
id = nan(size(b));
err = nan(size(b));
if nargin<3 || flag==0
    for ii = 1 : numel(b)
        [err(ii),id(ii)] = min(abs(A-b(ii))); 
    end
else
    for ii = 1 : numel(b)        
        d = flag * (A-b(ii));
        id1 = find(d>=0);
        if isempty(id1)
            [id(ii),err(ii)] = deal(nan,nan);
        else
            [err(ii),id2] = min(d(id1)); 
            id(ii) = id1(id2);
        end
    end
end
%%

%% SUBFUNCTIONS
function subfcn_demo
%% builtin demo
verb(1,'run builtin demo of ',mfilename);
assert(closest([3,2,5,4,6],5.4)==3,'test failed');
assert(closest([3,2,5,4,6],5.5)==3,'test failed');
assert(closest(1:10,5.5,-1)==5,'test failed');
assert(closest(1:10,5.5,1)==6,'test failed');
assert(isequal(closest(1:10,[4,5.4]),[4,5]),'test failed');
verb(1,'...test passed');
%% EOF
