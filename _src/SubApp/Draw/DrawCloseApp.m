function DrawCloseApp(app)
    f = uiprogressdlg(app.UIFigure, 'Title' , 'Please wait...' , 'Message' , 'Closing and Saving...' , ...
    'Cancelable' , 'off' , "Icon" , "info" , "Indeterminate" , "on");
    NodeNameEffective = app.CallerApp.ModelStruct.NodeNameEffective;
    ModelStruct = app.CallerApp.ModelStruct;
    app.CallerApp.ModelStruct = ModelStruct;
    CheckBoxToNodeSelect(app);
    close(f);
    delete(app);
end