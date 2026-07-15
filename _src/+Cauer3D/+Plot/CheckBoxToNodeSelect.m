function CheckBoxToNodeSelect(app)
    import Cauer3D.Model.*
    import Cauer3D.UI.*
    import Cauer3D.Nomenclature.*
    import Cauer3D.Plot.*
    import Cauer3D.Export.*
    import Cauer3D.IO.*
    import Cauer3D.Internal.*
    ModelStruct = app.CallerApp.ModelStruct;
    NodeNameEffective = ModelStruct.NodeNameEffective;
    NodeSelect = zeros(size(NodeNameEffective));
    for i = 1:numel(app.CheckBoxes)
        try
            Text = app.CheckBoxes{i}.Text;
            Text =string(Text);
            Index = GetNodeNameIndex(Text,NodeNameEffective);
            NodeSelect(Index) = app.CheckBoxes{i}.Value;
        catch
        end
    end
    ModelStruct.Result.Draw.NodeSelect = NodeSelect;
    app.CallerApp.ModelStruct = ModelStruct;
end