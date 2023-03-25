function ViewModelStruct(app,event);
    % This function is called when the user clicks on the "View Model" button
    
    % Get the Data
    ModelStruct = app.ModelStruct;

    assignin("base",'ModelStruct',ModelStruct);
    open('ModelStruct');
end


