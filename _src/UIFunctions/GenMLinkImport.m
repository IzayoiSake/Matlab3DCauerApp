function GenMTherImport(app,event)
    % wait for the user to select one file
    f = figure( 'Renderer' , 'painters' , 'Position' , [-100 -100 0 0]);
    if isfield(app.UsersData,'LastDir')
        LastDir = app.UsersData.LastDir;
    else
        LastDir = pwd;
    end
    [FileName,PathName] = uigetfile('*.xlsx','Select the TherSim file',LastDir,'MultiSelect','off');
    delete(f);
    % Back to the foreground of this program
    figure(app.UIFigure);
    % if the user pressed cancel, return an empty string
    if isequal(FileName,0) || isequal(PathName,0)
        return
    end
    if ischar(FileName)
        FileName = {FileName};
    end
    FileName = FileName(:);
    Data = cell(size(FileName,1),1);
    for i = 1:size(FileName,1)
        Data{i} = fullfile(PathName,FileName{i});
    end
    app.UsersData.LastDir = PathName;
    app.GenMLinkTable.Data = Data;
end