function ModelStruct = ResultToStateSpace(ModelStruct)
    slxPath = ModelStruct.Result.StateSpaceResultPath;
    TemptPath = ModelStruct.Result.TransTemptPath;
    PowerPath = ModelStruct.Result.TransPowerPath;

% 1: get Simulink file's path
    try
        [SimulinkFileDir, SimulinkFileName, SimulinkFileExt] = fileparts(slxPath);
    catch
        error('Simulink file path is not valid');
    end
    SimulinkName = SimulinkFileName;
    Example_1Name = "Example_1";
% 2: Read the T and P files
    try
        [TemperatureData,Type] = ReadFile(TemptPath);
        if ~strcmp(Type,"TTS")
            error('TransTemptFile is not valid');
        end
    catch ME
        ErrorMessage = CatchProcess(ME,1);
        error(ErrorMessage);
    end
    try
        [PowerData,Type] = ReadFile(PowerPath);
        if ~strcmp(Type,"TPS")
            error('TransPowerFile is not valid');
        end
    catch ME
        ErrorMessage = CatchProcess(ME,1);
        error(ErrorMessage);
    end
% 3: get current dir and change to Simulink file's path
    try
        CurrentDir = pwd;
        cd(SimulinkFileDir);
    catch ME
        ErrorMessage = CatchProcess(ME,1);
        error(ErrorMessage);
    end
% 4: create a new Simulink file and overwrite the old one
    try
        new_system(SimulinkName);
        save_system(SimulinkName,SimulinkName,'OverwriteIfChangedOnDisk',true);
        if ~bdIsLoaded(SimulinkName)
            load_system(SimulinkName);
        end
    catch ME
        ErrorMessage = CatchProcess(ME,1);
        error(ErrorMessage);
    end
    try
        if ~bdIsLoaded(Example_1Name)
            load_system(Example_1Name);
        end
    catch ME
        ErrorMessage = CatchProcess(ME,1);
        error(ErrorMessage);
    end
% 5: Process Power and Temperature data
    PHeader = PowerData(1,2:end);
    Ptime = PowerData(2:end,1);
    Pdata = PowerData(2:end,2:end);
    THeader = TemperatureData(1,2:end);
    Ttime = TemperatureData(2:end,1);
    Tdata = TemperatureData(2:end,2:end);
    Nomenclature = ModelStruct.Temp.Nomenclature;
    PHeader = ConvertNodeName(PHeader,Nomenclature);
    THeader = ConvertNodeName(THeader,Nomenclature);
    [PHeader,PIndex] = SortByNodeName(PHeader,ModelStruct.NodeName);
    [THeader,TIndex] = SortByNodeName(THeader,ModelStruct.NodeName);
    Pdata = Pdata(:,PIndex);
    Tdata = Tdata(:,TIndex);
    Ptime = double(Ptime);
    Ttime = double(Ttime);
    Pdata = double(Pdata);
    Tdata = double(Tdata);
    E = ModelStruct.C;
    A = -ModelStruct.G;
    B = diag(ones(size(A,1),1));
    C = B;
    D = zeros(size(A));
    [IsIn,~] = ismember(ModelStruct.NodeName,ModelStruct.NodeNameEffective);
    Ta = Tdata(:,~IsIn);
    Ga = ModelStruct.Ga;
    P = Pdata(:,IsIn);
    x0 = Tdata(1,IsIn);

    ModelStruct.Result.StateSpaceData.PHeader = PHeader;
    ModelStruct.Result.StateSpaceData.Ptime = Ptime;
    ModelStruct.Result.StateSpaceData.PData = Pdata;
    ModelStruct.Result.StateSpaceData.THeader = THeader;
    ModelStruct.Result.StateSpaceData.Ttime = Ttime;
    ModelStruct.Result.StateSpaceData.TData = Tdata;
% 6: add variables to model workspace
    % get the handle of the model workspace
    hws = get_param(SimulinkName, 'modelworkspace');
    hws.assignin('ModelStruct',ModelStruct);
    hws.assignin('PHeader',PHeader);
    hws.assignin('Ptime',Ptime);
    hws.assignin('Pdata',Pdata);
    hws.assignin('THeader',THeader);
    hws.assignin('Ttime',Ttime);
    hws.assignin('Tdata',Tdata);
    hws.assignin('E',E);
    hws.assignin('A',A);
    hws.assignin('B',B);
    hws.assignin('C',C);
    hws.assignin('D',D);
    hws.assignin('Ta',Ta);
    hws.assignin('Ga',Ga);
    hws.assignin('P',P);
    hws.assignin('x0',x0);

    DataSignal = Simulink.Signal;
    DataSignal.Complexity = 'real';
    DataSignal.Dimensions = size(ModelStruct.NodeNameEffective);
    DataSignal.InitialValue = "0";
    DataSignalName = "DataSignal";
    hws.assignin(DataSignalName,DataSignal);

    
% 7: set the simulink seetings
    % set the solver type to fixed-step
    set_param(SimulinkName,'SolverType','Variable-step');
    % set the solver mode to auto
    set_param(SimulinkName,'SolverMode','Auto');
    % Set the simulation time for the model
    set_param(SimulinkName,'StopTime',string(min(Ttime(end),Ptime(end))));
    % set the step size
    set_param(SimulinkName,'FixedStep','Auto');


    
    % Add Blocks
    try
        ReferPoint = [0,0];
        % add the Descriptor State-Space block
        Name = "State-Space";
        ExampleBlockName = "Descriptor State-Space";
        BlockPath = SimulinkName + "/" + Name;
        BlockLib = Example_1Name + "/" + ExampleBlockName;
        try
            add_block(BlockLib,BlockPath);
        catch
        end
        Position = get_param(BlockPath,'Position');
        BlockSize = [Position(3)-Position(1),Position(4)-Position(2)];
        PosPoint = ReferPoint;
        NewPosition = [PosPoint,PosPoint + BlockSize];
        set_param(BlockPath,'Position',NewPosition);
        % set the parameters of the Descriptor State-Space block
        set_param(BlockPath,'A','A','B','B','C','C','D','D','E','E','InitialCondition','x0');
        
        % add the from workspace block
        % P
        Name = "P";
        ExampleBlockName = "From Workspace P";
        BlockPath = SimulinkName + "/" + Name;
        BlockLib = Example_1Name + "/" + ExampleBlockName;
        try
            add_block(BlockLib,BlockPath);
        catch
        end
        Position = get_param(BlockPath,'Position');
        BlockSize = [Position(3)-Position(1),Position(4)-Position(2)];
        PosPoint = ReferPoint + [-300,100];
        NewPosition = [PosPoint,PosPoint + BlockSize];
        set_param(BlockPath,'Position',NewPosition);
        % set the parameters of the from workspace block
        VariableName = "[Ptime,P]";
        set_param(BlockPath,'VariableName',VariableName);
        % Ta
        Name = "Ta";
        ExampleBlockName = "From Workspace P";
        BlockPath = SimulinkName + "/" + Name;
        BlockLib = Example_1Name + "/" + ExampleBlockName;
        try
            add_block(BlockLib,BlockPath);
        catch
        end
        Position = get_param(BlockPath,'Position');
        BlockSize = [Position(3)-Position(1),Position(4)-Position(2)];
        PosPoint = ReferPoint + [-300,-100];
        NewPosition = [PosPoint,PosPoint + BlockSize];
        set_param(BlockPath,'Position',NewPosition);
        % set the parameters of the from workspace block
        VariableName = "[Ttime,Ta]";
        set_param(BlockPath,'VariableName',VariableName);
        % Ga
        Name = "Ga";
        ExampleBlockName = "Gain Ga";
        BlockPath = SimulinkName + "/" + Name;
        BlockLib = Example_1Name + "/" + ExampleBlockName;
        try
            add_block(BlockLib,BlockPath);
        catch
        end
        Position = get_param(BlockPath,'Position');
        BlockSize = [Position(3)-Position(1),Position(4)-Position(2)];
        PosPoint = ReferPoint + [-200,-100];
        NewPosition = [PosPoint,PosPoint + BlockSize];
        set_param(BlockPath,'Position',NewPosition);
        % set the parameters of the from workspace block
        Gain = "Ga";
        set_param(BlockPath,'Gain',Gain);

        % add the P+GaTa to workspace block
        Name = "P+GaTa";
        ExampleBlockName = "P+GaTa";
        BlockPath = SimulinkName + "/" + Name;
        BlockLib = Example_1Name + "/" + ExampleBlockName;
        try
            add_block(BlockLib,BlockPath);
        catch
        end
        Position = get_param(BlockPath,'Position');
        BlockSize = [Position(3)-Position(1),Position(4)-Position(2)];
        PosPoint = ReferPoint + [-100,0];
        NewPosition = [PosPoint,PosPoint + BlockSize];
        set_param(BlockPath,'Position',NewPosition);
        
        % add the scope to workspace block
        Name = "Scope";
        ExampleBlockName = "Scope";
        BlockPath = SimulinkName + "/" + Name;
        BlockLib = Example_1Name + "/" + ExampleBlockName;
        try
            add_block(BlockLib,BlockPath);
        catch
        end
        Position = get_param(BlockPath,'Position');
        BlockSize = [Position(3)-Position(1),Position(4)-Position(2)];
        PosPoint = ReferPoint + [100,0];
        NewPosition = [PosPoint,PosPoint + BlockSize];
        set_param(BlockPath,'Position',NewPosition);
        
    % add the connection
        % connect the P+GaTa and State-Space
        BlockName1 = "P+GaTa";
        BlockName2 = "State-Space";
        try
            add_line(SimulinkName,BlockName1 + "/1",BlockName2 + "/1");
        catch
        end
        % connect the State-Space and Scope
        BlockName1 = "State-Space";
        BlockName2 = "Scope";
        try
            add_line(SimulinkName,BlockName1 + "/1",BlockName2 + "/1");
        catch
        end
        % connect the Ga and P+GaTa
        BlockName1 = "Ga";
        BlockName2 = "P+GaTa";
        try
            add_line(SimulinkName,BlockName1 + "/1",BlockName2 + "/1");
        catch
        end
        % connect the P and P+GaTa
        BlockName1 = "P";
        BlockName2 = "P+GaTa";
        try
            add_line(SimulinkName,BlockName1 + "/1",BlockName2 + "/2");
        catch
        end
        % connect the Ta and Ga
        BlockName1 = "Ta";
        BlockName2 = "Ga";
        try
            add_line(SimulinkName,BlockName1 + "/1",BlockName2 + "/1");
        catch
        end
    catch ME
        save_system(SimulinkName,SimulinkName,'OverwriteIfChangedOnDisk',true);
        close_system(Example_1Name,0);
        close_system(SimulinkName,0);
        cd(CurrentDir);
        ErrorMessage = CatchProcess(ME);
        error(ErrorMessage);
    end
    % save
    save_system(SimulinkName,SimulinkName,'OverwriteIfChangedOnDisk',true);
    Out = sim(SimulinkName);
    ModelStruct.Result.StateSpaceData.Out = Out;
    close_system(Example_1Name,0);
    close_system(SimulinkName,0);
    % back to the original folder
    cd(CurrentDir);
end







