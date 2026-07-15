function NodeName = FindNodeName(Data)
    import Cauer3D.Model.*
    import Cauer3D.UI.*
    import Cauer3D.Nomenclature.*
    import Cauer3D.Plot.*
    import Cauer3D.Export.*
    import Cauer3D.IO.*
    import Cauer3D.Internal.*
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