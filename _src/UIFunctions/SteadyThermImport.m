function SteadyThermImport(app,event)
% wait for the user to select multiple files
    f = figure( 'Renderer' , 'painters' , 'Position' , [-100 -100 0 0]);
    if isfield(app.UsersData,'LastDir')
        LastDir = app.UsersData.LastDir;
    else
        LastDir = pwd;
    end
    [filename, PathName] = uigetfile({'*.csv'},'Select the Steady ThermSim data file(s)',LastDir,'MultiSelect','on');
    delete(f);
    if isequal(filename,0) || isequal(PathName,0)
        return
    end
    % check if the filename is cell array or not
    if ischar(filename)
        filename = {filename};
    end
    filename = filename(:);
    NewData = cell(size(filename,1),1);
    for i = 1:size(filename,1)
        tempPath = fullfile(PathName,filename{i});
        NewData{i} = tempPath;
    end
    PreData = app.SteadyThermTable.Data;
    % check if PreData already has the same file
    if isempty(PreData)
        Data = NewData;
    else
        Data = unique([PreData;NewData]);
    end
    app.UsersData.LastDir = PathName;
    app.SteadyThermTable.Data = Data;
end