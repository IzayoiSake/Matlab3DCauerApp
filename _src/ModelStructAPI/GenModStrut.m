function [ModelStruct]=GenModStrut(ModelStruct)
% GenModStrut() is used to generate the initial ModelStruct
% ModelStruct is a struct that contains all the information of the model

% 1: initialize the ErrorMessage
% 2: check the input

% 3: GenModStrut() Start
    if ModelStruct.Temp.State == "GenModStrut() Start"
        ModelStruct.Temp.State = "GenModStrut() GetNodeName";
    end
% 5: GenModStrut() GetNodeName
    try
        if ModelStruct.Temp.State == "GenModStrut() GetNodeName"
            % 5.1: get the NodeName
            NodeName = ModelStruct.Temp.NodeNameData;
            NodeName = SortNodeName(NodeName,"Layer");
            [NodeName] = ConvertNodeName(NodeName, ModelStruct.Temp.Nomenclature);
            NodeName = NodeName(:);
            ModelStruct.NodeName = NodeName;
            % 5.2: get the NodeNameEffective
            [~,Lay] = GetNodePosAndLay(NodeName);
            ModelStruct.LayerNum = max(Lay);
            Index = Lay ~= ModelStruct.LayerNum;
            NodeNameEffective = NodeName(Index);
            ModelStruct.NodeNameEffective = NodeNameEffective;
            ModelStruct.Temp.State = "GenModStrut() GetNodeLink";
            return
        end
    catch ME
        ErrorMessageNew = CatchProcess(ME);
        error(ErrorMessageNew)
    end
% 6: GenModStrut() GetNodeLink
    try
        if ModelStruct.Temp.State == "GenModStrut() GetNodeLink"
            % 6.1: get the NodeLink
            [NodeLink] = GetNodeLink(ModelStruct.NodeName,ModelStruct.Temp.LinkData);
            ModelStruct.NodeLink = NodeLink;
            ModelStruct.Temp.State = "GenModStrut() GenGrName";
            return
        end
    catch ME
        ErrorMessageNew = CatchProcess(ME);
        error(ErrorMessageNew)
    end
% 7: GenModStrut() GenGrName
    try
        if ModelStruct.Temp.State == "GenModStrut() GenGrName"
            % 7.1: generate the GrName
            ModelStruct = GenGrName(ModelStruct);
            ModelStruct.Temp.State = "GenModStrut() End";
            return
        end
    catch ME
        ErrorMessageNew = CatchProcess(ME);
        error(ErrorMessageNew)
    end
end
        




