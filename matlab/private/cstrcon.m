function s = cstrcon(varargin)
%% s = cstrcon(cs1,cs2,...)
% concat strings chosen from each cell string (all combinations; not corresponding ones)
%
% example:
%   > cstrcon('ab',0,1:2) % ab01, ab02
%   > cstrcon({'a','b'},0,1:3) % a01, a02, a03, b01, b02, b03
%   > cstrcon({'a','b'},{'c','d','e'}) % ac, ad, ae, bc, bd, be
%   > cstrcon({'a1','a2'},'.',{'b1','b2'}) % a1.b1, a1.b2, a2.b1, a2.b2
% see also: strjoin, strsplit; strcon
%% 
narg = length(varargin);
for ii = 1 : narg % make all args cellstr
    if ischar(varargin{ii})
        varargin{ii} = varargin(ii); 
    elseif isnumeric(varargin{ii})
        varargin{ii} = num2cstr(varargin{ii});
    elseif ~iscellstr(varargin{ii})
        error('wrong inputs');
    end
end
    
n  = cellfun(@length, varargin); % number of elements of all cellstrs
id = ndperm(n);
ntot = size(id, 1);
s = repmat({''}, ntot, 1);
for ii = 1 : ntot
    for jj = 1 : narg
        s{ii} = [s{ii}, varargin{jj}{id(ii,jj)}];
    end
end
%% EOF
