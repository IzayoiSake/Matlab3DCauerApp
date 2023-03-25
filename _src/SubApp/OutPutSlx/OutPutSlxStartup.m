function OutPutSlxStartup(app,CallerApp)
    % TransTemptTextArea
    try
        TransTemptPath = CallerApp.ModelStruct.Result.TransTemptPath;
    catch
        TransTemptPath = '';
    end
    app.TransTemptTextArea.Value = TransTemptPath;
    % TransPowerTextArea
    try
        TransPowerPath = CallerApp.ModelStruct.Result.TransPowerPath;
    catch
        TransPowerPath = '';
    end
    app.TransPowerTextArea.Value = TransPowerPath;
end