function [HeaderOut,Index] = SortByNodeName(HeaderIn,NodeName)
% SortByNodeName(HeaderIn,NodeName) - Sorts the header by node name
% 
% Syntax:  [HeaderOut,Index,ErrorMassage] = SortByNodeName(HeaderIn,NodeName)
%
% Warning: if Header has nodes which are not in NodeName, they will be ignored

% 1: Convert both to same Nomenclature
    try
        Header = HeaderIn(:);
        NodeName = NodeName(:);
        Nomenclature = NomenclatureOf(NodeName);
        Header = ConvertNodeName(Header,Nomenclature(1));
        NodeName = ConvertNodeName(NodeName,Nomenclature(1));
    catch ME
        ErrorMessage = "Convert both to same Nomenclature failed." + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
% 2: Check if Header has nodes which are not in NodeName
    try
        Index = find(ismember(Header,NodeName));
        if length(Index) ~= length(Header)
            ErrorMessage = "Header has nodes which are not in NodeName." + newline;
            ErrorMessage = ErrorMessage + "They will be ignored.";
            warning(ErrorMessage);
        end
    catch ME
        ErrorMessage = '';
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
% 3: sort Header by NodeName
    try
        Header = Header(Index);
        [X,Y] = ismember(Header,NodeName);
        [~,Index] = sort(Y(X));
        HeaderOut = Header(Index);
    catch ME
        ErrorMessage = "Sort Header by NodeName failed." + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
end