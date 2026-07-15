function ExportSlxModel(app)
% ExportSlxModel Generate a Simscape SLX model from cached test data.

    try
        if app.ModelStruct.Temp.State ~= "End"
            error("The fitted model is not ready.");
        end
        app.ModelStruct.Result.TestData.TransTemptPath;
        app.ModelStruct.Result.TestData.TransPowerPath;
    catch
        uialert(app.UIFigure, "请先加载测试集数据。", "错误", "Icon", "error");
        return;
    end

    try
        defaultDir = app.UsersData.LastDir;
    catch
        defaultDir = pwd;
    end
    [fileName, pathName] = uiputfile("*.slx", "导出SLX模型", ...
        fullfile(defaultDir, "Circuit.slx"));
    if isequal(fileName, 0)
        return;
    end

    app.ModelStruct.Result.CircuitResultPath = fullfile(pathName, fileName);
    app.ModelStruct.Result.TransTemptPath = ...
        app.ModelStruct.Result.TestData.TransTemptPath;
    app.ModelStruct.Result.TransPowerPath = ...
        app.ModelStruct.Result.TestData.TransPowerPath;
    app.UsersData.LastDir = pathName;

    progress = uiprogressdlg(app.UIFigure, "Title", "请稍候", ...
        "Message", "正在生成Simscape SLX模型...", "Indeterminate", "on");
    progressCleanup = onCleanup(@() delete(progress));
    try
        app.ModelStruct = ResultToPowergui(app.ModelStruct);
        uialert(app.UIFigure, "SLX模型导出完成。", "完成", "Icon", "success");
    catch ME
        uialert(app.UIFigure, CatchProcess(ME), "SLX导出失败", "Icon", "error");
    end
end
