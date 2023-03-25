function TransientThermTable(app,event)
    if event.EventName == "CellEdit"
        ChangedData = app.TransientThermTable.Data;
        Data = ChangedData;
        % delete the Data element that is emtpy
        Data = Data(~cellfun('isempty',Data(:,1)),:);
        app.TransientThermTable.Data = Data;
    end
end