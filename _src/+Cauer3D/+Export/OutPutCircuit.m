function OutPutCircuit(app,CallerApp)
    import Cauer3D.Model.*
    import Cauer3D.UI.*
    import Cauer3D.Nomenclature.*
    import Cauer3D.Plot.*
    import Cauer3D.Export.*
    import Cauer3D.IO.*
    import Cauer3D.Internal.*
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
    try
        CallerApp.ModelStruct = PrepareTransientTestData(CallerApp.ModelStruct, ...
            CallerApp.ModelStruct.Result.TransTemptPath, ...
            CallerApp.ModelStruct.Result.TransPowerPath);
    catch ME
        uialert(app.UIFigure, CatchProcess(ME), "Test Data Error", "Icon", "error");
        return;
    end
    if ~exist(PathName, 'dir')
        mkdir(PathName);
    end
    % open a progress bar
    f = uiprogressdlg(app.UIFigure, 'Title' , 'Please wait...' , 'Message' , 'Generating circuit...' , ...
    'Cancelable' , 'off' , "Icon" , "info" , "Indeterminate" , "on");
    try
        CallerApp.ModelStruct = ResultToPowergui(CallerApp.ModelStruct);
    catch ME
        ErrorMessage = CatchProcess(ME);
        uialert(app.UIFigure, ErrorMessage, "Error", "Icon", "error");
    end
    close(f);
end
