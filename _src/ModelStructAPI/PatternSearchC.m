function [ModelStruct] = PatternSearchC(ModelStruct)
% This function is used to perform the pattern search algorithm for the C
% 1: initialize Message
    slxDir = ModelStruct.Temp.slxDir;
    ParPoolNum = ModelStruct.Temp.ParPoolNum;
    StepSize = ModelStruct.Temp.StepSize;
% 2: check the inputs
    if ModelStruct.Temp.State == "PatternSearchC() Start"
        if ~strcmp(slxDir,"")
            if ~exist(slxDir,"dir")
                % create the directory
                mkdir(slxDir);
            end
        end
        ModelStruct.Temp.State = "PatternSearchC() Reading Files";
        ModelStruct.Message = ModelStruct.Message + "PatternSearchC begins." + newline;
        return
    end
    if ModelStruct.Temp.State ~= "PatternSearchC() Start"

    end
% 3: read the file
    if ModelStruct.Temp.State == "PatternSearchC() Reading Files"
        TData = ModelStruct.Temp.TransTemptData;
        PData = ModelStruct.Temp.TransPowerData;
    % process the data
        THeader = TData(1,2:end);
        Ttempt = TData(2:end,2:end);
        Ttempt = double(Ttempt);
        Ttime = TData(2:end,1);
        Ttime = double(Ttime);
        PHeader = PData(1,2:end);
        Ppower = PData(2:end,2:end);
        Ppower = double(Ppower);
        Ptime = PData(2:end,1);
        Ptime = double(Ptime);
        Nomenclature = ModelStruct.Temp.Nomenclature;
        THeader = ConvertNodeName(THeader,Nomenclature);
        PHeader = ConvertNodeName(PHeader,Nomenclature);
    % Save Current variables
        ModelStruct.Temp.THeader = THeader;
        ModelStruct.Temp.Ttempt = Ttempt;
        ModelStruct.Temp.Ttime = Ttime;
        ModelStruct.Temp.PHeader = PHeader;
        ModelStruct.Temp.Ppower = Ppower;
        ModelStruct.Temp.Ptime = Ptime;
        ModelStruct.Temp.Nomenclature = Nomenclature;
        ModelStruct.Temp.State = "PatternSearchC() Begin to Search";
        ModelStruct.Message = ModelStruct.Message + "Transient thermal data is processed and ready for pattern search." + newline;
        return
    end
% 4: begin to search
    if ModelStruct.Temp.State == "PatternSearchC() Begin to Search"
        StartNode = 1;
        EndNode = 0;
        ModelStruct.Temp.StartNode = StartNode;
        ModelStruct.Temp.EndNode = EndNode;
        ModelStruct.Temp.State = "PatternSearchC() Searching";
        Cr = zeros(length(ModelStruct.NodeNameEffective),1);
        ModelStruct.Temp.Cr = Cr;
        % check 'local' parallel pool
        if isempty(gcp('nocreate'))
            % get the maximum NumWorkers of cluster 'local'
            try
                parpool(ParPoolNum);
            catch
                ErrorMessage = "The number of parpool is too large";
                error(ErrorMessage);
            end
        end
        return
    end
    if ModelStruct.Temp.State == "PatternSearchC() Searching"
        StartNode = ModelStruct.Temp.StartNode;
        EndNode = ModelStruct.Temp.EndNode;
        THeader = ModelStruct.Temp.THeader;
        Ttempt = ModelStruct.Temp.Ttempt;
        Ttime = ModelStruct.Temp.Ttime;
        PHeader = ModelStruct.Temp.PHeader;
        Ppower = ModelStruct.Temp.Ppower;
        Ptime = ModelStruct.Temp.Ptime;
        NodeNameEffective = ModelStruct.NodeNameEffective;
        GrName = ModelStruct.GrName;
        % get current directory
        if ~isfield(ModelStruct.Temp,"CurrentDir")
            CurrentDir = pwd;
            ModelStruct.Temp.CurrentDir = CurrentDir;
        else
            CurrentDir = ModelStruct.Temp.CurrentDir;
        end
        % change the directory to the slxDir
        if ~strcmp(slxDir,"")
            cd(slxDir);
        end
        if EndNode<length(NodeNameEffective)
            if StartNode == EndNode+1
                EndNode = StartNode+ParPoolNum-1;
            end
            if EndNode>length(NodeNameEffective)
                EndNode=length(NodeNameEffective);
            end
            CrTemp=zeros(length(ModelStruct.NodeNameEffective),1);
            if exist("slxDir","var") && ~strcmp(slxDir,"")
                slxDirEx = 1;
            else
                slxDirEx = 0;
            end
            NodeLink = ModelStruct.NodeLink;
            Gr = ModelStruct.Gr;
            GrName = ModelStruct.GrName;
            Message = ModelStruct.Message;
            parfor i = StartNode:EndNode
                try
                    Exp_TIndex = find(strcmp(THeader,NodeNameEffective(i)));
                    Exp_T = Ttempt(:,Exp_TIndex);
                    PIndex = find(strcmp(PHeader,NodeNameEffective(i)));
                    P = Ppower(:,PIndex);
                    % find all the resistors connected to this node
                    ThisNodeName = NodeNameEffective(i);
                    ThisNodeLink = NodeLink{i};
                    ThisNodeLink = string(ThisNodeLink);
                    GrIndex = zeros(length(ThisNodeLink),1);
                    for j = 1:length(ThisNodeLink)
                        GrIndex(j) = GetGrIndex(ThisNodeName,ThisNodeLink(j),GrName);
                        if GrIndex(j) == 0
                            error(ThisNodeName + " and " + ThisNodeLink(j) + " are not connected by a resistor.");
                        end
                    end
                    GrNeed = Gr(GrIndex);
                    R = 1./GrNeed;
                    GrNameNeed = GrName(GrIndex,:);
                    % find the Tempterature of the Linked Nodes
                    T = zeros(length(Ttime),length(ThisNodeLink));
                    % find the index of the linked nodes in the THeader
                    [~,TIndex] = ismember(ThisNodeLink,THeader);
                    % Get the Tdata of the linked nodes
                    T = Ttempt(:,TIndex);
                    % Calculate C
                    Message = Message + "Calculating C(" + ThisNodeName + ")" + newline;
                    % Remainder = mod(i,ParPoolNum);
                    if slxDirEx
                        slxFilePath = fullfile(slxDir,"PatternSearch"+string(i)+".slx");
                    else
                        slxFilePath = "PatternSearch" + string(i)+".slx";
                    end
                    CrTemp(i) = SimulinkOperation(Exp_T,R,P,Ptime,T,Ttime,slxFilePath,StepSize);
                    % close all the simulink files named starting with "PatternSearch"
                    close_system("PatternSearch*",0);
                catch ME
                    close_system("PatternSearch*",0);
                    ErrorMessage = "Error when Calculating C(" + ThisNodeName + ")" + newline;
                    ErrorMessage = ErrorMessage + CatchProcess(ME,1);
                    error(ErrorMessage);
                end
            end
            ModelStruct.Message = Message;
            cd(CurrentDir);
            for i = StartNode:EndNode
                ModelStruct.Temp.Cr(i) = CrTemp(i);
            end
            StartNode = EndNode + 1;
            ModelStruct.Temp.StartNode = StartNode;
            ModelStruct.Temp.EndNode = EndNode;
        end
        if EndNode == length(NodeNameEffective)
            ModelStruct.Cr = ModelStruct.Temp.Cr;
            ModelStruct.Temp.State = "PatternSearchC() Calculate C";
        end
        return
    end
% Calculate C after Cr is calculated
    if ModelStruct.Temp.State == "PatternSearchC() Calculate C"
        Cr = ModelStruct.Cr;
        C = diag(Cr);
        ModelStruct.C = C;
        ModelStruct.Temp.State = "PatternSearchC() End";
        ModelStruct.Message = ModelStruct.Message+"PatternSearch is End";
        return
    end
end




