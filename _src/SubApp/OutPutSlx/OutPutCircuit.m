function OutPutCircuit(app,CallerApp)
    try
        ModelStruct = CallerApp.ModelStruct;
        if ModelStruct.Temp.State ~= "End"
            error("");
        end
    catch
        uialert(app.UIFigure, "Please run the simulation first!", "Error", "Icon", "error");
        return;
    end
    try
        DefaultPath = CallerApp.UsersData.LastDir;
    catch
        DefaultPath = pwd;
    end
    % wait for user to select a file
    f = figure( 'Renderer' , 'painters' , 'Position' , [-100 -100 0 0]);
    [FileName, PathName] = uiputfile("*.slx", 'Save As', fullfile(DefaultPath, "Circuit.slx"));
    close(f);
    if isequal(FileName, 0) || isequal(PathName, 0)
        return;
    end
    SlxPath = fullfile(PathName, FileName);
    CallerApp.ModelStruct.Result.CircuitResultPath = SlxPath;
    CallerApp.ModelStruct.Result.TransTemptPath = string(app.TransTemptTextArea.Value);
    CallerApp.ModelStruct.Result.TransPowerPath = string(app.TransPowerTextArea.Value);
    if ~exist(PathName, 'dir')
        mkdir(PathName);
    end
    % open a progress bar
    f = uiprogressdlg(app.UIFigure, 'Title' , 'Please wait...' , 'Message' , 'Generating circuit...' , ...
    'Cancelable' , 'off' , "Icon" , "info" , "Indeterminate" , "on");
    CurrentDir = pwd;
    try
        CallerApp.ModelStruct = ResultToPowergui(CallerApp.ModelStruct);
    catch ME
        ErrorMessage = CatchProcess(ME);
        cd(CurrentDir);
        uialert(app.UIFigure, ErrorMessage, "Error", "Icon", "error");
    end
    cd(CurrentDir);
    close(f);
end