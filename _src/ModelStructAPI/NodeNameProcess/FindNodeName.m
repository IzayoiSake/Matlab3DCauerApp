function NodeName = FindNodeName(Data)
    try
        Data = string(Data);
        Num = numel(Data);
    catch
        NodeName = "";
        return;
    end
    IsNode = false(Num,1);
    for i = 1:Num
        try
            [~,~] = GetNodePosAndLay(Data(i));
            IsNode(i) = true;
        catch
            IsNode(i) = false;
        end
    end
    NodeName = Data(IsNode);
end