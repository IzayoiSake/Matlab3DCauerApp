function SteadyPowerGen(app,event)

    ErrorMessage = '';
% 1: Get Steady Thermal files from SteadyThermTable and check 
    try
        if isfield(app.UsersData,'LastDir')
            LastDir = app.UsersData.LastDir;
        else
            LastDir = pwd;
        end
        ThermalFiles = app.SteadyThermTable.Data;
        ThermalFiles = string(ThermalFiles);
        if isequal(ThermalFiles,"")
            ErrorMessage = ErrorMessage + "No SteadyTemptFile(s) is(are) Selected";
            uialert(app.UIFigure,ErrorMessage,'Error','Icon','error');
            return
        end
        ThermalFiles = ThermalFiles(~cellfun('isempty',ThermalFiles));
        Notice = uiprogressdlg(app.UIFigure,"Message","处理较慢,请耐心等待.","Title","Notice","Icon","info","Indeterminate","on");
        drawnow;
    catch ME
        ErrorMessage = ErrorMessage + CatchProcess(ME);
        uialert(app.UIFigure,ErrorMessage,'Error','Icon','error');
        close(Notice);
        return
    end
% 2: Read the Thermal Files and check
    try
        [Data,Type] = ReadFile(ThermalFiles(1));
        if ~strcmp(Type,"STS")
            ErrorMessage = ErrorMessage + "Wrong File Type : ""SteadyTemptFile""";
            uialert(app.UIFigure,ErrorMessage,'Error','Icon','error');
            close(Notice);
            return
        end
        Header = Data(1,:);
        NodeName = SortNodeName(Header,"Layer");
        NodeName = NodeName(:);
    catch ME
        ErrorMessage = ErrorMessage + CatchProcess(ME);
        uialert(app.UIFigure,ErrorMessage,'Error','Icon','error');
        close(Notice);
        return
    end
% 3: Get the file name of ThermalFiles
    try
        FileNameList = zeros(length(ThermalFiles),1);
        FileNameList = string(FileNameList);
        FileNameList = strrep(FileNameList,"0","");
        for i = 1:length(ThermalFiles)
            [~,FileName,~] = fileparts(ThermalFiles(i));
            FileName = string(FileName);
            FileName = FileName(:);
            FileNameList(i) = FileName;
        end
        FileNameList = FileNameList(:)';
    catch ME
        ErrorMessage = ErrorMessage + CatchProcess(ME);
        uialert(app.UIFigure,ErrorMessage,'Error','Icon','error');
        close(Notice);
        return
    end
% 4: Write the Pr file
    try
        close(Notice);
        Data = zeros(length(NodeName)+1,length(ThermalFiles)+1);
        Data = string(Data);
        Data(1,1) = "NodeName";
        Data(1,2:end) = FileNameList;
        Data(2:end,1) = NodeName;
        DataTemp = Data;
        Data = cell(size(Data));
        for i = 1:numel(Data)
            Data{i} = DataTemp(i);
        end
        % wait users to choose a file name to save
        f = figure( 'Renderer' , 'painters' , 'Position' , [-100 -100 0 0]);
        [FileName,PathName] = uiputfile('*.xlsx','Save as',LastDir + "\" + "Pr.xlsx");
        close(f);
        if isequal(FileName,0) || isequal(PathName,0)
            return
        end
        FileName = string(FileName);
        PathName = string(PathName);
        FilePath = fullfile(PathName,FileName);
        % write the file
        writecell(Data,FilePath);
        app.SteadyPowerTable.Data = FilePath;
    catch ME
        ErrorMessage = ErrorMessage + CatchProcess(ME);
        uialert(app.UIFigure,ErrorMessage,'Error','Icon','error');
        return
    end
    % Open the file by Excel
    try
        winopen(FilePath);
    catch ME
        ErrorMessage = ErrorMessage + CatchProcess(ME);
        uialert(app.UIFigure,ErrorMessage,'Error','Icon','error');
        return
    end
    app.UsersData.LastDir = PathName;
end