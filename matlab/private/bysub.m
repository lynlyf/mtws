function B = bysub(varargin)
%% get|set|remove subarray
% usage: B = ...
%   bysub(A,i1,i2,...)  % returns A(i1,i2,...)
%   bysub(A,{i1,i2,...}) % returns A(i1(k),i2(k),...)
%   bysub('[g]et',A,...)
%   bysub('[s]et',A,...,val)
%   bysub('[g]et','char_array',irange)
%   bysub('[c]ell',{...},...)
%
% notes:
%  * to strip all elements along a dim, pass ':'
%  * `bysub('char_array',...)` is not feasible
%
% input:
%   A: numerical array | char array | 1D cell array
%   opt: '[g]et|[s]et|[d]elete|[r]emove'
%   iX: index along dim X
% output:
%   B: output array
%
% see also: islice; subsref
%%
if nargin == 0
    subfcn_demo;
    return
end

[opt,A,args] = subfcn_parse(varargin{:});
switch opt
    case {'g','get','slice'} %('g',A,i1,i2,...)
        B = subfcn_slice(A,args{:});
    case {'s','set'} %('s',A,i1,i2,..,iN,value)
        B = A;
        B(args{1:end-1}) = args{end};
    case {'c','cell'} %('c',A,i); return A{i}
        assert(isvector(A),'only 1D cell array is supported');
        B = A{args{:}};
    otherwise
        error('todo');
end
%%

%% FUNCTIONS
function varargout = subfcn_parse(varargin)
%% parse input and return opt, A, args
if ischar(varargin{1}) % (opt,A,...)
    varargout = {lower(varargin{1}),varargin{2},varargin(3:end)};
else % (A,...)
    varargout = {'g',varargin{1},varargin(2:end)};
end
%%

function B = subfcn_slice(A,varargin)
%% slice array
if isscalar(varargin) && iscell(varargin{1}) % (A,{id1,id2,...})
    sz = size(A);
    ss = varargin{1}; % subscripts
    ia = strcmp(ss,':');
    if ~any(ia)
        id = sub2ind(sz,ss{:});   
        B = A(id);     
    else
        ib = find(~ia);        
        k = length(ss{ib(1)});
        b = cell(1,k);
        for ii = 1 : k
            id = repmat({':'},1,length(sz));
            for jj = 1:length(ib), id{ib(jj)} = ss{ib(jj)}(ii); end
            b{ii} = squeeze(A(id{:}));
        end
        B = squeeze(cat(ndims(b{1})+1,b{:}));
    end        
    return;
end
B = squeeze(A(varargin{:}));
%%

function subfcn_demo
%% builtin demo
verb(1,'run builtin demo of ',mfilename);
A = permute(reshape(1:60,5,4,3),[2,1,3]); % size=[4,5,3]
assert(isequal(bysub(A,2:3,':',1),[6:10;11:15]),'test failed');
assert(isequal(bysub(A,{2:3,1:2,1:2}),[6,32]),'test failed');
assert(isequal(bysub(A,{2:3,':',1:2}),[6:10;31:35].'),'test failed');
assert(isequal(bysub('c',{'a','b'},2),'b'),'test failed');
verb(1,'...test passed');
%% EOF
