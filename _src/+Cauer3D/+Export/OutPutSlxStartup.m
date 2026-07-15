function OutPutSlxStartup(app,CallerApp)
    import Cauer3D.Model.*
    import Cauer3D.UI.*
    import Cauer3D.Nomenclature.*
    import Cauer3D.Plot.*
    import Cauer3D.Export.*
    import Cauer3D.IO.*
    import Cauer3D.Internal.*
    app.CallerApp = CallerApp;
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

    app.Circuit.ButtonPushedFcn = @(~,~) Cauer3D.Export.OutPutCircuit(app, CallerApp);
    app.StateSpace.ButtonPushedFcn = @(~,~) Cauer3D.Export.OutPutStateSpace(app);
    app.Button.ButtonPushedFcn = @(~,~) Cauer3D.Export.OutPutTTFImport(app, CallerApp);
    app.Button_2.ButtonPushedFcn = @(~,~) Cauer3D.Export.OutPutTTFClear(app, CallerApp);
    app.Button_3.ButtonPushedFcn = @(~,~) Cauer3D.Export.OutPutTPFImport(app, CallerApp);
    app.Button_4.ButtonPushedFcn = @(~,~) Cauer3D.Export.OutPutTPFClear(app, CallerApp);
    app.Button_5.ButtonPushedFcn = @(~,~) Cauer3D.Export.TrainingSetPowerGen(app);
end
