function [NodeName] = PLName_Gen(Pos,Lay)
    import Cauer3D.Model.*
    import Cauer3D.UI.*
    import Cauer3D.Nomenclature.*
    import Cauer3D.Plot.*
    import Cauer3D.Export.*
    import Cauer3D.IO.*
    import Cauer3D.Internal.*
% PLName_Gen: Generate a NodeName in the form of "PLName"


    Pos = double(Pos);
    Lay = double(Lay);
    Header = "P";
    PosStr = "_"+num2str(Pos);
    LayStr = "_"+num2str(Lay);
    NodeName = Header+PosStr+LayStr;
end