function IfSave = SaveMenu(app,event)
% check if app has a SavePath
    try
        SaveDir = app.UsersData.LastDir;
    catch
        SaveDir = pwd;
    end
    if ~isfield(app.UsersData, 'SavePath' )
        % if not, ask user to select a filename to save app data
        f = figure( 'Renderer' , 'painters' , 'Position' , [-100 -100 0 0]);
        [filename,pathname] = uiputfile( '*.Appmat' , 'Save as' , SaveDir + "\" + "AppData.Appmat");
        close(f)
        if isequal(filename,0) || isequal(pathname,0)
            IfSave = 0;
            return
        end
        SavePath = fullfile(pathname,filename);
        app.UsersData.SavePath = SavePath;
        AppData = GetUIData(app,event);
        save(SavePath, 'AppData' );
    else
        % save app data
        AppData = GetUIData(app,event);
        save(app.UsersData.SavePath, 'AppData' );
    end
    [app.UsersData.LastDir,~,~] = fileparts(app.UsersData.SavePath);
    IfSave = 1;
end


function AppData = GetUIData(app,event)
% get data from UI
    % find all tables
    Tables = findobj(app.UIFigure, 'Type' , 'uitable' );
    % find all numeric edit fields
    NumEditFields = findobj(app.UIFigure, 'Type' , 'uinumericeditfield' );
    % find all TextAreas
    TextAreas = findobj(app.UIFigure, 'Type' , 'uitextarea' );
    % find all dropdowns
    Dropdowns = findobj(app.UIFigure, 'Type' , 'uidropdown' );
    

    % get the Data above
    for i = 1:length(Tables)
        UIData.(Tables(i).Tag) = Tables(i).Data;
    end
    for i = 1:length(NumEditFields)
        UIData.(NumEditFields(i).Tag) = NumEditFields(i).Value;
    end
    for i = 1:length(TextAreas)
        UIData.(TextAreas(i).Tag) = TextAreas(i).Value;
    end
    for i = 1:length(Dropdowns)
        UIData.(Dropdowns(i).Tag) = Dropdowns(i).Value;
    end
    AppData.UIData = UIData;


% get data from UsersData
    AppData.UsersData = app.UsersData;
    AppData.ModelStruct = app.ModelStruct;
    
end