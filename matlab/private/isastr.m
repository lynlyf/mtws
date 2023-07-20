function flag = isastr(s)
%% flag = isastr(s)
% True for character array or string
%
% see also: iscstr; ischar, isstring, iscellstr
%%
flag = ischar(s) || isstring(s);
%% EOF
