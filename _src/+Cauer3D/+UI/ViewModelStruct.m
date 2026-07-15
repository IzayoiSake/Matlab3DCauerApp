function ViewModelStruct(app,event);
    import Cauer3D.Model.*
    import Cauer3D.UI.*
    import Cauer3D.Nomenclature.*
    import Cauer3D.Plot.*
    import Cauer3D.Export.*
    import Cauer3D.IO.*
    import Cauer3D.Internal.*
    % This function is called when the user clicks on the "View Model" button
    
    % Get the Data
    ModelStruct = app.ModelStruct;

    assignin("base",'ModelStruct',ModelStruct);
    open('ModelStruct');
end


