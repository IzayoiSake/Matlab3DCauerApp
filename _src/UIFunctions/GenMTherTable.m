function GenMTherTable(app,event)
    if event.EventName == "CellEdit"
        ChangedData = app.GenMTherTable.Data;
        Data = ChangedData;
        % delete the Data element that is emtpy
        Data = Data(~cellfun('isempty',Data(:,1)),:);
        app.GenMTherTable.Data = Data;
    end
end