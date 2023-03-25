function TransientPowerTable(app,event)
    if event.EventName == "CellEdit"
        ChangedData = app.TransientPowerTable.Data;
        Data = ChangedData;
        % delete the Data element that is emtpy
        Data = Data(~cellfun('isempty',Data(:,1)),:);
        app.TransientPowerTable.Data = Data;
    end
end