function [NodeName] = OriginalName_Gen(Pos,Lay)
% OriginalName_Gen generates the original name of the node

    Pos = double(Pos);
    Lay = double(Lay);
    Header = "P.";
    PosStr = num2str(Pos);
    LayStr = '';
    for i = 1:Lay-1
        LayStr = LayStr+".1";
    end
    NodeName = Header+PosStr+LayStr;
end 