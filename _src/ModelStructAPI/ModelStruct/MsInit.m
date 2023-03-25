function ModelStruct = MsInit(ModelStruct)
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
