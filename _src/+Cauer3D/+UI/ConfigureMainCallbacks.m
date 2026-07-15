function ConfigureMainCallbacks(app)
% ConfigureMainCallbacks Bind App Designer controls to package functions.

    app.UIFigure.CloseRequestFcn = @(~, event) Cauer3D.UI.CloseMainApp(app, event);

    app.SaveMenu.MenuSelectedFcn = @(~, event) Cauer3D.UI.SaveMenu(app, event);
    app.OpenMenu.MenuSelectedFcn = @(~, event) Cauer3D.UI.OpenMenu(app, event);
    app.NewMenu.MenuSelectedFcn = @(~, event) Cauer3D.UI.NewMenu(app, event);

    app.GenMTherImport.ButtonPushedFcn = @(~, event) Cauer3D.UI.GenMTherImport(app, event);
    app.GenMTherClear.ButtonPushedFcn = @(~, event) Cauer3D.UI.GenMTherClear(app, event);
    app.GenMTherTable.CellEditCallback = @(~, event) Cauer3D.UI.GenMTherTable(app, event);

    app.GenMLinkImport.ButtonPushedFcn = @(~, event) Cauer3D.UI.GenMLinkImport(app, event);
    app.GenMLinkClear.ButtonPushedFcn = @(~, event) Cauer3D.UI.GenMLinkClear(app, event);
    app.GenMLinkTable.CellEditCallback = @(~, event) Cauer3D.UI.GenMLinkTable(app, event);
    app.LinkGen.ButtonPushedFcn = @(~, event) Cauer3D.UI.LinkGen(app, event);

    app.NomenclatureDropDown.DropDownOpeningFcn = ...
        @(~, event) Cauer3D.UI.NomenclatureDropDown(app, event);
    app.NomenclatureDropDown.ValueChangedFcn = ...
        @(~, event) Cauer3D.UI.NomenclatureDropDown(app, event);

    app.SteadyThermImport.ButtonPushedFcn = @(~, event) Cauer3D.UI.SteadyThermImport(app, event);
    app.SteadyThermClear.ButtonPushedFcn = @(~, event) Cauer3D.UI.SteadyThermClear(app, event);
    app.SteadyThermTable.CellEditCallback = @(~, event) Cauer3D.UI.SteadyThermTable(app, event);

    app.TransientThermImport.ButtonPushedFcn = ...
        @(~, event) Cauer3D.UI.TransientThermImport(app, event);
    app.TransientThermClear.ButtonPushedFcn = ...
        @(~, event) Cauer3D.UI.TransientThermClear(app, event);
    app.TransientThermTable.CellEditCallback = ...
        @(~, event) Cauer3D.UI.TransientThermTable(app, event);

    app.SteadyPowerImport.ButtonPushedFcn = @(~, event) Cauer3D.UI.SteadyPowerImport(app, event);
    app.SteadyPowerClear.ButtonPushedFcn = @(~, event) Cauer3D.UI.SteadyPowerClear(app, event);
    app.SteadyPowerGen.ButtonPushedFcn = @(~, event) Cauer3D.UI.SteadyPowerGen(app, event);
    app.SteadyPowerTable.CellEditCallback = @(~, event) Cauer3D.UI.SteadyPowerTable(app, event);

    app.TransientPowerImport.ButtonPushedFcn = ...
        @(~, event) Cauer3D.UI.TransientPowerImport(app, event);
    app.TransientPowerClear.ButtonPushedFcn = ...
        @(~, event) Cauer3D.UI.TransientPowerClear(app, event);
    app.TransientPowerGen.ButtonPushedFcn = ...
        @(~, event) Cauer3D.UI.TransientPowerGen(app, event);
    app.TransientPowerTable.CellEditCallback = ...
        @(~, event) Cauer3D.UI.TransientPowerTable(app, event);

    app.StartStopButton.ValueChangedFcn = @(~, event) Cauer3D.UI.StartStopButton(app, event);
    app.ViewModelStructButton.ButtonPushedFcn = ...
        @(~, event) Cauer3D.UI.ViewModelStruct(app, event);
    app.slxDirFolderSelect.ButtonPushedFcn = ...
        @(~, event) Cauer3D.UI.slxDirFolderSelect(app, event);
    app.slxDirFolderClear.ButtonPushedFcn = ...
        @(~, event) Cauer3D.UI.slxDirFolderClear(app, event);

    Cauer3D.UI.ConfigureResultActions(app);
end
