function test()
    import Cauer3D.Model.*
    import Cauer3D.UI.*
    import Cauer3D.Nomenclature.*
    import Cauer3D.Plot.*
    import Cauer3D.Export.*
    import Cauer3D.IO.*
    import Cauer3D.Internal.*
% create a signal
packageRoot = fileparts(fileparts(mfilename("fullpath")));
examplePath = fullfile(packageRoot, ...
    "resources", "Example_1.slx");
load_system(examplePath);
hws = get_param("Example_1", 'modelworkspace');
% get the signal from the model workspace
Signal = Simulink.Signal;
Signal.Dimensions = [11,2];
Signal.Complexity = 'real';
Signal.InitialValue = '0';
hws.assignin('Signal',Signal);
DSW.Name = get_param("Example_1/DSW","DataStoreName");
DSW.Data = get_param("Example_1/DSW","DataStoreElements");
DSW.Or = get_param("Example_1/DSW","Orientation");
DSW.Data = 'DataSignal(2,1)';
set_param("Example_1/DSW","DataStoreElements",DSW.Data);
get_param("Example_1/VM","PortConnectivity")
close_system("Example_1",0);
end
