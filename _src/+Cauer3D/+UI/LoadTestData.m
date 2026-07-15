function LoadTestData(app)
    import Cauer3D.Model.*
    import Cauer3D.UI.*
    import Cauer3D.Nomenclature.*
    import Cauer3D.Plot.*
    import Cauer3D.Export.*
    import Cauer3D.IO.*
    import Cauer3D.Internal.*
% LoadTestData Open the test-data setup window.

    try
        if app.ModelStruct.Temp.State ~= "End"
            error("The fitted model is not ready.");
        end
    catch
        uialert(app.UIFigure, "请先完成模型参数辨识。", "错误", "Icon", "error");
        return;
    end

    testDataApp = Cauer3D.Export.OutPutSlx(app);
    testDataApp.UIFigure.Name = "加载测试集数据";
    testDataApp.StateSpace.Visible = "off";
    testDataApp.StateSpace.Enable = "off";
    testDataApp.Circuit.Text = "确认加载";
    testDataApp.Circuit.Layout.Column = [1, 3];
    testDataApp.Circuit.ButtonPushedFcn = ...
        @(~,~) confirmTestData(testDataApp, app);
end

function confirmTestData(testDataApp, mainApp)
    import Cauer3D.Model.*
    import Cauer3D.UI.*
    import Cauer3D.Nomenclature.*
    import Cauer3D.Plot.*
    import Cauer3D.Export.*
    import Cauer3D.IO.*
    import Cauer3D.Internal.*
    temperaturePath = getTextAreaPath(testDataApp.TransTemptTextArea, "瞬态温度");
    powerPath = getTextAreaPath(testDataApp.TransPowerTextArea, "瞬态功率");

    progress = uiprogressdlg(testDataApp.UIFigure, "Title", "请稍候", ...
        "Message", "正在读取并校验测试集...", "Indeterminate", "on");
    progressCleanup = onCleanup(@() delete(progress));
    try
        mainApp.ModelStruct = PrepareTransientTestData( ...
            mainApp.ModelStruct, temperaturePath, powerPath);
        powerDirectory = fileparts(powerPath);
        if powerDirectory ~= ""
            mainApp.UsersData.LastDir = powerDirectory;
        end
        delete(progressCleanup);
        delete(testDataApp);
        uialert(mainApp.UIFigure, "测试集数据已加载。", "完成", "Icon", "success");
    catch ME
        uialert(testDataApp.UIFigure, CatchProcess(ME), ...
            "测试集加载失败", "Icon", "error");
    end
end

function path = getTextAreaPath(textArea, dataName)
    import Cauer3D.Model.*
    import Cauer3D.UI.*
    import Cauer3D.Nomenclature.*
    import Cauer3D.Plot.*
    import Cauer3D.Export.*
    import Cauer3D.IO.*
    import Cauer3D.Internal.*
    value = string(textArea.Value);
    value = value(strlength(strtrim(value)) > 0);
    if ~isscalar(value)
        error(dataName + "文件路径不能为空，并且只能设置一个文件。");
    end
    path = strtrim(value);
end
