function [Nomenclature] = NomenclatureOf(NodeName)
% NomenclatureOf(NodeName) - returns the nomenclature of the nodes
% 
% Syntax:  [Nomenclature] = NomenclatureOf(NodeName)
%
% 


% 1: initialize the output
    Nomenclature = string(zeros(size(NodeName)));
    Nomenclature = strrep(Nomenclature, "0", "");

% 2: preprocess the NodeName and get the Nomenclature list
    try
        NodeName = string(NodeName);
    catch ME
        ErrorMessage = ...
        "The input NodeName must be string or a cell array of strings." + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
    try
        NomenclatureList = GetNomenclatureList(0);
    catch ME
        ErrorMessage = "Failed to get the nomenclature list." + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
% 3: Judge Nomenclature one by one according to NodeName
    try
        for i = 1:numel(NodeName)
            Ok = 0;
            ThisNodeName = NodeName(i);
            try
                for j = 1:numel(NomenclatureList)
                    ThisNomenclature = NomenclatureList(j);
                    FuncName = ThisNomenclature + "_Check";
                    Func = str2func(FuncName);
                    ErrorMessage = '';
                    try
                        Ok = Func(ThisNodeName);
                    catch ME
                        ThisErrorMessage = ...
                        "Users-Defined Function: {" + FuncName + "()} can't be found. Or it contains errors." + newline;
                        ErrorMessage = ErrorMessage + ThisErrorMessage + CatchProcess(ME,1);
                    end
                    if Ok == 1
                        Nomenclature(i) = ThisNomenclature;
                        break;
                    end
                end
                if ~Ok
                    if ~isempty(ErrorMessage)
                        error(ErrorMessage);
                    end
                    ErrorMessage = "The node name {" + ThisNodeName + "} is not supported.";
                    error(ErrorMessage);
                end
            catch ME
                ErrorMessage = "Failed to judge the nomenclature of {" + ThisNodeName + "}." + newline;
                ErrorMessage = ErrorMessage + CatchProcess(ME,1);
                error(ErrorMessage);
            end
        end
    catch ME
        error(CatchProcess(ME,1));
    end
end
