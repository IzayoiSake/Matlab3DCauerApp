function [Ok,Pos,Lay] = OriginalName_Check(NodeName)
    Ok = 0;
    Pos = 0;
    Lay = 0;
% check if NodeName has '.'
    DotIndex = strfind(NodeName,'.');
    if isempty(DotIndex)
        return
    end
% check if NodeName has 'P.'
    PDotIndex = strfind(NodeName,'P.');
    if isempty(PDotIndex) || PDotIndex~=1
        return
    end
% check if NodeName has more than one '.'
    FirstDotIndex = DotIndex(1);
    if length(DotIndex)>1
        SecondDotIndex = DotIndex(2);
    else
        SecondDotIndex = strlength(NodeName)+1;
    end
    Pos = extractBetween(NodeName,FirstDotIndex+1,SecondDotIndex-1);
    TF = isstrprop(Pos,'digit');
    if ~all(TF)
        return
    end
    Pos = str2double(Pos);
    if length(DotIndex)>1
        try
            Suffix = extractAfter(NodeName,SecondDotIndex-1);
        catch
            return
        end
        % Check if the suffix is ".1" loop string
        SuffixTest = strrep(Suffix,'.1','');
        if ~strcmp(SuffixTest,'')
            return
        end
        Lay = strlength(Suffix)/2+1;
        Ok = 1;
    else
        Lay = 1;
        Ok = 1;
    end
end 