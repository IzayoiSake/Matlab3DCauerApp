function SteadyPowerTable(app,event)
    if event.EventName == "CellEdit"
        ChangedData = app.SteadyPowerTable.Data;
        Data = ChangedData;
        % delete the Data element that is emtpy
        Data = Data(~cellfun('isempty',Data(:,1)),:);
        app.SteadyPowerTable.Data = Data;
    end
end