function [ModelStruct] = GenerateG(ModelStruct)
% GenerateG - Generate the G matrix for the model
% 1: PreTest
    try
        ModelStruct.Temp.State;
    catch ME
        ErrorMessage = "The current ModelStruct cannot generate G matrix" + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
% 2: GenerateG() Start
    if ModelStruct.Temp.State == "GenerateG() Start"
        try
            NodeNameEffective = ModelStruct.NodeNameEffective;
            Nomenclature = ModelStruct.Temp.Nomenclature;
            GrName = ModelStruct.GrName;
            GrName = ConvertNodeName(GrName, Nomenclature);
            NodeLink = ModelStruct.NodeLink;
            Gr = ModelStruct.Gr;
        catch ME
            ErrorMessage = "Error at State:" + ModelStruct.Temp.State + newline;
            ErrorMessage = ErrorMessage + CatchProcess(ME,1);
            error(ErrorMessage);
        end
        try
            G = zeros(length(NodeNameEffective), length(NodeNameEffective));
            GName = string(G);
            GName = strrep(GName,"0",'');
            for i = 1:size(G,1)
                ThisNodeName = NodeNameEffective(i);
                for j = 1:size(G,2)
                    if i == j
                        ThisNodeLink = NodeLink{i};
                        ThisNodeLink = string(ThisNodeLink);
                        ThisNodeLink = ConvertNodeName(ThisNodeLink, Nomenclature);
                        for k = 1:length(ThisNodeLink)
                            ThisNodeLinkName = ThisNodeLink(k);
                            ThisGrName = [ThisNodeName,ThisNodeLinkName];
                            [IsIn,Index] = ismember(ThisGrName,GrName,"rows");
                            if IsIn
                                G(i,j) = G(i,j) + Gr(Index);
                                
                            else
                                ThisGrName = [ThisNodeLinkName,ThisNodeName];
                                [IsIn,Index] = ismember(ThisGrName,GrName,"rows");
                                if IsIn
                                    G(i,j) = G(i,j) + Gr(Index);
                                    
                                else
                                    error("Error at State:" + ModelStruct.Temp.State + newline + "Cannot find the GrName:" + ThisGrName);
                                end
                            end
                            if k ~= length(ThisNodeLink)
                                GName(i,j) = GName(i,j) + "G(" + GrName(Index,1) + "," + GrName(Index,2) + ") + ";
                            else
                                GName(i,j) = GName(i,j) + "G(" + GrName(Index,1) + "," + GrName(Index,2) + ")";
                            end
                        end
                    else
                        ThatNodeName = NodeNameEffective(j);
                        ThisGrName = [ThisNodeName,ThatNodeName];
                        [IsIn,Index] = ismember(ThisGrName,GrName,"rows");
                        if IsIn
                            G(i,j) = -Gr(Index);
                        else
                            ThisGrName = [ThatNodeName,ThisNodeName];
                            [IsIn,Index] = ismember(ThisGrName,GrName,"rows");
                            if IsIn
                                G(i,j) = -Gr(Index);
                            else
                                G(i,j) = 0;
                                GName(i,j) = "";
                                % error("Error at State:" + ModelStruct.Temp.State + newline + "Cannot find the GrName:" + ThisGrName(1) + "," + ThisGrName(2));
                            end
                        end
                        if IsIn
                            GName(i,j) = GName(i,j) + "-G(" + GrName(Index,1) + "," + GrName(Index,2) + ")";
                        end
                    end
                end
            end
        catch ME
            ErrorMessage = "Error at State:" + ModelStruct.Temp.State + newline;
            ErrorMessage = ErrorMessage + CatchProcess(ME,1);
            error(ErrorMessage);
        end
    % save the G matrix
        ModelStruct.G = G;
        ModelStruct.GName = cell(size(GName));
        for i = 1:size(GName,1)
            for j = 1:size(GName,2)
                ModelStruct.GName{i,j} = GName(i,j);
            end
        end
        ModelStruct.Temp.State = "GenerateG() End";
    end
end