function OpenComparisonPlot(app)
    import Cauer3D.Model.*
    import Cauer3D.UI.*
    import Cauer3D.Nomenclature.*
    import Cauer3D.Plot.*
    import Cauer3D.Export.*
    import Cauer3D.IO.*
    import Cauer3D.Internal.*
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
    Cauer3D.Plot.DrawApp(app);
end
