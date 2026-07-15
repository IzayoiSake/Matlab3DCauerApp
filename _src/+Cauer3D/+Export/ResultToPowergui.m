
function ModelStruct = ResultToPowergui(ModelStruct)
    import Cauer3D.Model.*
    import Cauer3D.UI.*
    import Cauer3D.Nomenclature.*
    import Cauer3D.Plot.*
    import Cauer3D.Export.*
    import Cauer3D.IO.*
    import Cauer3D.Internal.*
    slxPath = ModelStruct.Result.CircuitResultPath;
    SimulinkName = "";
    try
    % 1: get Simulink file's path
        try
            [SimulinkFileDir, SimulinkFileName, ~] = fileparts(slxPath);
        catch
            error('Simulink file path is not valid');
        end
        SimulinkName = SimulinkFileName;
    % 2: Get the cached test data
        try
            TestData = ModelStruct.Result.TestData;
            PHeader = TestData.PHeader;
            Ptime = TestData.Ptime;
            Pdata = TestData.PData;
            THeader = TestData.THeader;
            Ttime = TestData.Ttime;
            Tdata = TestData.TData;
        catch ME
            error("Test data is not loaded. " + CatchProcess(ME, 1));
        end
    % 3: check the output folder
        try
            if SimulinkFileDir ~= "" && ~exist(SimulinkFileDir, 'dir')
                mkdir(SimulinkFileDir);
            end
        catch ME
            ErrorMessage = CatchProcess(ME,1);
            error(ErrorMessage);
        end
    % 4: create a new Simulink file and overwrite the old one
        try
            if bdIsLoaded(SimulinkName)
                close_system(SimulinkName,0);
            end
            new_system(SimulinkName);
            save_system(SimulinkName,slxPath,'OverwriteIfChangedOnDisk',true);
        catch ME
            ErrorMessage = CatchProcess(ME,1);
            error(ErrorMessage);
        end
    % 5: Save the data used to generate the circuit
        ModelStruct.Result.CircuitData.PHeader = PHeader;
        ModelStruct.Result.CircuitData.Ptime = Ptime;
        ModelStruct.Result.CircuitData.PData = Pdata;
        ModelStruct.Result.CircuitData.THeader = THeader;
        ModelStruct.Result.CircuitData.Ttime = Ttime;
        ModelStruct.Result.CircuitData.TData = Tdata;
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
        hws.assignin('StepSize',ModelStruct.Temp.StepSize);
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
            Position = [0,0];
        % Add the Simscape Solver Configuration block
            Name = "Solver Configuration";
            BlockPath = SimulinkName + "/" + Name;
            BlockLib = "nesl_utility/Solver Configuration";
            try
                add_block(BlockLib, BlockPath);
            catch
                
            end
            set_param(BlockPath,"UseLocalSolver","on");
            set_param(BlockPath,"LocalSolverChoice","NE_TRAPEZOIDAL_ADVANCER");
            set_param(BlockPath,"LocalSolverSampleTime","StepSize");
            % set the block position
            BlockSize = [100,100];
            Position = Position + [200,0];
            Rect = [Position,Position + BlockSize];
            set_param(BlockPath,"Position",Rect);
        % Capacitors
            for i = 1:length(ModelStruct.NodeNameEffective)
                Name = "C-" + ModelStruct.NodeNameEffective(i);
                BlockPath = SimulinkName + "/" + Name;
                BlockLib = "fl_lib/Electrical/Electrical Elements/Capacitor";
                try
                    add_block(BlockLib, BlockPath);
                catch
                    
                end
                % set the block parameters
                set_param(BlockPath,"c","ModelStruct.Cr(" + i + ")");
                Index = find(THeader == ModelStruct.NodeNameEffective(i));
                VariableName = "Tdata(1," + Index + ")";
                set_param(BlockPath,"vc_specify","on");
                set_param(BlockPath,"vc_priority","High");
                set_param(BlockPath,"vc",VariableName);
                % set the block position
                if ~exist('Position','var')
                    Position = [0,0];
                end
                BlockSize = [100,100];
                [Pos,Layer] = GetNodePosAndLay(ModelStruct.NodeNameEffective(i));
                PositionC = Position + [400,0] .* Pos + [0,400] .* Layer;
                Rect = [PositionC,PositionC + BlockSize];
                set_param(BlockPath,"Position",Rect);
                set_param(BlockPath,"Orientation","down");
            end
        % Grounds for Capacitors
            for i = 1:length(ModelStruct.NodeNameEffective)
                Name = "Ground-C-" + ModelStruct.NodeNameEffective(i);
                CName = "C-" + ModelStruct.NodeNameEffective(i);
                BlockPath = SimulinkName + "/" + Name;
                BlockLib = "fl_lib/Electrical/Electrical Elements/Electrical Reference";
                try
                    add_block(BlockLib, BlockPath);
                catch
                    
                end
                % set the block parameters
                % set the block position
                if ~exist('Position','var')
                    Position = [0,0];
                end
                CPosition = get_param(SimulinkName + "/" + CName,"Position");
                GPosition = CPosition + [0,100,0,100];
                set_param(BlockPath,"Position",GPosition);
            end
        % Voltage measuremens for Capacitors
            for i = 1:length(ModelStruct.NodeNameEffective)
                Name = "VolMea-C-" + ModelStruct.NodeNameEffective(i);
                BlockPath = SimulinkName + "/" + Name;
                BlockLib = "fl_lib/Electrical/Electrical Sensors/Voltage Sensor";
                try
                    add_block(BlockLib, BlockPath);
                catch
                    
                end
                CName = "C-" + ModelStruct.NodeNameEffective(i);
                CPosition = get_param(SimulinkName + "/" + CName,"Position");
                CPosition = [CPosition(1),CPosition(2)];
                OriginalSize = get_param(BlockPath,"Position");
                OriginalSize = [OriginalSize(3)-OriginalSize(1),OriginalSize(4)-OriginalSize(2)];
                BlockSize = OriginalSize;
                VolMeaPosition = CPosition + [-50,0];
                Rect = [VolMeaPosition,VolMeaPosition + BlockSize];
                set_param(BlockPath,"Position",Rect);
                % rotate the block to the left
                set_param(BlockPath,"Orientation","left");
            end
        % PS-Simulink converters for voltage measurements
            for i = 1:length(ModelStruct.NodeNameEffective)
                Name = "PSS-C-" + ModelStruct.NodeNameEffective(i);
                BlockPath = SimulinkName + "/" + Name;
                BlockLib = "nesl_utility/PS-Simulink Converter";
                try
                    add_block(BlockLib, BlockPath);
                catch

                end
                set_param(BlockPath,"Unit","V");
                CName = "C-" + ModelStruct.NodeNameEffective(i);
                CPosition = get_param(SimulinkName + "/" + CName,"Position");
                CPosition = [CPosition(1),CPosition(2)];
                OriginalSize = get_param(BlockPath,"Position");
                OriginalSize = [OriginalSize(3)-OriginalSize(1),OriginalSize(4)-OriginalSize(2)];
                BlockSize = OriginalSize;
                ConverterPosition = CPosition + [-100,0];
                Rect = [ConverterPosition,ConverterPosition + BlockSize];
                set_param(BlockPath,"Position",Rect);
                set_param(BlockPath,"Orientation","left");
            end
        % Data Store Write for Capacitors
            for i = 1:length(ModelStruct.NodeNameEffective)
                Name = "DSW-C-" + ModelStruct.NodeNameEffective(i);
                BlockPath = SimulinkName + "/" + Name;
                BlockLib = "simulink/Signal Routing/Data Store Write";
                try
                    add_block(BlockLib, BlockPath);
                catch
                    
                end
                % set the block parameters
                set_param(BlockPath,"DataStoreName",DataSignalName);
                set_param(BlockPath,"DataStoreElements",DataSignalName + "(" + i + ",1)");
                % set the block position
                CName = "C-" + ModelStruct.NodeNameEffective(i);
                CPosition = get_param(SimulinkName + "/" + CName,"Position");
                CPosition = [CPosition(1),CPosition(2)];
                DataStoreWritePosition = CPosition + [-200,0];
                OriginalSize = get_param(BlockPath,"Position");
                OriginalSize = [OriginalSize(3)-OriginalSize(1),OriginalSize(4)-OriginalSize(2)];
                BlockSize = OriginalSize;
                Rect = [DataStoreWritePosition,DataStoreWritePosition + BlockSize];
                set_param(BlockPath,"Position",Rect);
                % rotate the block to the left
                set_param(BlockPath,"Orientation","left");
            end

        % Data Store Read
            Name = "DSR";
            BlockPath = SimulinkName + "/" + Name;
            BlockLib = "simulink/Signal Routing/Data Store Read";
            try
                add_block(BlockLib, BlockPath);
            catch
                
            end
            % set the block parameters
            set_param(BlockPath,"DataStoreName",DataSignalName);
            set_param(BlockPath,"DataStoreElements",DataSignalName);
            % set the block position
            OriginalSize = get_param(BlockPath,"Position");
            OriginalSize = [OriginalSize(3)-OriginalSize(1),OriginalSize(4)-OriginalSize(2)];
            BlockSize = OriginalSize;
            DataStoreReadPosition = Position + [0,200];
            Rect = [DataStoreReadPosition,DataStoreReadPosition + BlockSize];
            set_param(BlockPath,"Position",Rect);


        % Scope connected to Data Store Read
            Name = "ScopeDSR";
            BlockPath = SimulinkName + "/" + Name;
            BlockLib = "simulink/Sinks/Scope";
            try
                add_block(BlockLib, BlockPath);
            catch
                
            end
            % set the block parameters
            
            % set the block position
            ScopePosition = Position + [100,200];
            OriginalSize = get_param(BlockPath,"Position");
            OriginalSize = [OriginalSize(3)-OriginalSize(1),OriginalSize(4)-OriginalSize(2)];
            BlockSize = OriginalSize;
            Rect = [ScopePosition,ScopePosition + BlockSize];
            set_param(BlockPath,"Position",Rect);

        % To Workspace connected to Data Store Read
            Name = "CauerDataToWorkspace";
            BlockPath = SimulinkName + "/" + Name;
            BlockLib = "simulink/Sinks/To Workspace";
            try
                add_block(BlockLib, BlockPath);
            catch

            end
            set_param(BlockPath,"VariableName","CauerScopeData");
            set_param(BlockPath,"SaveFormat","StructureWithTime");
            ToWorkspacePosition = Position + [100,260];
            OriginalSize = get_param(BlockPath,"Position");
            OriginalSize = [OriginalSize(3)-OriginalSize(1),OriginalSize(4)-OriginalSize(2)];
            BlockSize = OriginalSize;
            Rect = [ToWorkspacePosition,ToWorkspacePosition + BlockSize];
            set_param(BlockPath,"Position",Rect);

        % Resistors
            for i = 1:size(ModelStruct.GrName,1)
                Name = "R-(" + ModelStruct.GrName(i,1) + "," + ModelStruct.GrName(i,2) + ")";
                BlockPath = SimulinkName + "/" + Name;
                BlockLib = "fl_lib/Electrical/Electrical Elements/Resistor";
                try
                    add_block(BlockLib, BlockPath);
                catch
                    
                end
                % set the block parameters
                set_param(BlockPath,"R","1/ModelStruct.Gr(" + i + ")");
                % set the block position
                if ismember(ModelStruct.GrName(i,1),ModelStruct.NodeNameEffective)
                    CName1 = "C-" + ModelStruct.GrName(i,1);
                    PositionC1 = get_param(SimulinkName + "/" + CName1,"Position");
                else
                    CName1 = "";
                    PositionC1 = [];
                end
                if ismember(ModelStruct.GrName(i,2),ModelStruct.NodeNameEffective)
                    CName2 = "C-" + ModelStruct.GrName(i,2);
                    PositionC2 = get_param(SimulinkName + "/" + CName2,"Position");
                else
                    CName2 = "";
                    PositionC2 = [];
                end
                [~,Layer1] = GetNodePosAndLay(ModelStruct.GrName(i,1));
                [~,Layer2] = GetNodePosAndLay(ModelStruct.GrName(i,2));
                if CName1 == "" && CName2 == ""
                    error("Neither end of the resistor is on the capacitor node");
                elseif Layer2 == Layer1 + 1 || CName2 == ""
                    PositionR = PositionC1 + [100,200,100,200];
                    set_param(BlockPath,"Orientation","down");
                elseif Layer1 == Layer2 + 1 || CName1 == ""
                    PositionR = PositionC2 + [100,200,100,200];
                    set_param(BlockPath,"Orientation","down");
                else
                    PositionR = PositionC1 + [200,0,200,0];
                end
                set_param(BlockPath,"Position",PositionR);
            end
        % CCS,Grounds for CCS,CCS Inputs
            for i = 1:length(ModelStruct.NodeNameEffective)
                Name = "CCS-" + ModelStruct.NodeNameEffective(i);
                BlockPath = SimulinkName + "/" + Name;
                [~,Layer] = GetNodePosAndLay(ModelStruct.NodeNameEffective(i));
                if Layer ~= 1
                    continue;
                end
                BlockLib = "fl_lib/Electrical/Electrical Sources/Controlled Current Source";
                try
                    add_block(BlockLib, BlockPath);
                catch
                    
                end
                % set the block parameters
                % set the block position
                CName = "C-" + ModelStruct.NodeNameEffective(i);
                PositionC = get_param(SimulinkName + "/" + CName,"Position");
                PositionCCS = PositionC + [0,-200,0,-200];
                set_param(BlockPath,"Position",PositionCCS);
                set_param(BlockPath,"Orientation","down");
            % Add the grounds for CCS
                Name = "Ground-CCS-" + ModelStruct.NodeNameEffective(i);
                BlockPath = SimulinkName + "/" + Name;
                BlockLib = "fl_lib/Electrical/Electrical Elements/Electrical Reference";
                try
                    add_block(BlockLib, BlockPath);
                catch
                    
                end
                % set the block parameters
                % set the block position
                PositionG = PositionCCS + [50,-100,0,-150];
                set_param(BlockPath,"Position",PositionG);
                set_param(BlockPath,"Orientation","up");
            % Add the CCS inputs
                Name = "CCSInput-" + ModelStruct.NodeNameEffective(i);
                BlockPath = SimulinkName + "/" + Name;
                BlockLib = "simulink/Sources/From Workspace";
                try
                    add_block(BlockLib, BlockPath);
                catch
                    
                end
                % set the block parameters
                Index = find(PHeader == ModelStruct.NodeNameEffective(i));
                VariableName = "[Ptime,Pdata(:," + Index + ")]";
                set_param(BlockPath,"VariableName",VariableName);
                set_param(BlockPath,"Interpolate","on");
                set_param(BlockPath,"OutputAfterFinalValue","Holding final value");
                % set the block position
                PositionCCSInput = PositionCCS + [0,-100,-50,-150];
                set_param(BlockPath,"Position",PositionCCSInput);
                set_param(BlockPath,"Orientation","down");
            % Add the Simulink-PS converter for CCS input
                Name = "SPS-CCS-" + ModelStruct.NodeNameEffective(i);
                BlockPath = SimulinkName + "/" + Name;
                BlockLib = "nesl_utility/Simulink-PS Converter";
                try
                    add_block(BlockLib, BlockPath);
                catch

                end
                set_param(BlockPath,"Unit","A");
                PositionCCSInput = PositionCCS + [0,-50,-50,-100];
                set_param(BlockPath,"Position",PositionCCSInput);
                set_param(BlockPath,"Orientation","down");
            end
        % CVS,Grounds for CVS,CVS Inputs
            for i = 1:length(ModelStruct.NodeName)
                [~,Layer] = GetNodePosAndLay(ModelStruct.NodeName(i));
                if Layer ~= ModelStruct.LayerNum
                    continue;
                end
                Name = "CVS-" + ModelStruct.NodeName(i);
                BlockPath = SimulinkName + "/" + Name;
                BlockLib = "fl_lib/Electrical/Electrical Sources/Controlled Voltage Source";
                try
                    add_block(BlockLib, BlockPath);
                catch
                    
                end
                % set the block parameters
                % set the block position
                Links = ModelStruct.NodeLink{i};
                Links = string(Links);
                GrIndex = FindGrIndex(...
                    Links,...
                    ModelStruct.GrName,...
                    ModelStruct.NodeName(i)...
                );
                GrNameNeed = ModelStruct.GrName(GrIndex,:);
                RName = "R-(" + GrNameNeed(1,1) + "," + GrNameNeed(1,2) + ")";
                PositionR = get_param(SimulinkName + "/" + RName,"Position");
                PositionCVS = PositionR + [0,200,0,200];
                set_param(BlockPath,"Position",PositionCVS);
                set_param(BlockPath,"Orientation","up");
            % Add the grounds for CVS
                Name = "Ground-CVS-" + ModelStruct.NodeName(i);
                BlockPath = SimulinkName + "/" + Name;
                BlockLib = "fl_lib/Electrical/Electrical Elements/Electrical Reference";
                try
                    add_block(BlockLib, BlockPath);
                catch
                    
                end
                % set the block parameters
                % set the block position
                PositionG = PositionCVS + [50,150,0,100];
                set_param(BlockPath,"Position",PositionG);
                set_param(BlockPath,"Orientation","down");
            % Add the CVS inputs
                Name = "CVSInput-" + ModelStruct.NodeName(i);
                BlockPath = SimulinkName + "/" + Name;
                BlockLib = "simulink/Sources/From Workspace";
                try
                    add_block(BlockLib, BlockPath);
                catch
                    
                end
                % set the block parameters
                Index = find(THeader == ModelStruct.NodeName(i));
                VariableName = "[Ttime,Tdata(:," + Index + ")]";
                set_param(BlockPath,"VariableName",VariableName);
                set_param(BlockPath,"Interpolate","on");
                set_param(BlockPath,"OutputAfterFinalValue","Holding final value");
                % set the block position
                PositionCVSInput = PositionCVS + [0,150,-50,100];
                set_param(BlockPath,"Position",PositionCVSInput);
                set_param(BlockPath,"Orientation","up");
            % Add the Simulink-PS converter for CVS input
                Name = "SPS-CVS-" + ModelStruct.NodeName(i);
                BlockPath = SimulinkName + "/" + Name;
                BlockLib = "nesl_utility/Simulink-PS Converter";
                try
                    add_block(BlockLib, BlockPath);
                catch

                end
                set_param(BlockPath,"Unit","V");
                PositionCVSInput = PositionCVS + [0,100,-50,50];
                set_param(BlockPath,"Position",PositionCVSInput);
                set_param(BlockPath,"Orientation","up");
            end







    % Connections
            AllBlocks = find_system(SimulinkName);
            AllBlocks = AllBlocks(2:end);
            % AllLines = find_system(SimulinkName,"FindAll","on","type","line");
        % Connect the capacitor resistor
            for i = 1:size(ModelStruct.GrName,1)
                CName1 = "C-" + ModelStruct.GrName(i,1);
                CName2 = "C-" + ModelStruct.GrName(i,2);
                RName = "R-(" + ModelStruct.GrName(i,1) + "," + ModelStruct.GrName(i,2) + ")";
                if ismember(ModelStruct.GrName(i,1),ModelStruct.NodeNameEffective)
                    try
                        add_line(SimulinkName,CName1 + "/LConn1",RName + "/LConn1");
                    catch 
                    end
                end
                if ismember(ModelStruct.GrName(i,2),ModelStruct.NodeNameEffective)
                    try
                        add_line(SimulinkName,CName2 + "/LConn1",RName + "/RConn1");
                    catch 
                    end
                end
            end
        % Connect capacitor to ground
            for i = 1:length(ModelStruct.NodeNameEffective)
                CName = "C-" + ModelStruct.NodeNameEffective(i);
                GName = "Ground-C-" + ModelStruct.NodeNameEffective(i);
                try
                    add_line(SimulinkName,CName + "/RConn1",GName + "/LConn1");
                    if i == 1
                        add_line(SimulinkName,"Solver Configuration/RConn1",GName + "/LConn1");
                    end
                catch 
                end
            end
        % Connect capacitor and Voltage measuremens
            for i = 1:length(ModelStruct.NodeNameEffective)
                CName = "C-" + ModelStruct.NodeNameEffective(i);
                VName = "VolMea-C-" + ModelStruct.NodeNameEffective(i);
                try
                    add_line(SimulinkName,CName + "/LConn1",VName + "/LConn1");
                    add_line(SimulinkName,CName + "/RConn1",VName + "/RConn2");
                catch 
                end
            end
        % Connect Voltage measuremens and Data Store Write
            for i = 1:length(ModelStruct.NodeNameEffective)
                VName = "VolMea-C-" + ModelStruct.NodeNameEffective(i);
                PSSName = "PSS-C-" + ModelStruct.NodeNameEffective(i);
                DSName = "DSW-C-" + ModelStruct.NodeNameEffective(i);
                try
                    add_line(SimulinkName,VName + "/RConn1",PSSName + "/LConn1");
                    add_line(SimulinkName,PSSName + "/1",DSName + "/1");
                catch 
                end
            end
        % Connect Data Store Read and Scope
            DSName = "DSR";
            ScopeName = "ScopeDSR";
            ToWorkspaceName = "CauerDataToWorkspace";
            try
                add_line(SimulinkName,DSName + "/1",ScopeName + "/1");
                add_line(SimulinkName,DSName + "/1",ToWorkspaceName + "/1");
            catch 
            end

        % Connect current source and ground
            for i = 1:length(ModelStruct.NodeName)
                CCSName = "CCS-" + ModelStruct.NodeName(i);
                GName = "Ground-CCS-" + ModelStruct.NodeName(i);
                if ismember(SimulinkName + "/" + CCSName,AllBlocks)
                    try
                        add_line(SimulinkName,CCSName + "/RConn2",GName + "/LConn1");
                    catch 
                    end
                end
            end
        % Connecting Current Sources and Current Source Inputs
            for i = 1:length(ModelStruct.NodeName)
                CCSName = "CCS-" + ModelStruct.NodeName(i);
                CCSInputName = "CCSInput-" + ModelStruct.NodeName(i);
                SPSName = "SPS-CCS-" + ModelStruct.NodeName(i);
                if ismember(SimulinkName + "/" + CCSName,AllBlocks)
                    try
                        add_line(SimulinkName,CCSInputName + "/1",SPSName + "/1");
                        add_line(SimulinkName,SPSName + "/RConn1",CCSName + "/RConn1");
                    catch 
                    end
                end
            end
        % Connect the voltage source and ground
            for i = 1:length(ModelStruct.NodeName)
                CVSName = "CVS-" + ModelStruct.NodeName(i);
                GName = "Ground-CVS-" + ModelStruct.NodeName(i);
                if ismember(SimulinkName + "/" + CVSName,AllBlocks)
                    try
                        add_line(SimulinkName,CVSName + "/RConn2",GName + "/LConn1");
                    catch 
                    end
                end
            end
        % Connecting Voltage Sources and Voltage Source Inputs
            for i = 1:length(ModelStruct.NodeName)
                CVSName = "CVS-" + ModelStruct.NodeName(i);
                CVSInputName = "CVSInput-" + ModelStruct.NodeName(i);
                SPSName = "SPS-CVS-" + ModelStruct.NodeName(i);
                if ismember(SimulinkName + "/" + CVSName,AllBlocks)
                    try
                        add_line(SimulinkName,CVSInputName + "/1",SPSName + "/1");
                        add_line(SimulinkName,SPSName + "/RConn1",CVSName + "/RConn1");
                    catch 
                    end
                end
            end
        % Connect the current source and capacitor
            for i = 1:length(ModelStruct.NodeName)
                CCSName = "CCS-" + ModelStruct.NodeName(i);
                CName = "C-" + ModelStruct.NodeName(i);
                if ismember(SimulinkName + "/" + CCSName,AllBlocks)
                    try
                        add_line(SimulinkName,CCSName + "/LConn1",CName + "/LConn1");
                    catch 
                    end
                end
            end
        % Connect the voltage source and resistor
            for i = 1:size(ModelStruct.GrName,1)
                CVSName1 = "CVS-" + ModelStruct.GrName(i,1);
                CVSName2 = "CVS-" + ModelStruct.GrName(i,2);
                RName = "R-(" + ModelStruct.GrName(i,1) + "," + ModelStruct.GrName(i,2) + ")";
                if ismember(SimulinkName + "/" + CVSName1,AllBlocks)
                    try
                        add_line(SimulinkName,CVSName1 + "/LConn1",RName + "/RConn1");
                    catch 
                    end
                elseif ismember(SimulinkName + "/" + CVSName2,AllBlocks)
                    try
                        add_line(SimulinkName,CVSName2 + "/LConn1",RName + "/RConn1");
                    catch 
                    end
                end
            end
        catch ME
            if SimulinkName ~= "" && bdIsLoaded(SimulinkName)
                save_system(SimulinkName,slxPath,'OverwriteIfChangedOnDisk',true);
                close_system(SimulinkName,0);
            end
            ErrorMessage = CatchProcess(ME);
            error(ErrorMessage);
        end
    % save
        save_system(SimulinkName,slxPath,'OverwriteIfChangedOnDisk',true);
        Out = sim(SimulinkName);
        ModelStruct.Result.CircuitData.Out = Out;
        close_system(SimulinkName,0);
    catch ME
        if SimulinkName ~= "" && bdIsLoaded(SimulinkName)
            close_system(SimulinkName,0);
        end
        ErrorMessage = CatchProcess(ME);
        error(ErrorMessage);
    end
end
