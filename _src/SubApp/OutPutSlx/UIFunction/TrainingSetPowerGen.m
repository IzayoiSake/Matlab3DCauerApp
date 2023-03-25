function TrainingSetPowerGen(app)
    
    ErrorMessage = '';
% 1: Get Transient Thermal files from SteadyThermTable and check 
    try
        if isfield(app.UsersData,'LastDir')
            LastDir = app.UsersData.LastDir;
        else
            LastDir = pwd;
        end
        ThermalFile = string(app.TransTemptTextArea.Value);
        ThermalFile = string(ThermalFile);
        if isempty(ThermalFile) || ThermalFile == ""
            ErrorMessage = ErrorMessage + "No ""TransTemptFile"" is Selected";
            uialert(app.UIFigure,ErrorMessage,'Error','Icon','error');
            return
        end
        ThermalFile = ThermalFile(~cellfun('isempty',ThermalFile));
        % create a notice but hide the progress bar
        Notice = uiprogressdlg(app.UIFigure,"Message","处理较慢,请耐心等待.","Title","Notice","Icon","info","Indeterminate","on");
        drawnow;
    catch ME
        ErrorMessage = ErrorMessage + CatchProcess(ME);
        uialert(app.UIFigure,ErrorMessage,'Error','Icon','error');
        return
    end
% 2: Read the Thermal Files and check
    try
        [FileData,Type] = ReadFile(ThermalFile);
        if ~strcmp(Type,"TTS")
            ErrorMessage = ErrorMessage + "Wrong File Type : ""TransTemptFile""";
            uialert(app.UIFigure,ErrorMessage,'Error','Icon','error');
            return
        end
    catch ME
        ErrorMessage = ErrorMessage + CatchProcess(ME);
        uialert(app.UIFigure,ErrorMessage,'Error','Icon','error');
        return
    end
% 3: Get the Time and NodeName from the Thermal Files
    try
        Time = FileData(2:end,1);
        NodeName = FileData(1,2:end);
        NodeName = SortNodeName(NodeName,"Layer");
    catch ME
        ErrorMessage = ErrorMessage + CatchProcess(ME);
        uialert(app.UIFigure,ErrorMessage,'Error','error');
        return
    end
% 4: Create and write the Transient Power File
    try
        Data = zeros(length(Time)+1,length(NodeName)+1);
        Data = string(Data);
        Data(1,1) = "Time";
        for i = 1:length(NodeName)
            Data(1,i+1) = NodeName(i);
        end
        for i = 1:length(Time)
            Data(i+1,1) = Time(i);
        end
        DataTemp = Data;
        Data = cell(length(Time)+1,length(NodeName)+1);
        for i = 1:numel(DataTemp)
            Data{i} = DataTemp(i);
        end
    catch ME
        ErrorMessage = ErrorMessage + CatchProcess(ME);
        uialert(app.UIFigure,ErrorMessage,'Error','Icon','error');
        return
    end
    try
        close(Notice);
        [Dir,TSName,~] = fileparts(ThermalFile);
        InitalName = TSName + "_P.xlsx";
        InitialPath = fullfile(Dir,InitalName);
        f = figure( 'Renderer' , 'painters' , 'Position' , [-100 -100 0 0]);
        [FileName,PathName] = uiputfile('*.xlsx','Save as',InitialPath);
        close(f);
        if isequal(FileName,0) || isequal(PathName,0)
            return
        end
        FileName = fullfile(PathName,FileName);
        FileName = string(FileName);
        writecell(Data,FileName);
        app.TransPowerTextArea.Value = FileName;
    catch ME
        ErrorMessage = ErrorMessage + CatchProcess(ME);
        uialert(app.UIFigure,ErrorMessage,'Error','Icon','error');
        return
    end
    % Open the File by excel
    try
        winopen(FileName);
    catch ME
        ErrorMessage = ErrorMessage + CatchProcess(ME);
        uialert(app.UIFigure,ErrorMessage,'Error','Icon','error');
        return
    end
end