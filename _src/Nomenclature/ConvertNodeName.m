function NodeNameOut = ConvertNodeName(NodeName, Nomenclature)
% ConvertNodeName(NodeName, Nomenclature) - Convert node name to a valid variable name
% 
% Syntax:  NodeNameOut = ConvertNodeName(NodeName, Nomenclature)
%
% 


% 1: Check inputs
    try
        NodeName = string(NodeName);
        Nomenclature = string(Nomenclature);
    catch ME
        ErrorMessage = "NodeName and Nomenclature must be string." + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
% 2: Get nomenclature list and check if nomenclature is valid
    try
        NomenclatureList = GetNomenclatureList(0);
        NodeNameDim = size(NodeName);
        NomenclatureDim = size(Nomenclature);
        EqualDim = NodeNameDim == NomenclatureDim;
        NomenToConvert = zeros(NodeNameDim);
        NomenToConvert = string(NomenToConvert);
        NomenToConvert = strrep(NomenToConvert,'0','');
        if ~all(EqualDim)
            NomenToConvert(:) = Nomenclature(1);
        else
            NomenToConvert = Nomenclature;
        end
        if ~all(ismember(NomenToConvert,NomenclatureList))
            ErrorMessage = "Nomenclature is not valid." + newline;
            error(ErrorMessage);
        end
    catch ME
        ErrorMessage = "Error 2 in ConvertNodeName." + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
% 3: Convert node name to a valid variable name
    try
        NodeNameOut = zeros(NodeNameDim);
        NodeNameOut = string(NodeNameOut);
        NodeNameOut = strrep(NodeNameOut,'0','');
        [Pos,Lay] = GetNodePosAndLay(NodeName);
        for i = 1:numel(NodeName)
            ThisPos = Pos(i);
            ThisLay = Lay(i);
            ThisNomenToConvert = NomenToConvert(i);
            FuncName = ThisNomenToConvert + "_Gen";
            Func = str2func(FuncName);
            try 
                ThisNodeNameOut = Func(ThisPos,ThisLay);
                NodeNameOut(i) = ThisNodeNameOut;
            catch ME
                ErrorMessage = ...
                "Users-Defined Function: {" + FuncName + "()} can't be found. Or it contains errors." + newline;
                ErrorMessage = ErrorMessage + CatchProcess(ME,1);
                error(ErrorMessage);
            end
        end
    catch ME
        ErrorMessage = "Error 3 in ConvertNodeName." + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
end
