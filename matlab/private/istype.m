function flag = istype(x,types)
%% 
% Check if being the specific type(s)
% usage:
%   flag = istype(x,'type'|{'type1',...})
%   dict = istype
%
% * 'type' could be case sensitive in case of capital letters
%
%% example:
% > istype(1,'num')
% > istype(struct(),{'struct','containers.Map'})
%
% see also: isastr, iscstr; isa, isgraphics, ishghandle
%%
if nargin == 1
    flag = subfcn_dict;
    return;
end

if isastr(types) %(x,'type')
    tp = string(parse_alias(subfcn_dict,lower(types)));
    if tp == "cellstr"
        flag = iscstr(x);
    elseif tp == "astr"
        flag = isastr(x);
    else
        flag = isa(x,tp);
    end
    return;
end

if iscell(types) %(x,{'type1',...})
    flag = false;
    for ii = 1 : length(types)
        flag = flag || istype(x,types{ii});
        if flag, break; end
    end
    return;
end

%(x,obj); check if x is the same type as obj (obj cannot be cell array)
flag = isa(x,class(types));
%%

%% SUBFUNCTION
function d = subfcn_dict
%% return a classname alias dict
d = {'matlab.ui.Figure',{'f','fig','figure'}, ...
     'matlab.graphics.axis.Axes',{'a','ax','axes'}, ...
     'matlab.graphics.axis.decorator.NumericRuler',{'ruler','numericruler'}, ...
     'matlab.graphics.illustration.ColorBar',{'cb','cbar','colorbar'}, ...
     'matlab.graphics.illustration.Legend',{'lg','legend'}, ...
     'matlab.graphics.primitive.Text',{'t','txt','text'}, ...
     'matlab.graphics.chart.primitive.Line',{'l','line'}, ...
     'matlab.graphics.chart.primitive.Scatter',{'sc','scatter'}, ...
     'matlab.graphics.primitive.Patch',{'patch'}, ...
     'matlab.graphics.shape.internal.AnnotationPane',{'ap','annotation'}, ...
     'char',{'c'}, ...
     'numeric',{'n','num'}, ...
     'cellstr',{'cs','cstr'}, ...
     'string',{'s','str'}, ...
     'struct',{'st'}, ...
     'containers.Map',{'d','dict','containers.map'}, ...
     'table',{'tab'}, ...
     'timetable',{'ttab'}, ...
     'function_handle',{'fun','func','fcn','function'}, ...
     };
%% EOF
