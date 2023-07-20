function status = strmate(s,pat,opt)
%% status = strmate(s,pat,opt)
% alternative to `strfind|strmatch|str[n]cmp[i]|validatestring|starsWith|endsWith`
%
% input:
%   s: string or cellstr
%   pat: pattern to match
%   opt: option
%     '[f]ind|[c]ontain': find pattern in str (default)
%     'fi|ci': find pattern in str (case-insensitive)
%     '[b]egin|[s]tart': starts with pattern 
%     'si|bi': starts with pattern (case-insensitive)
%     '[e]nd': ends with pattern 
%     'ei': ends with pattern (case-insensitive)
% output: true|false
%
%% example:
% > strmate(s,'abc') % check if s contains 'abc'
% > strmate(s,'abc','fi') % check if s contains 'abc' (ignore case)
% > strmate(s,'abc','b') % check if s contains 'abc'
%
% see also: strcut, strinstr;
%           strfind, strmatch, str[n]cmp[i], start|endsWith
%% 
if nargin<3, opt = 'f'; end

if iscell(s)
    status = cellfun(@(x)strmate(x,pat,opt),s);
    return;
end

assert(ischar(s)&&ischar(pat),'wrong input');
n = length(pat);
if length(s) < n
    status = false;
    return;
end

switch lower(opt)
    case {'f','find','c','contain'} % find pat in str
        status = ~isempty(strfind(s,pat)); %#ok
        %status = contains(s,pat);
    case {'fi','ci'} % ignore case
        status = ~isempty(strfind(lower(s),lower(pat))); %#ok
        %status = contains(lower(s),lower(pat));
    case {'s','start','b','begin'} % start with
        status = isequal(s(1:n),pat);
    case {'si','bi'} % ignore case
        status = isequal(lower(s(1:n)),lower(pat));
    case {'e','end'} % end with
        status = isequal(s(end-n+1:end),pat);
    case {'ei'} % ignore case
        status = isequal(lower(s(end-n+1:end)),lower(pat));
    otherwise
        error('unknonw opt');
end
%% EOF
