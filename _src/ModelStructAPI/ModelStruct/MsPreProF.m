function ModelStruct = MsPreProF(ModelStruct)
    if ModelStruct.Temp.State == "Preprocess Files"
        CheckFiles(ModelStruct.Temp);
        ModelStruct.Temp = PreprocessFiles(ModelStruct.Temp);
        ModelStruct.Message = ModelStruct.Message + "Files are checked and data are preprocessed." + newline;
    end
end




function CheckFiles(Temp)
% check if the files exist
% NodeNamePath LinkPath SteadyPowerPath SteadyTemptPath TransPowerPath TransTemptPath
    ErrorMessage = "";
    if numel(Temp.LinkPath) == 0
        ErrorMessage = ErrorMessage + " The ""LinkPath"" is invalid." + newline;
        ErrorMessage = ErrorMessage + "Please select a LinkFile." + newline;
        error(ErrorMessage);
    end
    for i = 1: numel(Temp.LinkPath)
        if ~exist(Temp.LinkPath{i},'file')
            ErrorMessage = ErrorMessage + " The ""LinkPath"" is invalid." + newline;
            ErrorMessage = ErrorMessage + " The file " + Temp.LinkPath{i} + " does not exist." + newline;
            error(ErrorMessage);
        end
    end
    if numel(Temp.NodeNamePath) == 0
        ErrorMessage = ErrorMessage + " The ""NodeNamePath"" is invalid." + newline;
        ErrorMessage = ErrorMessage + "Please select a NodeNameFile." + newline;
        error(ErrorMessage);
    end
    for i = 1:numel(Temp.NodeNamePath)
        if ~exist(Temp.NodeNamePath{i},'file')
            ErrorMessage = ErrorMessage + " The ""NodeNamePath"" is invalid." + newline;
            ErrorMessage = ErrorMessage + " The file " + Temp.NodeNamePath{i} + " does not exist." + newline;
            error(ErrorMessage);
        end
    end
    if numel(Temp.SteadyPowerPath) == 0
        ErrorMessage = ErrorMessage + " The ""SteadyPowerPath"" is invalid." + newline;
        ErrorMessage = ErrorMessage + "Please select a SteadyPowerFile." + newline;
        error(ErrorMessage);
    end
    for i = 1:numel(Temp.SteadyPowerPath)
        if ~exist(Temp.SteadyPowerPath{i},'file')
            ErrorMessage = ErrorMessage + " The ""SteadyPowerPath"" is invalid." + newline;
            ErrorMessage = ErrorMessage + " The file " + Temp.SteadyPowerPath{i} + " does not exist." + newline;
            error(ErrorMessage);
        end
    end
    if numel(Temp.SteadyTemptPath) == 0
        ErrorMessage = ErrorMessage + " The ""SteadyTemptPath"" is invalid." + newline;
        ErrorMessage = ErrorMessage + "Please select one or more SteadyTemptFile." + newline;
        error(ErrorMessage);
    end
    for i = 1:numel(Temp.SteadyTemptPath)
        if ~exist(Temp.SteadyTemptPath{i},'file')
            ErrorMessage = ErrorMessage + " The ""SteadyTemptPath"" is invalid." + newline;
            ErrorMessage = ErrorMessage + " The file " + Temp.SteadyTemptPath{i} + " does not exist." + newline;
            error(ErrorMessage);
        end
    end
    if numel(Temp.TransPowerPath) == 0
        ErrorMessage = ErrorMessage + " The ""TransPowerPath"" is invalid." + newline;
        ErrorMessage = ErrorMessage + "Please select a TransPowerFile." + newline;
        error(ErrorMessage);
    end
    for i = 1:numel(Temp.TransPowerPath)
        if ~exist(Temp.TransPowerPath{i},'file')
            ErrorMessage = ErrorMessage + " The ""TransPowerPath"" is invalid." + newline;
            ErrorMessage = ErrorMessage + " The file " + Temp.TransPowerPath{i} + " does not exist." + newline;
            error(ErrorMessage);
        end
    end
    if numel(Temp.TransTemptPath) == 0
        ErrorMessage = ErrorMessage + " The ""TransTemptPath"" is invalid." + newline;
        ErrorMessage = ErrorMessage + "Please select a TransTemptFile." + newline;
        error(ErrorMessage);
    end
    for i = 1:numel(Temp.TransTemptPath)
        if ~exist(Temp.TransTemptPath{i},'file')
            ErrorMessage = ErrorMessage + " The ""TransTemptPath"" is invalid." + newline;
            ErrorMessage = ErrorMessage + " The file " + Temp.TransTemptPath{i} + " does not exist." + newline;
            error(ErrorMessage);
        end
    end
end




function Temp = PreprocessFiles(Temp)
% Preprocess the Data of files
    ErrorMessage = "";
% 1: NodeNamePath
    try
        [NodeNameData,Type] = ReadFile(Temp.NodeNamePath{1});
    catch ME
        ErrorMessage = ErrorMessage + " The ""NodeNameFile"" is corrupted." + newline;
        ErrorMessage = ErrorMessage + " The file " + Temp.NodeNamePath{1} + " is corrupted." + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
    if ~strcmp(Type,"NS") && ~strcmp(Type,"STS")
        ErrorMessage = ErrorMessage + " The ""NodeNameFile"" is corrupted." + newline;
        ErrorMessage = ErrorMessage + " The file " + Temp.NodeNamePath{1} + " is not a NodeNameFile." + newline;
        error(ErrorMessage);
    elseif strcmp(Type,"NS")
        NodeNameData = string(NodeNameData);
    elseif strcmp(Type,"STS")
        NodeNameData = string(NodeNameData(1,:));
    end
    try
        NodeNameData = ConvertNodeName(NodeNameData,Temp.Nomenclature);
        NodeNameData = SortNodeName(NodeNameData);
    catch ME
        ErrorMessage = ErrorMessage + " The ""NodeNameFile"" contains invalid data." + newline;
        ErrorMessage = ErrorMessage + " The file " + Temp.NodeNamePath{1} + " contains invalid data." + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
    Temp.NodeNameData = NodeNameData(:);
% 2: LinkPath
    try
        [LinkData,Type] = ReadFile(Temp.LinkPath{1});
    catch ME
        ErrorMessage = ErrorMessage + " The ""LinkFile"" is corrupted." + newline;
        ErrorMessage = ErrorMessage + " The file " + Temp.LinkPath{1} + " is corrupted." + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
    if ~strcmp(Type,"NCS")
        ErrorMessage = ErrorMessage + " The ""LinkFile"" is corrupted." + newline;
        ErrorMessage = ErrorMessage + " The file " + Temp.LinkPath{1} + " is not a LinkFile." + newline;
        error(ErrorMessage);
    else
        Temp.LinkData = LinkData;
    end
% 3: SteadyPowerPath
    try
        [SteadyPowerData,Type] = ReadFile(Temp.SteadyPowerPath{1});
    catch ME
        ErrorMessage = ErrorMessage + " The ""SteadyPowerFile"" is corrupted." + newline;
        ErrorMessage = ErrorMessage + " The file " + Temp.SteadyPowerPath{1} + " is corrupted." + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
    if ~strcmp(Type,"SPS")
        ErrorMessage = ErrorMessage + " The ""SteadyPowerFile"" is corrupted." + newline;
        ErrorMessage = ErrorMessage + " The file " + Temp.SteadyPowerPath{1} + " is not a SteadyPowerFile." + newline;
        error(ErrorMessage);
    else
        Temp.SteadyPowerData = SteadyPowerData;
    end
% 4: SteadyTemptPath
    try
        Type = zeros(numel(Temp.SteadyTemptPath),1);
        Type = string(Type);
        Type = strrep(Type,"0","");
        SteadyTemptData = cell(numel(Temp.SteadyTemptPath),1);
        for i = 1:numel(Temp.SteadyTemptPath)
            [SteadyTemptData{i},Type(i)] = ReadFile(Temp.SteadyTemptPath{i});
        end
    catch ME
        ErrorMessage = ErrorMessage + " The ""SteadyTemptFile"" is corrupted." + newline;
        ErrorMessage = ErrorMessage + " The file " + Temp.SteadyTemptPath{i} + " is corrupted." + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
    for i = 1:numel(Temp.SteadyTemptPath)
        if ~strcmp(Type(i),"STS")
            ErrorMessage = ErrorMessage + " The ""SteadyTemptFile"" is corrupted." + newline;
            ErrorMessage = ErrorMessage + " The file " + Temp.SteadyTemptPath{i} + " is not a SteadyTemptFile." + newline;
            error(ErrorMessage);
        end
    end
    Temp.SteadyTemptData = SteadyTemptData;
% 5: TransPowerPath
    try
        [TransPowerData,Type] = ReadFile(Temp.TransPowerPath{1});
    catch ME
        ErrorMessage = ErrorMessage + " The ""TransPowerFile"" is corrupted." + newline;
        ErrorMessage = ErrorMessage + " The file " + Temp.TransPowerPath{1} + " is corrupted." + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
    if ~strcmp(Type,"TPS")
        ErrorMessage = ErrorMessage + " The ""TransPowerFile"" is corrupted." + newline;
        ErrorMessage = ErrorMessage + " The file " + Temp.TransPowerPath{1} + " is not a TransPowerFile." + newline;
        error(ErrorMessage);
    else
        Temp.TransPowerData = TransPowerData;
    end
% 6: TransTemptPath
    try 
        [TransTemptData,Type] = ReadFile(Temp.TransTemptPath{1});
    catch ME
        ErrorMessage = ErrorMessage + " The ""TransTemptFile"" is corrupted." + newline;
        ErrorMessage = ErrorMessage + " The file " + Temp.TransTemptPath{1} + " is corrupted." + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
    if ~strcmp(Type,"TTS")
        ErrorMessage = ErrorMessage + " The ""TransTemptFile"" is corrupted." + newline;
        ErrorMessage = ErrorMessage + " The file " + Temp.TransTemptData{1} + " is corrupted." + newline;
        error(ErrorMessage);
    else
        Temp.TransTemptData = TransTemptData;
    end
% Final: Check if the Power and Thermal Data are valid
    % 1: NodeNameData
    try
        [Pos,Lay] = GetNodePosAndLay(Temp.NodeNameData);
    catch ME
        ErrorMessage = ErrorMessage + "The ""NodeNameFile"" contains invalid data." + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
    NodeNameInfo = [Pos,Lay];
    % 2: LinkData
    % 3: SteadyPowerData
    Header = Temp.SteadyPowerData(2:end,1);
    try 
        [Pos,Lay] = GetNodePosAndLay(Header);
    catch ME
        ErrorMessage = ErrorMessage + "The ""SteadyPowerFile"" contains invalid data." + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
    % 4: SteadyTemptData
    for i = 1:numel(Temp.SteadyTemptData)
        Header = Temp.SteadyTemptData{i}(1,:);
        try
            [Pos,Lay] = GetNodePosAndLay(Header(:));
        catch ME
            ErrorMessage = ErrorMessage + "The ""SteadyTemptFile"" contains invalid data." + newline;
            ErrorMessage = ErrorMessage + CatchProcess(ME,1);
            error(ErrorMessage);
        end
        HeaderInfo = [Pos,Lay];
        for j = 1:numel(Temp.NodeNameData)
            if ~ismember(NodeNameInfo(j,:),HeaderInfo,'rows')
                ErrorMessage = ErrorMessage + "The ""SteadyTemptFile(" + i + ")"" doesn't match the ""NodeNameFile""." + newline;
                ErrorMessage = ErrorMessage + "The node " + Temp.NodeNameData{j} + " is not in the SteadyTemptFile." + newline;
                error(ErrorMessage);
            end
        end
    end
    % 5: TransPowerPath
    Header = Temp.TransPowerData(1,2:end);
    try 
        [Pos,Lay] = GetNodePosAndLay(Header(:));
    catch ME
        ErrorMessage = ErrorMessage + "The ""TransPowerFile"" contains invalid data." + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
    HeaderInfo = [Pos,Lay];
    for i = 1:numel(Temp.NodeNameData)
        if ~ismember(NodeNameInfo(i,:),HeaderInfo,'rows')
            ErrorMessage = ErrorMessage + "The ""TransPowerFile"" doesn't match the ""NodeNameFile""." + newline;
            ErrorMessage = ErrorMessage + "The node " + Temp.NodeNameData{i} + " is not in the TransPowerFile." + newline;
            error(ErrorMessage);
        end
    end
    
    % 6: TransTemptPath
    Header = Temp.TransTemptData(1,2:end);
    try 
        [Pos,Lay] = GetNodePosAndLay(Header(:));
    catch ME
        ErrorMessage = ErrorMessage + "The ""TransTemptFile"" contains invalid data." + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
    HeaderInfo = [Pos,Lay];
    for i = 1:numel(Temp.NodeNameData)
        if ~ismember(NodeNameInfo(i,:),HeaderInfo,'rows')
            ErrorMessage = ErrorMessage + "The ""TransTemptFile"" doesn't match the ""NodeNameFile""." + newline;
            ErrorMessage = ErrorMessage + "The node " + Temp.NodeNameData{i} + " is not in the TransTemptFile." + newline;
            error(ErrorMessage);
        end
    end
    
end
    
    