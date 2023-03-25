function Cr = SimulinkOperation(Exp_T,R,P,Ptime,T,Ttime,slxFilePath,StepSize)
% SimulinkOperation - Operate Simulink

% 1: check the inputs
    try
        Exp_T = Exp_T(:);
        R = R(:);
        Ptime = Ptime(:);
        Ttime = Ttime(:);
        if ~isa(R,'double')
            R = double(R);
        end
        if ~isa(P,'double')
            P = double(P);
        end
        if ~isa(Ptime,'double')
            Ptime = double(Ptime);
        end
        if ~isa(T,'double')
            T = double(T);
        end
        if ~isa(Ttime,'double')
            Ttime = double(Ttime);
        end
    catch ME
        ErrorMessage = "Inputs are illegal." + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
% 2: check if the file exists
    try
        [Dir,FileName,~]=fileparts(slxFilePath);
        
        if ~bdIsLoaded(FileName)
            new_system(FileName);
        end
        if ~strcmp(Dir,"")
            save_system(FileName,slxFilePath);
        end
    catch ME
        ErrorMessage = "Unkown path error" + newline;
        ErrorMessage = ErrorMessage + CatchProcess(ME,1);
        error(ErrorMessage);
    end
% Add variables to the model workspace
    % get the handle of the model workspace
    hws= get_param(FileName,'ModelWorkspace');
    % add variables to the model workspace
    hws.assignin('Exp_T',Exp_T);
    hws.assignin('R',R);
    hws.assignin('P',P);
    hws.assignin('Ptime',Ptime);
    hws.assignin('T',T);
    hws.assignin('Ttime',Ttime);
    hws.assignin('StepSize',StepSize);
% predefined C
    C=1;
    hws.assignin('C',C);
% set the simulation settings
    % Set the solution type of the model to fixed step size
    % set_param(FileName,'SolverType','Fixed-step');
    set_param(FileName,'SolverType','Variable-step');
    % Set the model's solver to automatic
    set_param(FileName,'SolverMode','Auto');
    % Set the simulation time for the model
    set_param(FileName,'StopTime',string(min(Ttime(end),Ptime(end))));
    % Set the step size for the model
    % set_param(FileName,'FixedStep',"StepSize");

% add and set the blocks
% get all the blocks needed
    NeedBlocks = [];
% powergui
    % add the powergui block
    Name = "powergui";
    PathName = FileName + "/" + Name;
    try
        add_block("spspowerguiLib/powergui", PathName);
    catch

    end
    % set the SimulationMode
    if strcmp(get_param(PathName,"SimulationMode"),"Continuous")
    else
        set_param(PathName,"SimulationMode","Continuous");
    end
    % set the SampleTime
    try
        if strcmp(get_param(PathName,"SampleTime"),"StepSize")
        else
            set_param(PathName,"SampleTime","StepSize");
        end
    catch
    end
    % set the position
    if ~exist('Position','var')
        Position = [0,0,100,100];
    else
        Position = Position + [200,0,200,0];
    end
    set_param(PathName,"Position",Position);
    NeedBlocks = [NeedBlocks;PathName];
% Controlled Current Source
    % add the Controlled Current Source block
    Name = "CCS";
    PathName = FileName + "/"+Name;
    try
        add_block("sps_lib/Sources/Controlled Current Source", PathName);
    catch

    end
    set_param(PathName,"Initialize","off");
    % set the position
    if ~exist('Position','var')
        Position = [0,0,100,100];
    else
        Position = Position + [200,0,200,0];
    end
    set_param(PathName,"Position",Position);
    NeedBlocks = [NeedBlocks;PathName];
% CCS From Workspace
    Name = "CCS From Workspace";
    PathName = FileName + "/" + Name;
    try
        add_block("simulink/Sources/From Workspace", PathName);
    catch

    end
    % set the Data
    set_param(PathName,"VariableName","[Ptime,P]");
    % set the position
    if ~exist('Position','var')
        Position = [0,0,100,100];
    else
        PositionW = Position + [-100, + 100,-100, + 100];
    end
    set_param(PathName,"Position",PositionW);
    NeedBlocks = [NeedBlocks;PathName];
% Ground for CCS
    Name = "Ground for CCS";
    PathName = FileName + "/" + Name;
    try
        add_block("sps_lib/Utilities/Ground", PathName);
    catch

    end
    % set the position
    if ~exist('Position','var')
        Position = [0,0,100,100];
    else
        PositionG = Position + [0,200,0,200];
    end
    set_param(PathName,"Position",PositionG);
    NeedBlocks = [NeedBlocks;PathName];
% Capacitor
    Name = "C";
    PathName = FileName + "/" + Name;
    try
        add_block("sps_lib/Passives/Series RLC Branch", PathName);
    catch

    end
    % set the BranchType
    BranchType = get_param(PathName,"BranchType");
    if ~strcmp(BranchType,"C")
        set_param(PathName,"BranchType","C");
    end
    % set the C
    set_param(PathName,"Capacitance","C");
    % set the initial voltage of the capacitor
    set_param(PathName,"Setx0","on");
    set_param(PathName,"InitialVoltage","Exp_T(1)");
    % set the position
    if ~exist('Position','var')
        Position = [0,0,100,100];
    else
        Position = Position + [200,0,200,0];
    end
    set_param(PathName,"Position",Position);
    % Set the positive terminal of the capacitor facing up
    set_param(PathName,"Orientation","down");
    NeedBlocks = [NeedBlocks;PathName];
% Resistors
    RNum = length(R);
    Position = Position + [200,0,200,0];
    for i = 1:RNum
        Name = "R" + string(i);
        PathName = FileName + "/" + Name;
        try
            add_block("sps_lib/Passives/Series RLC Branch", PathName);
        catch

        end
        % set the BranchType
        BranchType = get_param(PathName,"BranchType");
        if ~strcmp(BranchType,"R")
            set_param(PathName,"BranchType","R");
        end
        % set the R
        set_param(PathName,"Resistance","R(" + string(i) + ")");
        % set the position
        if ~exist('Position','var')
            Position = [0,0,100,100];
        end
        set_param(PathName,"Position",Position);
        % Set the positive terminal of the resistor facing left
        set_param(PathName,"Orientation","right");
        NeedBlocks = [NeedBlocks;PathName];
    end
% Controlled Voltage Source
    Position = Position + [200,0,200,0];
    for i = 1:RNum
        Name = "CVS" + string(i);
        PathName = FileName + "/" + Name;
        try
            add_block("sps_lib/Sources/Controlled Voltage Source", PathName);
        catch

        end
        set_param(PathName,"Initialize","off");
        % set the position
        if ~exist('Position','var')
            Position = [0,0,100,100];
        end
        set_param(PathName,"Position",Position);
        NeedBlocks = [NeedBlocks;PathName];
    end
% CVS From Workspace
    for i = 1:RNum
        Name = "CVS From Workspace" + string(i);
        PathName = FileName + "/" + Name;
        try
            add_block("simulink/Sources/From Workspace", PathName);
        catch

        end
        % set the Data
        set_param(PathName,"VariableName","[Ttime,T(:," + string(i) + ")]");
        % set the position
        if ~exist('Position','var')
            Position = [0,0,100,100];
        else
            PositionW = Position + [-100,100,-100,100];
        end
        set_param(PathName,"Position",PositionW);
        NeedBlocks = [NeedBlocks;PathName];
    end
% Ground for CVS
    Name = "Ground for CVS";
    PathName = FileName + "/" + Name;
    try
        add_block("sps_lib/Utilities/Ground", PathName);
    catch

    end
    % set the position
    if ~exist('Position','var')
        Position = [0,0,100,100];
    else
        PositionG = Position + [0,200,0,200];
    end
    set_param(PathName,"Position",PositionG);
    % Set the direction of the ground facing up
    set_param(PathName,"Orientation","down");
    NeedBlocks = [NeedBlocks;PathName];
% Voltage Measurement
    Name = "Voltage Measurement";
    PathName = FileName + "/" + Name;
    try
        add_block("sps_lib/Sensors and Measurements/Voltage Measurement", PathName);
    catch

    end
    % set the position
    PositionW = get_param(FileName + "/" + "C","Position");
    PositionW = PositionW + [200,-300,200,-300];
    set_param(PathName,"Position",PositionW);
    NeedBlocks = [NeedBlocks;PathName];
% Ground for Voltage Measurement
    Name = "Ground for Voltage Measurement";
    PathName = FileName + "/" + Name;
    try
        add_block("sps_lib/Utilities/Ground", PathName);
    catch

    end
    % set the position
    PositionG = get_param(FileName + "/" + "Voltage Measurement","Position");
    PositionG = PositionG + [-100,100,-100,100];
    set_param(PathName,"Position",PositionG);
    % Set the direction of the ground facing up
    set_param(PathName,"Orientation","down");
    NeedBlocks = [NeedBlocks;PathName];
% Output
    Name = "Output";
    PathName = FileName + "/" + Name;
    try
        add_block("simulink/Sinks/Out1", PathName);
    catch

    end
    % set the position
    PositionW = get_param(FileName + "/" + "Voltage Measurement","Position");
    PositionW = PositionW + [200,0,200,0];
    set_param(PathName,"Position",PositionW);
    NeedBlocks = [NeedBlocks;PathName];
% delete the unused blocks
    AllBlocks = find_system(FileName);
    AllBlocks = AllBlocks(2:end);
    DeleteBlocks = AllBlocks(~ismember(AllBlocks,NeedBlocks));
    delete_block(DeleteBlocks);

% set the connection
    % initial connection
    allLines = find_system(FileName,"FindAll","on","type","line");
    delete_line(allLines);
    % "CCS From Workspace/1","CCS/1"
    add_line(FileName,"CCS From Workspace/1","CCS/1");
    % "CCS/LConn1","Ground/LConn1"
    add_line(FileName,"CCS/LConn1","Ground for CCS/LConn1");
    % "CCS/RConn1","C/LConn1"
    add_line(FileName,"CCS/RConn1","C/LConn1");
    % "C/RConn1","Ground/LConn1"
    add_line(FileName,"C/RConn1","Ground for CCS/LConn1");
    % "C/LConn1","R/LConn1"
    try
        for i = 1:RNum
            add_line(FileName,"C/LConn1","R" + string(i) + "/LConn1");
        end
    catch
    end
    % "R/RConn1","CVS/RConn1"
    for i = 1:RNum
        add_line(FileName,"R" + string(i) + "/RConn1","CVS" + string(i) + "/RConn1");
    end
    % "CVS" + string(i) + "/LConn1","Ground/LConn1"
    for i = 1:RNum
        add_line(FileName,"CVS" + string(i) + "/LConn1","Ground for CVS/LConn1");
    end
    % "CVS From Workspace/1","CVS/1"
    for i = 1:RNum
        add_line(FileName,"CVS From Workspace" + string(i) + "/1","CVS" + string(i) + "/1");
    end
    % "C/LConn1","Voltage Measurement/LConn1"
    add_line(FileName,"C/LConn1","Voltage Measurement/LConn1");
    % "Voltage Measurement/LConn2","Ground/LConn1"
    add_line(FileName,"Voltage Measurement/LConn2","Ground for Voltage Measurement/LConn1");
    % "Voltage Measurement/1","OutPut/1"
    add_line(FileName,"Voltage Measurement/1","Output/1");

% Begin the Pattern Search
    % 选择需要辨识的模型参数
    p = sdo.getParameterFromModel(FileName,'C');
    % 定义辨识的实验数据
        Exp = sdo.Experiment(FileName);
    % 定义仿真数据的测量端口
        Exp_Sig_Output = Simulink.SimulationData.Signal;
        Exp_Sig_Output.Values    = timeseries(Exp_T,Ttime);
        Exp_Sig_Output.BlockPath = FileName+"/Voltage Measurement";
        Exp_Sig_Output.PortType  = 'outport';
        Exp_Sig_Output.PortIndex = 1;
        Exp_Sig_Output.Name      = 'OutPut';
        Exp.OutputData = Exp_Sig_Output;
    % 给实验数据设置仿真器
        Simulator = createSimulator(Exp);
    % Use an anonymous function with one argument that calls Test_optFcn.
        optimfcn = @(P) Test_optFcn(P,Simulator,Exp,FileName);
    % Specify optimization options.
        Options = sdo.OptimizeOptions;
        Options.Method = 'patternsearch';
        Options.OptimizedModel = Simulator;
    % 辨识一次
        [pOpt,Info] = sdo.optimize(optimfcn,p,Options);
    % Update the experiments with the estimated parameter values.
        Exp = setEstimatedValues(Exp,pOpt);
    % Update the model with the optimized parameter values.
        sdo.setValueInModel(FileName,pOpt);
    % 提取辨识结果
        Cr=pOpt.Value;
% save
    if ~strcmp(Dir,"")
        save_system(FileName,[],"OverwriteIfChangedOnDisk",true);
    end
    close_system(FileName,0);
end

function Vals = Test_optFcn(P,Simulator,Exp,FileName)
    %TEST_OPTFCN
    %
    % Function called at each iteration of the estimation problem.
    %
    % The function is called with a set of parameter values, P, and returns
    % the estimation cost, Vals, to the optimization solver.
    %
    % See the sdoExampleCostFunction function and sdo.optimize for a more
    % detailed description of the function signature.
    %
    
    %
    % Define a signal tracking requirement to compute how well the model
    % output matches the experiment data.
    r = sdo.requirements.SignalTracking;
    %
    % Update the experiment(s) with the estimated parameter values.
    Exp = setEstimatedValues(Exp,P);
    
    %
    % Simulate the model and compare model outputs with measured experiment
    % data.
    
    F_r = 0;
    Simulator = createSimulator(Exp,Simulator);
    strOT = mat2str(Exp.OutputData(1).Values.Time);
    Simulator = sim(Simulator, 'OutputOption', 'AdditionalOutputTimes', 'OutputTimes', strOT);
    try
        drawnow;
    catch
    end
    
    SimLog = find(Simulator.LoggedData,get_param(FileName,'SignalLoggingName'));
    Sig = find(SimLog,Exp.OutputData.Name);
    
    Error = evalRequirement(r,Sig.Values,Exp.OutputData.Values);
    F_r = F_r + Error;
    
    % Return Values.
    %
    % Return the evaluated estimation cost in a structure to the
    % optimization solver.
    Vals.F = F_r;
end



