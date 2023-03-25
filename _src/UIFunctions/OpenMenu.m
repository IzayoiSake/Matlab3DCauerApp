function OpenMenu(app,event)
% wait users to select a AppData file
    f = figure( 'Renderer' , 'painters' , 'Position' , [-100 -100 0 0]);
    [filename,pathname] = uigetfile('*.Appmat','Select an AppData file');
    close(f);
    if isequal(filename,0) || isequal(pathname,0)
        return
    end
    % load the AppData file
    SavePath = fullfile(pathname,filename);
    AppData = load(SavePath,'-mat');
    % transfer the data to the current app
    PutUIData(app,event,AppData.AppData);
    app.UsersData.SavePath = SavePath;
    [app.UsersData.LastDir,~,~] = fileparts(app.UsersData.SavePath);
end




function PutUIData(app,event,AppData)
% Put UsersData
    if isfield(AppData,'UsersData')
        app.UsersData = AppData.UsersData;
    end
    if isfield(AppData,'ModelStruct')
        app.ModelStruct = AppData.ModelStruct;
    end
% Put UI Data
    % find all the tables
    Tables = findobj(app.UIFigure,'Type','uitable');
    % find all the numeric edit fields
    NumEditFields = findobj(app.UIFigure, 'Type' , 'uinumericeditfield' );
    % find all TextAreas
    TextAreas = findobj(app.UIFigure, 'Type' , 'uitextarea' );
    % find all dropdowns
    Dropdowns = findobj(app.UIFigure, 'Type' , 'uidropdown' );

    % Put the Data above to the UI
    for i = 1:length(Tables)
        Table = Tables(i);
        if isfield(AppData.UIData,Table.Tag)
            Table.Data = AppData.UIData.(Table.Tag);
        end
    end
    for i = 1:length(NumEditFields)
        NumEditField = NumEditFields(i);
        if isfield(AppData.UIData,NumEditField.Tag)
            NumEditField.Value = AppData.UIData.(NumEditField.Tag);
        end
    end
    for i = 1:length(TextAreas)
        TextArea = TextAreas(i);
        if isfield(AppData.UIData,TextArea.Tag)
            TextArea.Value = AppData.UIData.(TextArea.Tag);
        end
    end
    for i = 1:length(Dropdowns)
        Dropdown = Dropdowns(i);
        if isfield(AppData.UIData,Dropdown.Tag)
            Dropdown.Value = AppData.UIData.(Dropdown.Tag);
        end
    end
end
    

