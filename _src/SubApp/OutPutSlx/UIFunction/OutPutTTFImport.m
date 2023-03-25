function OutPutTTFImport(app,CallerApp)
    try
        DefaultDir = CallerApp.UsersData.LastDir;
    catch
        DefaultDir = pwd;
    end
    f = figure( 'Renderer' , 'painters' , 'Position' , [-100 -100 0 0]);
    [FileName,PathName] = uigetfile('*.csv','Select the TransTemptFile file',DefaultDir,'MultiSelect','off');
    close(f)
    if isequal(FileName,0) || isequal(PathName,0)
        return
    end
    app.TransTemptTextArea.Value = fullfile(PathName,FileName);
    CallerApp.UsersData.LastDir = PathName;
end
