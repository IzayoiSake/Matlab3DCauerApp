
function ModelStruct = ResultToPowergui(ModelStruct)
    slxPath = ModelStruct.Result.CircuitResultPath;
    TemptPath = ModelStruct.Result.TransTemptPath;
    PowerPath = ModelStruct.Result.TransPowerPath;
    try
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
        % Add the powergui block
            Name = "Powergui";
            BlockPath = SimulinkName + "/" + Name;
            BlockLib = "spspowerguiLib/powergui";
            try
                add_block(BlockLib, BlockPath);
            catch
                
            end
            % set the block parameters
            set_param(BlockPath,"SimulationMode","Continuous");
            StepSize = ModelStruct.Temp.StepSize;
            StepSize = string(StepSize);
            % set_param(BlockPath,"SampleTime",StepSize);
            % set the block position
            BlockSize = [100,100];
            if ~exist('Position','var')
                Position = [0,0];
            else
                Position = Position + [200,0];
            end
            Rect = [Position,Position + BlockSize];
            set_param(BlockPath,"Position",Rect);
        % Capacitors
            for i = 1:length(ModelStruct.NodeNameEffective)
                Name = "C-" + ModelStruct.NodeNameEffective(i);
                BlockPath = SimulinkName + "/" + Name;
                BlockLib = "sps_lib/Passives/Series RLC Branch";
                try
                    add_block(BlockLib, BlockPath);
                catch
                    
                end
                % set the block parameters
                set_param(BlockPath,"BranchType","C");
                set_param(BlockPath,"Capacitance","ModelStruct.Cr(" + i + ")");
                set_param(BlockPath,"Measurements","Branch voltage and current");
                set_param(BlockPath,"Setx0","on");
                Index = find(THeader == ModelStruct.NodeNameEffective(i));
                VariableName = "Tdata(1," + Index + ")";
                set_param(BlockPath,"InitialVoltage",VariableName);
                % set the block position
                if ~exist('Position','var')
                    Position = [0,0];
                end
                OriginalSize = get_param(BlockPath,"Position");
                OriginalSize = [OriginalSize(3)-OriginalSize(1),OriginalSize(4)-OriginalSize(2)];
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
                BlockLib = "sps_lib/Utilities/Ground";
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
        % Voltage measuremens for Capacitors (Copy VM from Example_1/VM)
            for i = 1:length(ModelStruct.NodeNameEffective)
                Name = "VolMea-C-" + ModelStruct.NodeNameEffective(i);
                ExampleBlockName = "VM";
                BlockPath = SimulinkName + "/" + Name;
                % BlockLib = "sps_lib/Sensors and Measurements/Voltage Measurement";
                BlockLib = Example_1Name + "/" + ExampleBlockName;
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
        % Data Store Write for Capacitors (Cope from Example_1/DSW)
            for i = 1:length(ModelStruct.NodeNameEffective)
                Name = "DSW-C-" + ModelStruct.NodeNameEffective(i);
                ExampleBlockName = "DSW";
                BlockPath = SimulinkName + "/" + Name;
                % BlockLib = "sps_lib/Utilities/Data Store Write";
                BlockLib = Example_1Name + "/" + ExampleBlockName;
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
                DataStoreWritePosition = CPosition + [-100,0];
                OriginalSize = get_param(BlockPath,"Position");
                OriginalSize = [OriginalSize(3)-OriginalSize(1),OriginalSize(4)-OriginalSize(2)];
                BlockSize = OriginalSize;
                Rect = [DataStoreWritePosition,DataStoreWritePosition + BlockSize];
                set_param(BlockPath,"Position",Rect);
                % rotate the block to the left
                set_param(BlockPath,"Orientation","left");
            end

        % Data Store Read (Cope from Example_1/DSR)
            Name = "DSR";
            ExampleBlockName = "DSR";
            BlockPath = SimulinkName + "/" + Name;
            BlockLib = Example_1Name + "/" + ExampleBlockName;
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


        % Scope connected to Data Store Read (Copy from Example_1/Scope)
            Name = "ScopeDSR";
            ExampleBlockName = "Scope";
            BlockPath = SimulinkName + "/" + Name;
            BlockLib = Example_1Name + "/" + ExampleBlockName;
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


        % Resistors
            for i = 1:size(ModelStruct.GrName,1)
                Name = "R-(" + ModelStruct.GrName(i,1) + "," + ModelStruct.GrName(i,2) + ")";
                BlockPath = SimulinkName + "/" + Name;
                BlockLib = "sps_lib/Passives/Series RLC Branch";
                try
                    add_block(BlockLib, BlockPath);
                catch
                    
                end
                % set the block parameters
                set_param(BlockPath,"BranchType","R");
                set_param(BlockPath,"Resistance","1/ModelStruct.Gr(" + i + ")");
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
                BlockLib = "sps_lib/Sources/Controlled Current Source";
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
                BlockLib = "sps_lib/Utilities/Ground";
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
            end
        % CVS,Grounds for CVS,CVS Inputs
            for i = 1:length(ModelStruct.NodeName)
                [~,Layer] = GetNodePosAndLay(ModelStruct.NodeName(i));
                if Layer ~= ModelStruct.LayerNum
                    continue;
                end
                Name = "CVS-" + ModelStruct.NodeName(i);
                BlockPath = SimulinkName + "/" + Name;
                BlockLib = "sps_lib/Sources/Controlled Voltage Source";
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
                BlockLib = "sps_lib/Utilities/Ground";
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
                catch 
                end
            end
        % Connect capacitor and Voltage measuremens
            for i = 1:length(ModelStruct.NodeNameEffective)
                CName = "C-" + ModelStruct.NodeNameEffective(i);
                VName = "VolMea-C-" + ModelStruct.NodeNameEffective(i);
                try
                    add_line(SimulinkName,CName + "/LConn1",VName + "/LConn1");
                    add_line(SimulinkName,CName + "/RConn1",VName + "/LConn2");
                catch 
                end
            end
        % Connect Voltage measuremens and Data Store Write
            for i = 1:length(ModelStruct.NodeNameEffective)
                VName = "VolMea-C-" + ModelStruct.NodeNameEffective(i);
                DSName = "DSW-C-" + ModelStruct.NodeNameEffective(i);
                try
                    add_line(SimulinkName,VName + "/1",DSName + "/1");
                catch 
                end
            end
        % Connect Data Store Read and Scope
            DSName = "DSR";
            ScopeName = "ScopeDSR";
            try
                add_line(SimulinkName,DSName + "/1",ScopeName + "/1");
            catch 
            end

        % Connect current source and ground
            for i = 1:length(ModelStruct.NodeName)
                CCSName = "CCS-" + ModelStruct.NodeName(i);
                GName = "Ground-CCS-" + ModelStruct.NodeName(i);
                if ismember(SimulinkName + "/" + CCSName,AllBlocks)
                    try
                        add_line(SimulinkName,CCSName + "/LConn1",GName + "/LConn1");
                    catch 
                    end
                end
            end
        % Connecting Current Sources and Current Source Inputs
            for i = 1:length(ModelStruct.NodeName)
                CCSName = "CCS-" + ModelStruct.NodeName(i);
                CCSInputName = "CCSInput-" + ModelStruct.NodeName(i);
                if ismember(SimulinkName + "/" + CCSName,AllBlocks)
                    try
                        add_line(SimulinkName,CCSInputName + "/1",CCSName + "/1");
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
                        add_line(SimulinkName,CVSName + "/LConn1",GName + "/LConn1");
                    catch 
                    end
                end
            end
        % Connecting Voltage Sources and Voltage Source Inputs
            for i = 1:length(ModelStruct.NodeName)
                CVSName = "CVS-" + ModelStruct.NodeName(i);
                CVSInputName = "CVSInput-" + ModelStruct.NodeName(i);
                if ismember(SimulinkName + "/" + CVSName,AllBlocks)
                    try
                        add_line(SimulinkName,CVSInputName + "/1",CVSName + "/1");
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
                        add_line(SimulinkName,CCSName + "/RConn1",CName + "/LConn1");
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
                        add_line(SimulinkName,CVSName1 + "/RConn1",RName + "/RConn1");
                    catch 
                    end
                elseif ismember(SimulinkName + "/" + CVSName2,AllBlocks)
                    try
                        add_line(SimulinkName,CVSName2 + "/RConn1",RName + "/RConn1");
                    catch 
                    end
                end
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
        ModelStruct.Result.CircuitData.Out = Out;
        close_system(Example_1Name,0);
        close_system(SimulinkName,0);
    % back to the original folder
        cd(CurrentDir);
    catch ME
        close_system(Example_1Name,0);
        close_system(SimulinkName,0);
        cd(CurrentDir);
        ErrorMessage = CatchProcess(ME);
        error(ErrorMessage);
    end
end