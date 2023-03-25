function [Pos,Lay] = GetNodePosAndLay(NodeName)
% GetNodePosAndLay(NodeName) - Get the position and layer of a node
% 
% Syntax: [Pos,Lay] = GetNodePosAndLay(NodeName)

% Author(s): Yuankai Gong

% 1: check the input(s)
    try
        NodeName = string(NodeName);
        NodeNameDim = size(NodeName);
    catch ME
        ErrorMessage = "NodeName must be string type." + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
    
% 2: initilize the output(s)
    Pos = zeros(NodeNameDim);
    Lay = zeros(NodeNameDim);

% 3: get the NomenclatureList
    try
        NomenclatureList = GetNomenclatureList(0);
    catch
        ErrorMessage = "GetNomenclatureList failed." + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
% 4: get the position and layer of the node
    try
        Ok = 0;
        for i = 1:numel(NodeName)
            ThisNodeName = NodeName(i);
            ErrorMessage = '';
            for j = 1:numel(NomenclatureList)
                ThisNomenclature = NomenclatureList(j);
                FuncName = ThisNomenclature + "_Check";
                try
                    Func = str2func(FuncName);
                    [Ok,ThisPos,ThisLay] = Func(ThisNodeName);
                    ThisPos = double(ThisPos);
                    ThisLay = double(ThisLay);
                catch ME
                    Ok = 0;
                    ThisErrorMessage = ...
                    "Users-Defined Function: {" + FuncName + "()} can't be found. Or it contains errors." + newline;
                    ErrorMessage = ErrorMessage + ThisErrorMessage + CatchProcess(ME,1);
                end
                if Ok
                    Pos(i) = ThisPos;
                    Lay(i) = ThisLay;
                    break
                end
            end
            if ~Ok
                if ~isempty(ErrorMessage)
                    error(ErrorMessage);
                end
                ErrorMessage = "The node name {" + ThisNodeName + "} is not supported.";
                error(ErrorMessage);
            end
        end
    catch ME
        ErrorMessage = "GetNodePosAndLay failed." + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
end