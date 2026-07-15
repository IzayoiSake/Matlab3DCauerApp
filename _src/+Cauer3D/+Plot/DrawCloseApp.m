function DrawCloseApp(app)
    import Cauer3D.Model.*
    import Cauer3D.UI.*
    import Cauer3D.Nomenclature.*
    import Cauer3D.Plot.*
    import Cauer3D.Export.*
    import Cauer3D.IO.*
    import Cauer3D.Internal.*
    f = uiprogressdlg(app.UIFigure, 'Title' , 'Please wait...' , 'Message' , 'Closing and Saving...' , ...
    'Cancelable' , 'off' , "Icon" , "info" , "Indeterminate" , "on");
    NodeNameEffective = app.CallerApp.ModelStruct.NodeNameEffective;
    ModelStruct = app.CallerApp.ModelStruct;
    app.CallerApp.ModelStruct = ModelStruct;
    CheckBoxToNodeSelect(app);
    close(f);
    delete(app);
end