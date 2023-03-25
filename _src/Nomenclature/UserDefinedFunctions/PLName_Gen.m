function [NodeName] = PLName_Gen(Pos,Lay)
% PLName_Gen: Generate a NodeName in the form of "PLName"


    Pos = double(Pos);
    Lay = double(Lay);
    Header = "P";
    PosStr = "_"+num2str(Pos);
    LayStr = "_"+num2str(Lay);
    NodeName = Header+PosStr+LayStr;
end