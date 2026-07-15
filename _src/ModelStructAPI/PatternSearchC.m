function [ModelStruct] = PatternSearchC(ModelStruct)
% This function is used to perform the pattern search algorithm for the C
% 1: initialize Message
    ParPoolNum = ModelStruct.Temp.ParPoolNum;
    StepSize = ModelStruct.Temp.StepSize;
% 2: check the inputs
    if ModelStruct.Temp.State == "PatternSearchC() Start"
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
        if EndNode<length(NodeNameEffective)
            if StartNode == EndNode+1
                EndNode = StartNode+ParPoolNum-1;
            end
            if EndNode>length(NodeNameEffective)
                EndNode=length(NodeNameEffective);
            end
            CrTemp=zeros(length(ModelStruct.NodeNameEffective),1);
            NodeLink = ModelStruct.NodeLink;
            Gr = ModelStruct.Gr;
            GrName = ModelStruct.GrName;
            Message = ModelStruct.Message;
            parfor i = StartNode:EndNode
                ThisNodeName = NodeNameEffective(i);
                try
                    Exp_TIndex = find(strcmp(THeader,ThisNodeName));
                    if ~isscalar(Exp_TIndex)
                        error("Temperature data must contain exactly one column for " + ThisNodeName + ".");
                    end
                    Exp_T = Ttempt(:,Exp_TIndex);
                    PIndex = find(strcmp(PHeader,ThisNodeName));
                    if ~isscalar(PIndex)
                        error("Power data must contain exactly one column for " + ThisNodeName + ".");
                    end
                    P = Ppower(:,PIndex);
                    % find all the resistors connected to this node
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
                    if any(~isfinite(GrNeed))
                        error("The fitted thermal conductance of " + ThisNodeName + " contains NaN or Inf.");
                    end
                    if any(GrNeed < 0)
                        error("The fitted thermal conductance of " + ThisNodeName + " must not be negative.");
                    end
                    % A zero conductance is an open thermal branch and does not
                    % participate in the transient temperature calculation.
                    ActiveLink = GrNeed > 0;
                    GrNeed = GrNeed(ActiveLink);
                    ThisNodeLink = ThisNodeLink(ActiveLink);
                    R = 1./GrNeed;
                    % find the Tempterature of the Linked Nodes
                    % find the index of the linked nodes in the THeader
                    [~,TIndex] = ismember(ThisNodeLink,THeader);
                    if any(TIndex == 0)
                        error("Temperature data is missing one or more nodes linked to " + ThisNodeName + ".");
                    end
                    % Get the Tdata of the linked nodes
                    T = Ttempt(:,TIndex);
                    % Calculate C
                    Message = Message + "Calculating C(" + ThisNodeName + ")" + newline;
                    CrTemp(i) = MatlabOperation(Exp_T,R,P,Ptime,T,Ttime,StepSize);
                catch ME
                    ErrorMessage = "Error when Calculating C(" + ThisNodeName + ")" + newline;
                    ErrorMessage = ErrorMessage + CatchProcess(ME,1);
                    error(ErrorMessage);
                end
            end
            ModelStruct.Message = Message;
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




