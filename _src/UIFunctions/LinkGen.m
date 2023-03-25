function LinkGen(app)
    ErrorMessage = '';
    try
        if isfield(app.UsersData,'LastDir')
            LastDir = app.UsersData.LastDir;
        else
            LastDir = pwd;
        end
        Data = ["Layer","Link"];
        Notice = uiprogressdlg(app.UIFigure,"Message","处理较慢,请耐心等待.","Title","Notice","Icon","info","Indeterminate","on");
        drawnow;
    catch ME
        ErrorMessage = ErrorMessage + CatchProcess(ME);
        uialert(app.UIFigure,ErrorMessage,'Error','Icon','error');
    end
    % wait users to choose a file name to save
    try
        f = figure( 'Renderer' , 'painters' , 'Position' , [-100 -100 0 0]);
        [FileName,PathName] = uiputfile('*.xlsx','Save as',LastDir + "\" + "Link.xlsx");
        close(f);
        if isequal(FileName,0) || isequal(PathName,0)
            close(Notice);
            return
        end
        FileName = string(FileName);
        PathName = string(PathName);
        FilePath = fullfile(PathName,FileName);
        % write the file
        writematrix(Data,FilePath);
        app.GenMLinkTable.Data = FilePath;
    catch ME
        ErrorMessage = ErrorMessage + CatchProcess(ME);
        uialert(app.UIFigure,ErrorMessage,'Error','Icon','error');
        close(Notice);
        return
    end 
    close(Notice);
    try
        winopen(FilePath);
    catch ME
        ErrorMessage = ErrorMessage + CatchProcess(ME);
        uialert(app.UIFigure,ErrorMessage,'Error','Icon','error');
        close(Notice);
        return
    end
    app.UsersData.LastDir = PathName;
end