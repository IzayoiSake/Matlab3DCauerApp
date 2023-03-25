function CheckBoxesSAValueChanged(src,event)
    app = src.UserData.app;
    Value = app.CheckBoxesSA.Value;
    if Value == 1
        app.CheckBoxesSA.Value = 1;
    else
        app.CheckBoxesSA.Value = 0;
    end
    for i = 1:numel(app.CheckBoxes)
        try
            app.CheckBoxes{i}.Value = Value;
        catch
        end
    end
    for i = 1:numel(app.CheckBoxesSL)
        try
            app.CheckBoxesSL{i}.Value = Value;
        catch
        end
    end
    for i = 1:numel(app.CheckBoxesSP)
        try
            app.CheckBoxesSP{i}.Value = Value;
        catch
        end
    end
end