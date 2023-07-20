function txtsave(f,s,mode,newlines)
%% txtsave(filename,str,mode[,newlines]);
% write|add str or cellstr to a text file
%
% input:
%   f: filepath
%      if not a str, output `s` on screen
%   s: str to print
%   mode: 'w|a' (default,'a')
%   newlines: number of newlines to add after str (default,0)
% 
% example:
%  > txtsave('log.txt','test');
%%
if nargin<3||isempty(mode), mode = 'a'; end
if nargin<4, newlines = 0; end
if iscellstr(s), s = strjoin(s,'\n'); end
assert(ischar(s),'wrong text');
fid = 1;
ME = [];
try
    if ~isempty(f) && ischar(f)
        fid = fopen(f,mode); 
    elseif length(s)>5e3 % avoid print too long text on screen
        s = [s(1:2500),'\n\n ...... \n\n',s(end-2500:end)];
    end
    fprintf(fid,['%s',repmat('\n',1,newlines)],s);
catch ME
    fprintf('** error: %s\n',ME.message);
end
if ischar(f), fclose(fid); end
if ~isempty(ME), rethrow(ME); end
%% EOF