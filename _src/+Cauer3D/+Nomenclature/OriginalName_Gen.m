function [NodeName] = OriginalName_Gen(Pos,Lay)
    import Cauer3D.Model.*
    import Cauer3D.UI.*
    import Cauer3D.Nomenclature.*
    import Cauer3D.Plot.*
    import Cauer3D.Export.*
    import Cauer3D.IO.*
    import Cauer3D.Internal.*
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