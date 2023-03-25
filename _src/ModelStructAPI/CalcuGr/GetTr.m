function [Tr,TrName] = GetTr(ModelStruct)
% GetTr(ModelStruct,TherSimPath) - Get the Tr Matrix of one thermal simulation results file

% 1: initialize ErrorMessage

% 2: check the inputs
    try
        NodeName = ModelStruct.NodeName;
        NodeNameEffective = ModelStruct.NodeNameEffective;
        GrName = ModelStruct.GrName;
    catch ME
        ErrorMessage = "This ModelStruct does not contain the required fields" + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end


Tr = [];
TrName = [];
for k = 1:numel(ModelStruct.Temp.SteadyTemptData)
% 3: read the thermal simulation results file
    TherSimData = ModelStruct.Temp.SteadyTemptData{k};
    try
        TsHeader = TherSimData(1,:);
        TsData = TherSimData(2:end,:);
        Nomenclature = ModelStruct.Temp.Nomenclature;
        TsHeader = ConvertNodeName(TsHeader,Nomenclature);
        [TsHeader,Index] = SortByNodeName(TsHeader,NodeName);
        TsData = TsData(:,Index);
        TsData = double(TsData);
    catch ME
        ErrorMessage = "Unkonw error" + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
% 4: Process in the order of NodeName
    try
        ThisTr = zeros(length(NodeNameEffective),length(NodeNameEffective));
        ThisTrName = zeros(length(NodeNameEffective),length(NodeNameEffective));
        ThisTrName = string(ThisTrName);
        ThisTrName = strrep(ThisTrName,"0","");
        for i = 1:length(NodeNameEffective)
            % Find the row with the element in GrName equal to NodeName(i)
            Index = zeros(size(GrName,1),1);
            LinkNode = zeros(size(GrName,1),1);
            LinkNode  =  string(LinkNode);
            LinkNode  =  strrep(LinkNode,"0",'');
            for j = 1:size(GrName,1)
                if GrName(j,1) == NodeNameEffective(i)
                    Index(j) = 1;
                    LinkNode(j) = GrName(j,2);
                elseif GrName(j,2) == NodeNameEffective(i)
                    Index(j) = 1;
                    LinkNode(j) = GrName(j,1);
                end
            end
            Index = find(Index);
            LinkNode = LinkNode(Index);
            % Get the temperature of the current node
            % Find the position of NodeName(i) in TsHeader
            Index1 = TsHeader == NodeNameEffective(i);
            TCNode = TsData(:,Index1);
            % Get the temperature of the link node
            % Find the position of LinkNode in TsHeader
            Index2 = zeros(length(LinkNode),1);
            try
                for j = 1:length(LinkNode)
                    Index2(j) = find(ismember(TsHeader,LinkNode(j)));
                end
            catch
                ErrorMessage = "The thermal simulation results file is not complete" + newline;
                ErrorMessage = ErrorMessage + CatchProcess(ME,1);
                error(ErrorMessage);
            end
            TLNode = TsData(:,Index2);
            % Calculate the difference between the value of TCNode and each element of TLNode
            dT = TCNode-TLNode;
            % Fill dT to Tr(i,:) according to Index
            ThisTr(i,Index) = dT;
            % Replace each element of LinkNode with "(" + NodeName(i) + ")" + "-" + "(" + LinkNode + ")"
            for j = 1:length(LinkNode)
                ThisTrName(i,Index(j)) = "(" + NodeNameEffective(i) + ")" + "-" + "(" + LinkNode(j) + ")";
            end
        end
        ThisTr = double(ThisTr);
        ThisTrName = string(ThisTrName);
    catch ME
        ErrorMessage = "Unexpected error" + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
    Tr = [Tr;ThisTr];
    TrName = [TrName;ThisTrName];
end
    
    
end


