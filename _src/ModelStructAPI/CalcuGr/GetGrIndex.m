function Index = GetGrIndex(NodeName1,NodeName2,GrName)
    try
        [Pos1,Lay1] = GetNodePosAndLay(NodeName1);
        [Pos2,Lay2] = GetNodePosAndLay(NodeName2);
        [Pos,Lay] = GetNodePosAndLay(GrName);
    catch
        Index = 0;
        return
    end
    PosIndex = (Pos1 == Pos);
    LayIndex = (Lay1 == Lay);
    NN1Index = (PosIndex & LayIndex);
    PosIndex = (Pos2 == Pos);
    LayIndex = (Lay2 == Lay);
    NN2Index = (PosIndex & LayIndex);
    AllIndex = NN1Index | NN2Index;
    % Index is the number of the row where the whole row is 1
    Index = AllIndex(:,1);
    for i = 2:size(AllIndex,2)
        Index = Index & AllIndex(:,i);
    end
    Index = find(Index);
    if isempty(Index)
        Index = 0;
    end
end
