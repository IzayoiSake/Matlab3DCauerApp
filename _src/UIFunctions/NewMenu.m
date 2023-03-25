function NewMenu(app,event)
    % create an message to ask users if they want to save the current data before create a new one
    AlertResponse = uiconfirm(app.UIFigure,'Do you want to save the current data before create a new one?','New','Options',{'Yes','No','Cancel'},'DefaultOption',1,'CancelOption',3);
    % if users click 'Yes', save the data
    if AlertResponse == "Yes"
        IfSave = SaveMenu(app,event);
        if IfSave == 0
            return;
        end
    % if users click 'No', do nothing
    elseif AlertResponse == "No"
    % if users click 'Cancel', cancel the new data
    elseif AlertResponse == "Cancel"
        return;
    end
    % create a new AppData
    AppStartup(app);
end

