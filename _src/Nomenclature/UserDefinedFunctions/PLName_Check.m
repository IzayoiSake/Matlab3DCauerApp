function [Ok,Pos,Lay] = PLName_Check(NodeName)
    Ok = 0;
    Pos = 0;
    Lay = 0;
% check if NodeName has 2 '_'
    UnderlineIndex = strfind(NodeName,'_');
    if length(UnderlineIndex)~=2
        return
    end
% check if NodeName has 'P_'
    PUnderlineIndex = strfind(NodeName,'P_');
    if isempty(PUnderlineIndex) || PUnderlineIndex~=1
        return
    end
% check if the two strings after the two "_" are numbers
    FirstUnderlineIndex = UnderlineIndex(1);
    SecondUnderlineIndex = UnderlineIndex(2);
    Pos = extractBetween(NodeName,FirstUnderlineIndex+1,SecondUnderlineIndex-1);
    Lay = extractAfter(NodeName,SecondUnderlineIndex);
    TF = isstrprop(Pos,'digit');
    if ~all(TF)
        return
    end
    TF = isstrprop(Lay,'digit');
    if ~all(TF)
        return
    end
    Pos = str2double(Pos);
    Lay = str2double(Lay);
    Ok = 1;
end