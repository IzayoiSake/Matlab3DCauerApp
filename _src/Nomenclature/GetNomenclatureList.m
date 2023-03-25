function [NomenclatureList,Description,Example] = GetNomenclatureList(Type)
% GetNomenclatureList(Type) - Get the list of nomenclature from the NomenclatureList.xlsx
% 
% Syntax: [NomenclatureList,Description,Example] = GetNomenclatureList(Type)
% 
% This function is used to get the naming method of the record.
% If Type is 0, only NomenclatureList will be returned
% If Type is 1, NomenclatureList, and Description will be returned
% If Type is 2, NomenclatureList, Description, and Example will be returned


% 1: initialize the output
    NomenclatureList = [];
    Description = [];
    Example = [];

% 2: try to read the NomenclatureList.xlsx
    try
        FileContent = readcell('NomenclatureList.xlsx');
        FileContent = string(FileContent);
    catch ME
        ErrorMessage = "Cannot read the NomenclatureList.xlsx" + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end

% 3: Process the Data of Type 0 and 1
    if ~exist('Type','var')
        Type = 0;
    end
    try
        Header = FileContent(1,:);
        NomenclatureHeader = "命名方式";
        DescriptionHeader = "描述";
        ExamplePosHeader = "示例点位";
        ExampleLayHeader = "示例层数";
        ExampleHeader = "示例";
        Index = strcmp(NomenclatureHeader,Header);
        NomenclatureList = FileContent(2:end,Index);
        if Type == 0
            return;
        end
        Index = strcmp(DescriptionHeader,Header);
        Description = FileContent(2:end,Index);
        if Type == 1
            return
        end
    catch ME
        ErrorMessage = "NomenclatureList.xlsx might be corrupted" + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end

% 4: Process the Data of Type 2
    try
        Index = strcmp(ExamplePosHeader,Header);
        ExamplePos = FileContent(2:end,Index);
        Index = strcmp(ExampleLayHeader,Header);
        ExampleLay = FileContent(2:end,Index);
        Index = strcmp(ExampleHeader,Header);
        Example_Raw = FileContent(2:end,Index);
        Example = ExampleProcess(Example_Raw,ExamplePos,ExampleLay);
        if Type == 2
            return
        end
    catch ME
        ErrorMessage = "The format of col ""Example"" is not correct" + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
    ErrorMessage = "Type should be 0, 1, or 2" + newline;
    error(ErrorMessage);
end

function Example = ExampleProcess(Example_Raw,ExamplePos,ExampleLay)
    Pos = cell(length(ExamplePos),1);
    for i = 1:length(ExamplePos)
        Pos{i} = split(ExamplePos(i),newline);
    end
    Lay = cell(length(ExampleLay),1);
    for i = 1:length(ExampleLay)
        Lay{i} = split(ExampleLay(i),newline);
    end
    ExampleRaw = cell(length(Example_Raw),1);
    for i = 1:length(Example_Raw)
        ExampleRaw{i} = split(Example_Raw(i),newline);
    end
    Example=zeros(length(Example_Raw),1);
    Example=string(Example);
    Example=strrep(Example,"0",'');
    for i = 1:length(Example_Raw)
        for j = 1:length(ExampleRaw{i})
            Example(i) = Example(i)+"第"+string(Pos{i}(j))+"点位，第"+string(Lay{i}(j))+"层，"+"命名为:"+ExampleRaw{i}(j)+newline;
        end
        % clear the last newline
        newlinePos = strfind(Example(i),newline);
        Example(i) = extractBefore(Example(i),newlinePos(end));
    end
end