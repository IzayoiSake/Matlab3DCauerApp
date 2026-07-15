function CloseAppPreProcess(app,event)
    import Cauer3D.Model.*
    import Cauer3D.UI.*
    import Cauer3D.Nomenclature.*
    import Cauer3D.Plot.*
    import Cauer3D.Export.*
    import Cauer3D.IO.*
    import Cauer3D.Internal.*
    % remove the "src" folder and all subfolders from the path
    % rmpath(genpath('_src'));
end