function outp = hsm_(data)
    outp = [];
    if numel(data) == 1
        outp = data(1);
    elseif numel(data) == 2
        outp = mean(data(:));
    elseif numel(data) == 3
        i1 = data(2) - data(1);
        i2 = data(3) - data(2);
        if i1 < i2
            outp = mean(data(1:2));
        elseif i2 > i1
            outp = mean(data(2:end));
        else
            outp = data(2);
        end
    else
        
%         if any(data~=-100)
%             disp('now')
%         end
        
        % wMin = data[-1] - data[0]
        wMin = inf;
        N = idivide(int32(numel(data)),2,'floor') + mod(numel(data),2)-1;

        for i = 1:N
            w = data(i + N - 1) - data(i);
            if w < wMin
                wMin = w;
                j = i;
            end
        end
        outp = hsm_(data(j:j + N));
    end
end