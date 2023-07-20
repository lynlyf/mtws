function n = cmndims(cmap)
%% nd = cmndims(cmap); 
% output number of dimensions of colormap
% 0 : not a colormap
% 1 : regular colormap of size [m,3]
% 2 : an image of colormap of size [m1,m2,3]
% see also: cmindex, cmstore, cmtest
%%
if nargin == 0
    subfcn_demo;
    return;
end

n = 0;
if isempty(cmap), return; end
sz = size(cmap);
nd = ndims(cmap);
if sz(nd)~=3, return; end
n = nd - 1;
%% 

%% SUBFUNCTION
function subfcn_demo
%% Builtin demo
verb(1,'run builtin demo of ',mfilename);
assert(cmndims(rand(2,2))==0,'...test failed');
assert(cmndims(rand(12,3))==1,'...test failed');
assert(cmndims(rand(12,16,3))==2,'...test failed');
verb(1,'...test passed');
%% EOF