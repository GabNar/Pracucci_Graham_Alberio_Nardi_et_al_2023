function SelTab2Clip(mytable,selectedIndices)
% Copies UItable selection to system clipboard
    % selectedIndices is a vector [a b c d], in which a and b are the
    % row and column number of the top-left element of the selection. c
    % and d are the row and column number of the bottom-right element.

    % by Enrico from ZebraExploreApp

%         To copy the data from a UItable to the clipboard
str = '';
for i = selectedIndices(1):selectedIndices(3) % rows
    for j = selectedIndices(2):selectedIndices(4) % columns
        tmp = mytable.Data{i,j};
        if isa(tmp,'cell')
            tmp = tmp{:};
        end
        if j == selectedIndices(4)
            if isa(tmp, 'char')
                str = sprintf('%s%s', str, tmp);
            else
                str = sprintf('%s%f',str,tmp);
            end
        else
            if isa(tmp, 'char')
                str = sprintf('%s%s\t', str,tmp);
            else
                str = sprintf('%s%f\t',str,tmp);
            end
        end
    end
    str = sprintf('%s\n',str);
end
clipboard('copy',str);
end
