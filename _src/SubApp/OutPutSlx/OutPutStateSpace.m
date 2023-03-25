function OutPutStateSpace(app)
    try
        CallerApp = app.CallerApp;
        if CallerApp.ModelStruct.Temp.State ~= "End"
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
    [FileName, PathName] = uiputfile("*.slx", 'Save As', fullfile(DefaultPath, "CauerStateSpace.slx"));
    close(f);
    if isequal(FileName, 0) || isequal(PathName, 0)
        return;
    end
    SlxPath = fullfile(PathName, FileName);
    CallerApp.ModelStruct.Result.StateSpaceResultPath = SlxPath;
    CallerApp.ModelStruct.Result.TransTemptPath = string(app.TransTemptTextArea.Value);
    CallerApp.ModelStruct.Result.TransPowerPath = string(app.TransPowerTextArea.Value);
    if ~exist(PathName, 'dir')
        mkdir(PathName);
    end
    % open a progress bar
    f = uiprogressdlg(app.UIFigure, 'Title' , 'Please wait...' , 'Message' , 'Generating StateSpace...' , ...
    'Cancelable' , 'off' , "Icon" , "info" , "Indeterminate" , "on");
    CurrentDir = pwd;
    try
        CallerApp.ModelStruct = ResultToStateSpace(CallerApp.ModelStruct);
    catch ME
        ErrorMessage = CatchProcess(ME);
        cd(CurrentDir);
        uialert(app.UIFigure, ErrorMessage, "Error", "Icon", "error");
    end
    cd(CurrentDir);
    close(f);
end