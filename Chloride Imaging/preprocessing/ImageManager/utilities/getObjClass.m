function y = getObjClass(x,app)
    y = '';
    try
        eval(['y = class(app.' x ');'])
    end
end