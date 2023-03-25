function [ModelStruct]=CalcuGr(ModelStruct)
% 1: PreTest
    try
        ModelStruct.Temp.State;
    catch ME
        ErrorMessage = "The current ModelStruct cannot calculate Gr" + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
% 2: CalcuGr() Start
    if ModelStruct.Temp.State == "CalcuGr() Start"
        ModelStruct.Temp.State = "CalcuGr() Getting Tr and Pr";
        return
    end
% 3: CalcuGr() Getting Tr and Pr
    if ModelStruct.Temp.State == "CalcuGr() Getting Tr and Pr"
        try
            [Tr,TrName] = GetTr(ModelStruct);
            Pr = GetPr(ModelStruct);
            ModelStruct.Temp.Tr = Tr;
            ModelStruct.Temp.Pr = Pr;
            ModelStruct.Temp.TrName = TrName;
            ModelStruct.Temp.State = "CalcuGr() Calculating Gr";
            return
        catch ME
            ErrorMessage = "Error at State: CalcuGr() Getting Tr and Pr" + newline;
            ErrorMessage = ErrorMessage + CatchProcess(ME,1);
            error(ErrorMessage);
        end
    end
% 4: CalcuGr() Calculating Gr
    try
        if ModelStruct.Temp.State == "CalcuGr() Calculating Gr"
            ModelStruct.Gr = lsqnonneg(ModelStruct.Temp.Tr,ModelStruct.Temp.Pr);
            ModelStruct.Temp.State = "CalcuGr() End";
            return
        end
    catch ME
        ErrorMessage = "Error at State: CalcuGr() Calculating Gr" + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
end