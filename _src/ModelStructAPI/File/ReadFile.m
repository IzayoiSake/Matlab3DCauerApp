function [Data,Type] = ReadFile(Path)
% ReadFile(Path) - Read a file and return the data and type
%
% Syntax: output = myFun(input)
%
% This file can be read and identified: 
% "Steady-state thermal simulation", "STS"
% "Transient thermal simulation", "TTS"
% "Steady-state power setting", "SPS"
% "Transient power setting", "TPS"
% "Node connection setting", "NCS"
% "Node selection" , "NS"
% files
    Data = "";
    Type = "";
% 1: Read the file
    try
        [~,~,ext] = fileparts(Path);
        if strcmp(Path,"")
            ErrorMessage = "Path is empty";
            error(ErrorMessage);
        end
        if ~exist(Path,'file')
            ErrorMessage = Path + newline + "File does not exist";
            error(ErrorMessage);
        end
    catch ME
        ErrorMessage = "Path is not correct" + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
% 2: Determination of file type based on file extension and file flag
    try
        if strcmp(ext,".csv")
            DataTemp = readlines(Path);
            DataTemp = string(DataTemp);
            if isempty(DataTemp)
                ErrorMessage = Path + newline + "File is empty";
                error(ErrorMessage);
            end
            if ~contains(DataTemp(1),"Summary report for")
                ErrorMessage = Path + newline + "Unknown file type";
                error(ErrorMessage);
            end
            Type = "TS";
            DataTemp = DataTemp(6:end);
            DataTemp = DataTemp(~cellfun('isempty',DataTemp));
            DataTemp = split(DataTemp,",");
        elseif strcmp(ext,".xlsx")
            DataTemp = readcell(Path);
            DataTemp = string(DataTemp);
            if isempty(DataTemp)
                ErrorMessage = Path + newline + "File is empty";
                error(ErrorMessage);
            end
            Flag = DataTemp(1,1);
            if strcmp(Flag,"NodeName")
                Type = "SPS";
            elseif strcmp(Flag,"Time")
                Type = "TPS";
            elseif strcmp(Flag,"Layer")
                Type = "NCS";
            elseif strcmp(Flag,"Node Selection")
                Type = "NS";
            else
                ErrorMessage = Path + newline + "Unknown file type";
                error(ErrorMessage);
            end
        end
    catch ME
        ErrorMessage = "File is not correct" + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end

% 3: Data processing by file type
    try
        if strcmp(Type,"TS")
            [Data,Type] = TSPrcoess(DataTemp);
        elseif strcmp(Type,"SPS")
            Data = DataTemp;
        elseif strcmp(Type,"TPS")
            Data = DataTemp;
        elseif strcmp(Type,"NCS")
            Data = DataTemp(2:end,:);
        elseif strcmp(Type,"NS")
            Data = DataTemp(2:end,:);
        end
    catch ME
        ErrorMessage = "File might be corrupted" + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end

end


function [Data,Type] = TSPrcoess(DataTemp)
    Header = DataTemp(1,:);
    % Header of Type "TTS" has an element "Time Value"
    if any(strcmp(Header,"Time Value"))
        Type = "TTS";
    else
        Type = "STS";
    end
    if Type == "STS"
        ObjectIndex = strcmp(Header,"Object");
        MeanIndex = strcmp(Header,"Mean");
        Object = DataTemp(2:end,ObjectIndex);
        Mean = DataTemp(2:end,MeanIndex);
        NodeName = unique(Object);
        NodeName = NodeName(~cellfun('isempty',NodeName));
        NodeName = NodeName(:)';
        T = zeros(1,numel(NodeName));
        T = string(T);
        T = strrep(T,"0","");
        for i = 1:numel(NodeName)
            NodeNameIndex = find(strcmp(Object,NodeName(i)));
            % make sure that only one element is found
            if size(NodeNameIndex,1) ~= 1
                ErrorMessage = newline + "Duplicate node name detected";
                error(ErrorMessage);
            end
            NodeNameMean = Mean(NodeNameIndex);
            T(i) = NodeNameMean;
        end
        Data = [NodeName;T];
    elseif Type == "TTS"
        TimeIndex = strcmp(Header,"Time Value");
        ObjectIndex = strcmp(Header,"Object");
        MeanIndex = strcmp(Header,"Mean");
        Time = DataTemp(2:end,TimeIndex);
        Object = DataTemp(2:end,ObjectIndex);
        Mean = DataTemp(2:end,MeanIndex);
        NodeName = unique(Object);
        AllTime = Time;
        Time = unique(Time);
        NodeName = NodeName(~cellfun('isempty',NodeName));
        NodeName = NodeName(:)';
        T = zeros(numel(Time),numel(NodeName));
        T = string(T);
        T = strrep(T,"0","");
        for i = 1:numel(NodeName)
            [ObjectRowIndex,ObjectColIndex] = find(strcmp(Object,NodeName(i)));
            ObjectIndex = [ObjectRowIndex,ObjectColIndex];
            for j = 1:numel(Time)
                [TimeRowIndex,TimeColIndex] = find(strcmp(AllTime,Time(j)));
                TimeIndex = [TimeRowIndex,TimeColIndex];
                Index = intersect(ObjectIndex,TimeIndex,'rows');
                if isempty(Index)
                    ErrorMessage = newline + "Time and node name do not match";
                    error(ErrorMessage);
                end
                if size(Index,1) > 1
                    ErrorMessage = newline + "Duplicate node name detected";
                    error(ErrorMessage);
                end
                T(j,i) = Mean(Index(1),Index(2));
            end
        end
        TimeDb = double(Time);
        [~,TimeIndex] = sort(TimeDb);
        Time = Time(TimeIndex);
        T = T(TimeIndex,:);
        Header = ["Time",NodeName];
        Data = [Header;[Time,T]];
    end
end