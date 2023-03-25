function NodeSelectToCheckBox(app)
    ModelStruct = app.CallerApp.ModelStruct;
    NodeNameEffective = ModelStruct.NodeNameEffective;
    try
        NodeSelect = ModelStruct.Result.Draw.NodeSelect;
    catch
        NodeSelect = zeros(size(NodeNameEffective));
    end
    for i = 1:numel(app.CheckBoxes)
        try
            ThisNodeName = app.CheckBoxes{i}.Text;
        catch
        end
        ThisNodeName = string(ThisNodeName);
        Index = GetNodeNameIndex(ThisNodeName,NodeNameEffective);
        if NodeSelect(Index) == 1
            app.CheckBoxes{i}.Value = 1;
        else
            app.CheckBoxes{i}.Value = 0;
        end
    end
end