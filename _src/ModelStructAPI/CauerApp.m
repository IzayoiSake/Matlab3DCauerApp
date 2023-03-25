
function [ModelStruct] = CauerApp(ModelStruct)

    ModelStruct = MsInit(ModelStruct);
    
% 3: Get Users Settings from ModelStruct.Settings to ModelStruct.Temp
    try
        if ModelStruct.Temp.State == "Get Users Settings"
            ModelStruct = MsGUS(ModelStruct);
            ModelStruct.Temp.State = "Preprocess Files";
            return;
        end
    catch ME
        ErrorMessage = "Unexpected Error in CauerApp():" + newline + CatchProcess(ME);
        error(ErrorMessage);
    end
% 3.5: Check files and preprocess the Data of files
    try
        if ModelStruct.Temp.State == "Preprocess Files"
            ModelStruct = MsPreProF(ModelStruct);
            ModelStruct.Temp.State = "GenModStrut() Start";
            return;
        end
    catch ME
        ErrorMessage = CatchProcess(ME);
        error(ErrorMessage);
    end
% 4: function [ModelStruct]=GenModStrut(ModelStruct)
    try
        if contains(ModelStruct.Temp.State,"GenModStrut()")
            [ModelStruct] = GenModStrut(ModelStruct);
            if strcmp(ModelStruct.Temp.State,"GenModStrut() End")
                ModelStruct.Temp.State = "CalcuGr() Start";
            end
            return;
        end
    catch ME
        ErrorMessage = CatchProcess(ME,1);
        error(ErrorMessage);
    end
% 5: function [ModelStruct]=CalcuGr(ModelStruct,PrPath,TrPath)
    try
        if contains(ModelStruct.Temp.State,"CalcuGr()")
            [ModelStruct] = CalcuGr(ModelStruct);
            if strcmp(ModelStruct.Temp.State,"CalcuGr() End")
                ModelStruct.Temp.State="GenerateG() Start";
            end
            return
        end
    catch ME
        ErrorMessage = CatchProcess(ME,1);
        error(ErrorMessage);
    end
% 6: function ModelStruct = GenerateG(ModelStruct)
    try
        if contains(ModelStruct.Temp.State,"GenerateG()")
            [ModelStruct]=GenerateG(ModelStruct);
            if strcmp(ModelStruct.Temp.State,"GenerateG() End")
                ModelStruct.Temp.State="GenerateGa() Start";
            end
            return
        end
    catch ME
        ErrorMessage = CatchProcess(ME,1);
        error(ErrorMessage);
    end
% 7: function ModelStruct=GenerateGa(ModelStruct)
    try
        if contains(ModelStruct.Temp.State,"GenerateGa()")
            [ModelStruct]=GenerateGa(ModelStruct);
            if strcmp(ModelStruct.Temp.State,"GenerateGa() End")
                ModelStruct.Temp.State="PatternSearchC() Start";
            end
            return
        end
    catch ME
        ErrorMessage = CatchProcess(ME,1);
        error(ErrorMessage);
    end
% 8: function [ModelStruct,ErrorMessage] = PatternSearchC(ModelStruct,slxDir,Path_T,Path_P,ParPoolNum,StepSize)
    try
        if contains(ModelStruct.Temp.State,"PatternSearchC()")
            [ModelStruct] = PatternSearchC(ModelStruct);
            if strcmp(ModelStruct.Temp.State,"PatternSearchC() End")
                ModelStruct.Temp.State="End";
            end
            return
        end
    catch ME
        ErrorMessage = CatchProcess(ME,1);
        error(ErrorMessage);
    end
end








    