function flag = iscstr(s)
%% flag = iscstr(s)
% True for cell array of all elements being character array or string
%
% see also: isstr; ischar, isstring, iscellstr
%%
flag = iscell(s) && all(cellfun(@isastr,s));
%% EOF
