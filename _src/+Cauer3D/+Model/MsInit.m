function ModelStruct = MsInit(ModelStruct)
    import Cauer3D.Model.*
    import Cauer3D.UI.*
    import Cauer3D.Nomenclature.*
    import Cauer3D.Plot.*
    import Cauer3D.Export.*
    import Cauer3D.IO.*
    import Cauer3D.Internal.*
% MsInit - Initialize the state of ModelStruct
    if ~isfield(ModelStruct,"Temp")
        ModelStruct.Temp.State = "Get Users Settings";
        if ~isfield(ModelStruct,"Message")
            ModelStruct.Message = "";
        end
        ModelStruct.Message = ModelStruct.Message + "The state of ModelStruct is initialized." + newline;
    elseif ~isfield(ModelStruct.Temp,"State")
        ModelStruct.Temp.State = "Get Users Settings";
        if ~isfield(ModelStruct,"Message")
            ModelStruct.Message = "";
        end
        ModelStruct.Message = ModelStruct.Message + "The state of ModelStruct is initialized." + newline;
    elseif ModelStruct.Temp.State == "End"
        ModelStruct.Temp.State = "Get Users Settings";
        if ~isfield(ModelStruct,"Message")
            ModelStruct.Message = "";
        end
        ModelStruct.Message = ModelStruct.Message + "The state of ModelStruct is initialized." + newline;
    end
end
