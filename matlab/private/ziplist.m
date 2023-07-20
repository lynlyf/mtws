function z = ziplist(varargin)
%% z = ziplist(v1,v2,...)
% similar to python's `zip` function
% z{ii} = {..,vn{ii}|vn(ii),...}
%%
n = nargin;
l = cellfun(@length,varargin);
z = cell(1,max(l));
for ii = 1 : l
    z{ii} = cell(1,n);
    for jj = 1 : n
        assert(isvector(varargin{jj}),'args should be scalar or vector');
        if iscell(varargin{jj})
            if isscalar(varargin{jj})
                z{ii}{jj} = varargin{jj}{1};
            else
                z{ii}{jj} = varargin{jj}{ii};
            end
        else
            if isscalar(varargin{jj})
                z{ii}{jj} = varargin{jj};
            else
                z{ii}{jj} = varargin{jj}(ii);
            end
        end
    end
end
%% EOF