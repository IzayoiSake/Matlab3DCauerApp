function ModelStruct = MsGUS(ModelStruct)
    import Cauer3D.Model.*
    import Cauer3D.UI.*
    import Cauer3D.Nomenclature.*
    import Cauer3D.Plot.*
    import Cauer3D.Export.*
    import Cauer3D.IO.*
    import Cauer3D.Internal.*
    if ModelStruct.Temp.State == "Get Users Settings"
        % copy every field from ModelStruct.Settings to ModelStruct.Temp
        Fields = fieldnames(ModelStruct.Settings);
        for i=1:length(Fields)
            ModelStruct.Temp.(Fields{i})=ModelStruct.Settings.(Fields{i});
        end
        ModelStruct.Message = ModelStruct.Message + "Users Settings are got and saved temporarily for this calculation process." + newline;
    end
end