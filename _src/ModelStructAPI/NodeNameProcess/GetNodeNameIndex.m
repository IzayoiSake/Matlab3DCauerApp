function NodeNameIndex = GetNodeNameIndex(varargin)
    if nargin == 2
        Method = "Name";
        NodeName = varargin{1};
        NodeNameList = varargin{2};
    elseif nargin == 3
        Method = "PL";
        PosNeed = varargin{1};
        LayNeed = varargin{2};
        NodeNameList = varargin{3};
    else
        error("Invalid Input");
    end
    if Method == "Name"
        try
            NodeName = string(NodeName);
            NodeNameList = string(NodeNameList);
            [Pos,Lay] = GetNodePosAndLay(NodeNameList);
            [PosNeed,LayNeed] = GetNodePosAndLay(NodeName);
        catch
            ErrorMessage = "Invalid NodeName or NodeNameList";
            error(ErrorMessage);
        end
        NodeNameIndex = zeros(size(NodeName));
        for i = 1:numel(NodeName)
            PosIndex = (Pos == PosNeed(i));
            LayIndex = (Lay == LayNeed(i));
            Index = PosIndex & LayIndex;
            if sum(Index) == 1
                NodeNameIndex(i) = find(Index);
            else
                NodeNameIndex(i) = 0;
            end
        end
    elseif Method == "PL"
        try
            [Pos,Lay] = GetNodePosAndLay(NodeNameList);
        catch
            ErrorMessage = "Invalid NodeNameList";
            error(ErrorMessage);
        end
        NodeNameIndex = zeros(size(PosNeed));
        if size(PosNeed) ~= size(LayNeed)
            error("Invalid Position and Layer");
        end
        for i = 1:numel(PosNeed)
            PosIndex = (Pos == PosNeed(i));
            LayIndex = (Lay == LayNeed(i));
            Index = PosIndex & LayIndex;
            if sum(Index) == 1
                NodeNameIndex(i) = find(Index);
            else
                NodeNameIndex(i) = 0;
            end
        end
    end
end