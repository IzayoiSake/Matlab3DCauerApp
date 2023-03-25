function GenMLinkTable(app,event)
    if event.EventName == "CellEdit"
        ChangedData = app.GenMLinkTable.Data;
        Data = ChangedData;
        % delete the Data element that is emtpy
        Data = Data(~cellfun('isempty',Data(:,1)),:);
        app.GenMLinkTable.Data = Data;
    end
end