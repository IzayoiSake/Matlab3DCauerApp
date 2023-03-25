function SteadyThermTable(app,event)
    if event.EventName == "CellEdit"
        ChangedData = app.SteadyThermTable.Data;
        Data = ChangedData;
        % delete the Data element that is emtpy
        Data = Data(~cellfun('isempty',Data(:,1)),:);
        app.SteadyThermTable.Data = Data;
    end
end
