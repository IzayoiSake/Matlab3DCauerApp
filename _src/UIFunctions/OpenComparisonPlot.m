function OpenComparisonPlot(app)
% OpenComparisonPlot Open the node-selection app when inputs are ready.

    try
        if app.ModelStruct.Temp.State ~= "End"
            error("Parameter identification is not complete.");
        end
        app.ModelStruct.Result.TestData.TData;
        app.ModelStruct.Result.TestData.PData;
    catch
        uialert(app.UIFigure, ...
            "请先完成参数辨识并加载测试集数据。", "错误", "Icon", "error");
        return;
    end
    DrawApp(app);
end
