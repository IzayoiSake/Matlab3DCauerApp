function ModelStructSettingsGetFromUI(app,event,Type)
% Get the settings from the UI and store them in the app struct
% This function is called when the user clicks the "StartStopButton" and etc.
% NodeNamePath LinkPath Nomenclature SteadyPowerPath SteadyTemptPath TransPowerPath TransTemptPath ParPoolNum StepSize slxDir
    if ~exist('Type','var')
        Type = 'All';
    end
    if isprop(app,'ModelStruct') && strcmp(Type,'All')
        Data = app.GenMLinkTable.Data;
        Data = string(Data);
        app.ModelStruct.Settings.LinkPath = Data;
        
        Data = app.GenMTherTable.Data;
        Data = string(Data);
        app.ModelStruct.Settings.NodeNamePath = Data;

        Data = app.NomenclatureDropDown.Value;
        app.ModelStruct.Settings.Nomenclature = Data;

        Data = app.SteadyPowerTable.Data;
        Data = string(Data);
        app.ModelStruct.Settings.SteadyPowerPath = Data;

        Data = app.SteadyThermTable.Data;
        Data = string(Data);
        app.ModelStruct.Settings.SteadyTemptPath = Data;

        Data = app.TransientPowerTable.Data;
        Data = string(Data);
        app.ModelStruct.Settings.TransPowerPath = Data;

        Data = app.TransientThermTable.Data;
        Data = string(Data);
        app.ModelStruct.Settings.TransTemptPath = Data;

        Data = app.ParPoolEditField.Value;
        app.ModelStruct.Settings.ParPoolNum = double(Data);

        Data = app.StepSizeEditField.Value;
        app.ModelStruct.Settings.StepSize = double(Data);

        Data = app.slxDirFolderTextArea.Value;
        Data = string(Data);
        app.ModelStruct.Settings.slxDir = Data;
    end
end
