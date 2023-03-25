%% Sort node names
function [NodeNameOut,Index] = SortNodeName(NodeName,Method)
% SortNodeName(NodeName,Method) - Sort node names
% 
% Syntax: [NodeNameOut,Index] = SortNodeName(NodeName,Method)
% 
% NodeName refers to the node names to be sorted;
% Method refers to the sorting method, ...
    % "Layer" refers to putting nodes of the same layer together;
    % "Position" refers to putting nodes of the same position together;

% 1: Check inputs
    if ~exist('Method','var')
        Method = "Layer";
    end
    MethodList = ["Layer";"Position"];
    try
        if ~ismember(Method,MethodList)
            ErrorMessage = "illegal method" + newline;
            error(ErrorMessage);
        end
    catch ME
        ErrorMessage = '';
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
% 2: get the positon and layer of NodeName
    try
        [Pos,Lay] = GetNodePosAndLay(NodeName);
    catch ME
        ErrorMessage = '';
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
% 3: sort the node names
    try
        NodeNameDim = size(NodeName);
        NodeNameNum = numel(NodeName);
        Layer = zeros(NodeNameNum,1);
        Position = zeros(NodeNameNum,1);
        NodeNameOut = zeros(NodeNameDim);
        NodeNameOut = string(NodeNameOut);
        NodeNameOut = strrep(NodeNameOut,'0','');
        Index = zeros(NodeNameDim);
        for i = 1:NodeNameNum
            Layer(i) = Lay(i);
            Position(i) = Pos(i);
        end
        PL = [Position,Layer];
        if Method == "Layer"
            [~,Index(:)] = sortrows(PL,[2,1]);
        elseif Method == "Position"
            [~,Index(:)] = sortrows(PL,[1,2]);
        end
        NodeNameOut(:) = NodeName(Index);
    catch ME
        ErrorMessage = "Unknown error" + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
end