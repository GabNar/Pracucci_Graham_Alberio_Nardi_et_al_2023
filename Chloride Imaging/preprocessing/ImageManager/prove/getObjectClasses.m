function y = getObjClass(x,app)
    if ~isempty(x)
        y = x.Class.Name;
    else
        y = '';
    end
end