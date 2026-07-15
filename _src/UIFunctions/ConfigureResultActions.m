function ConfigureResultActions(app)
% ConfigureResultActions Configure the three result workflow buttons.

    app.GridLayout8_2.ColumnWidth = {'1x', '1x', '1x'};
    app.OutPutToSlx.Text = '加载测试集数据';
    app.OutPutToSlx.Layout.Column = 1;
    app.OutPutToSlx.ButtonPushedFcn = @(~,~) LoadTestData(app);

    exportButton = findobj(app.GridLayout8_2, 'Tag', 'ExportSlxButton');
    if isempty(exportButton)
        exportButton = uibutton(app.GridLayout8_2, 'push');
        exportButton.Tag = 'ExportSlxButton';
    end
    exportButton.Text = '导出SLX模型';
    exportButton.FontName = '微软雅黑';
    exportButton.Layout.Row = 1;
    exportButton.Layout.Column = 2;
    exportButton.ButtonPushedFcn = @(~,~) ExportSlxModel(app);

    app.DrawButton.Text = '画图对比';
    app.DrawButton.Layout.Column = 3;
    app.DrawButton.ButtonPushedFcn = @(~,~) OpenComparisonPlot(app);
end
