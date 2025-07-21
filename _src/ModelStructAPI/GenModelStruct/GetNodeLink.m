function [NodeLink] = GetNodeLink(NodeName,LinkData)
% GetNodeLink(NodeName,LinkPath) - Get the link of the nodes form the link file.
% 
% Syntax: [NodeLink] = GetNodeLink(NodeName,LinkPath)
% 
% 

% 1: check input
    try
        NodeName = string(NodeName);
    catch ME
        ErrorMessage = "Input must be string." + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
% 2: read the linkfile
    LinkFile = LinkData;
% 3: layer link
    [Pos,Lay] = GetNodePosAndLay(NodeName);
    try
        NodeNameDim = size(NodeName);
        NodeLink = cell(NodeNameDim);
        for i = 1:prod(NodeNameDim)
            NodeLink{i} = '';
        end
        for i = 1:prod(NodeNameDim)
            ThisPos = Pos(i);
            ThisLay = Lay(i);
            LastLay = ThisLay - 1;
            NextLay = ThisLay + 1;
            PosIndex = ismember(Pos,ThisPos);
            LayIndex = ismember(Lay,LastLay);
            LastIndex = PosIndex & LayIndex;
            PosIndex = ismember(Pos,ThisPos);
            LayIndex = ismember(Lay,NextLay);
            NextIndex = PosIndex & LayIndex;
            Index = LastIndex | NextIndex;
            LinkTemp = NodeName(Index);
            LinkTemp = LinkTemp(~cellfun('isempty',LinkTemp));
            NodeLink{i} = [NodeLink{i};LinkTemp];
            Temp = NodeLink{i};
            Temp = Temp(~cellfun('isempty',Temp));
            NodeLink{i} = Temp;
        end
    catch ME
        ErrorMessage = "The link file is corrupted." + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
% 4: Position link
    try
        LinkHeader = LinkFile(:,1);
        for i = 1:length(LinkHeader)
            ThisHeader = LinkHeader(i);
            if ~contains(ThisHeader,"-")
                continue
            end
            ThisHeader = split(ThisHeader,"-");
            LayerRange = double(ThisHeader);
            
            MaxLayer = max(LayerRange);
            MinLayer = min(LayerRange);
            NodePosToBeLinked = LinkFile(i,2:end);
            % 去除 missing 数据
            NodePosToBeLinkedTemp = [];
            for j = 1:length(NodePosToBeLinked)
                if ~ismissing(NodePosToBeLinked(j))
                    NodePosToBeLinkedTemp = [NodePosToBeLinkedTemp;NodePosToBeLinked(j)];
                end
            end
            NodePosToBeLinked = NodePosToBeLinkedTemp;
            NodePosToBeLinked = string(NodePosToBeLinked);
            NodePosToBeLinked = NodePosToBeLinked(:);
            [ThisRowPos,~] = GetNodePosAndLay(NodePosToBeLinked);

            for j = 1:length(NodePosToBeLinked)
                ThisNodePos = ThisRowPos(j);
                OtherNodePos = ThisRowPos(~ismember(ThisRowPos,ThisNodePos));
                for k = MinLayer:MaxLayer
                    PosIndex = ismember(Pos,ThisNodePos);
                    LayIndex = ismember(Lay,k);
                    Index = PosIndex & LayIndex;
                    OtherPosIndex = ismember(Pos,OtherNodePos);
                    OtherLayIndex = ismember(Lay,k);
                    OtherIndex = OtherPosIndex & OtherLayIndex;
                    LinkTemp = NodeName(OtherIndex);
                    LinkTemp = LinkTemp(~cellfun('isempty',LinkTemp));
                    % if Index is all 0, the ThisNodeName is not in the NodeName
                    % if ~any(Index)
                    %     ErrorMessage = ErrorMessage + ErrorHeader + ...
                    %     "The link file:"+LinkPath+" contains a node name that does not exist";
                    % end
                    NodeLink{Index} = [NodeLink{Index};LinkTemp];
                end
            end
        end
    catch ME
        ErrorMessage = "The link file (Position link part) is corrupted." + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end

% 5: specific link
    try
        LinkHeader = LinkFile(:,1);
        for i = 1:length(LinkHeader)
            ThisHeader = LinkHeader(i);
            if ~strcmp(ThisHeader,"s")
                continue
            end
            NodeNameToBeLinked = LinkFile(i,2:end);
            % 去除 missing 数据
            NodePosToBeLinkedTemp = [];
            for j = 1:length(NodeNameToBeLinked)
                if ~ismissing(NodeNameToBeLinked(j))
                    NodePosToBeLinkedTemp = [NodePosToBeLinkedTemp;NodeNameToBeLinked(j)];
                end
            end
            NodeNameToBeLinked = NodePosToBeLinkedTemp;
            NodeNameToBeLinked = string(NodeNameToBeLinked);
            NodeNameToBeLinked = NodeNameToBeLinked(:);
            [ThisRowPos,ThisRowLay] = GetNodePosAndLay(NodeNameToBeLinked);
            
            ThisRowIndex = zeros(size(NodeNameToBeLinked));
            for j = 1:length(NodeNameToBeLinked)
                ThisNodePos = ThisRowPos(j);
                ThisNodeLay = ThisRowLay(j);
                PosIndex = ismember(Pos,ThisNodePos);
                LayIndex = ismember(Lay,ThisNodeLay);
                Index = PosIndex & LayIndex;
                % if ~any(Index)
                %     ErrorMessage = ErrorMessage + ErrorHeader + ...
                %     "The link file:"+LinkPath+" contains a node name that does not exist";
                % end
                ThisRowIndex(j) = find(Index);
            end
            NodeNameToBeLinked = NodeName(ThisRowIndex);
            NodeNameToBeLinked = NodeNameToBeLinked(:);
            for j = 1:length(NodeNameToBeLinked)
                ThisNodeName = NodeNameToBeLinked(j);
                OtherNodeName = NodeNameToBeLinked(~ismember(NodeNameToBeLinked,ThisNodeName));
                NodeLink{ThisRowIndex(j)} = [NodeLink{ThisRowIndex(j)};OtherNodeName];
            end
        end
    catch ME
        ErrorMessage = "The link file (specific link part) is corrupted." + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
% 6: remove duplicate
    for i = 1:prod(NodeNameDim)
        NodeLink{i} = unique(NodeLink{i});
    end
end