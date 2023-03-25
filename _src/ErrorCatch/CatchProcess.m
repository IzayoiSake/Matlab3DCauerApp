function [ErrorMessage] = CatchProcess(ME, Type)
%CatchProcess - Catch the error message and display it in the command window
    if ~exist('Type', 'var')
        Type = 0;
    end
    if Type == 0
        Num = length(ME.stack);
        for i = Num : -1 : 1
            ErrorMessage = string(ME.stack(i).name) + "()  " + ...
                "{Line:" + string(ME.stack(i).line) + "}" + newline;
        end
        ErrorMessage = ErrorMessage + ME.message;
    elseif Type == 1
        ErrorMessage = string(ME.stack(1).name) + "()  " + ...
            "{Line:" + string(ME.stack(1).line) + "}" + newline + ME.message;
    end
end