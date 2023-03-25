function slxDirFolderSelect(app,event)
    if isfield(app.UsersData,'LastDir')
        LastDir = app.UsersData.LastDir;
    else
        LastDir = pwd;
    end
    f = figure( 'Renderer' , 'painters' , 'Position' , [-100 -100 0 0]);
    slxDir = uigetdir(LastDir, 'Select a folder' );
    close(f);
    if slxDir == 0
        return
    end
    slxDir = [slxDir '\'];
    app.slxDirFolderTextArea.Value = slxDir;
end