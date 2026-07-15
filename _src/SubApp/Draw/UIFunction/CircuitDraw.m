function CircuitDraw(app)
    f = uiprogressdlg(app.UIFigure, 'Title' , 'Please wait...' , 'Message' , 'Calculating...' , ...
    'Cancelable' , 'off' , "Icon" , "info" , "Indeterminate" , "on");
    CheckBoxToNodeSelect(app);
    ModelStruct = app.CallerApp.ModelStruct;
    try
        if ModelStruct.Temp.State ~= "End"
            error("Parameter identification is not complete.");
        end
        [Time,CauerValue] = SimulateCauerStateSpace(ModelStruct);
        TestData = ModelStruct.Result.TestData;
        ModelStruct.Result.ComparisonData.Time = Time;
        ModelStruct.Result.ComparisonData.CauerValue = CauerValue;
        app.CallerApp.ModelStruct = ModelStruct;
        THeader = TestData.THeader;
        TData = TestData.TData;
        Ttime = TestData.Ttime;
    catch ME
        f.close();
        ErrorMessage = "请先完成参数辨识并加载测试集数据。" + newline + CatchProcess(ME);
        uialert(app.UIFigure, ErrorMessage, "无法画图", "Icon", "error");
        return;
    end
    try
        DrawNum = sum(ModelStruct.Result.Draw.NodeSelect);
        Figure1Value = zeros(length(Time), DrawNum*2);
        Figure1Legend = cell(1, DrawNum*2);
        DrawPointer = 1;
        Figure2Value = zeros(length(Time), DrawNum);
        Figure2Legend = cell(1, DrawNum);
        for i = 1:numel(ModelStruct.Result.Draw.NodeSelect)
            if ModelStruct.Result.Draw.NodeSelect(i) == 1
                ThisNodeName = ModelStruct.NodeNameEffective(i);
                Index = GetNodeNameIndex(ThisNodeName, THeader);
                TempValue = TData(:, Index);
                Figure1Value(:, DrawPointer) = interp1(Ttime, TempValue, Time, "linear");
                [ThisPos,ThisLay] = GetNodePosAndLay(ThisNodeName);
                Figure1Legend{1, DrawPointer} = "FFE: " + "P" + "(" + ThisPos + "," + ThisLay + ")";
                Figure1Value(:, DrawPointer + DrawNum) = CauerValue(:, i);
                Figure1Legend{1, DrawPointer + DrawNum} = "3D Cauer: " + "P" + "(" + ThisPos + "," + ThisLay + ")";
                Figure2Value(:, DrawPointer) = (Figure1Value(:, DrawPointer) - Figure1Value(:, DrawPointer + DrawNum));
                Figure2Legend{1, DrawPointer} = "P" + "(" + ThisPos + "," + ThisLay + ")";
                DrawPointer = DrawPointer + 1;
            end
        end
        figure( 'Name' , 'Temperature' , 'NumberTitle' , 'off' );
        SetFigure();
        FFELines = plot(Time, Figure1Value(:, 1:DrawNum), "LineStyle", "-");
        NodeColors = zeros(DrawNum,3);
        for i = 1:DrawNum
            NodeColors(i,:) = FFELines(i).Color;
        end
        hold on;
        CauerLines = plot(Time, Figure1Value(:, DrawNum+1:end), "LineStyle", "--");
        for i = 1:DrawNum
            CauerLines(i).Color = NodeColors(i,:);
        end
        hold off;
        legend(Figure1Legend);
        xlabel( 'Time (s)' );
        ylabel( 'Temperature (℃)' );
        title( 'FFE and 3D Cauer Comparison' );
        figure( 'Name' , 'Error' , 'NumberTitle' , 'off' );
        SetFigure();
        ErrorLines = plot(Time, Figure2Value);
        for i = 1:DrawNum
            ErrorLines(i).Color = NodeColors(i,:);
        end
        legend(Figure2Legend);
        xlabel( 'Time (s)' );
        ylabel( 'Temperature Error (℃)' );
        title( 'FFE and 3D Cauer Error' );
    catch ME
        f.close();
        ErrorMessage = "Draw Error!" ;
        errordlg(ErrorMessage);
        return;
    end
    f.close();
end

function SetFigure()
    % 设置字体""Times New Roman"
        set(0,'DefaultAxesFontName','Times New Roman');
    % 设置字体大小
        set(0,'DefaultAxesFontSize',12);
    % 字体加粗
        set(0,'DefaultAxesFontWeight','bold');
    % 设置坐标轴网格线
        set(0,'DefaultAxesXGrid','on');
        set(0,'DefaultAxesYGrid','on');
        set(0,'DefaultAxesZGrid','on');
    % 设置标尺的LimMode为manual
        set(0,'DefaultAxesXLimMode','auto');
        set(0,'DefaultAxesYLimMode','auto');
    % 设置Y轴标尺的YLim
        set(0,'DefaultAxesYLim',[0.038,0.062]);
    % 设置X轴标尺的XLim
        set(0,'DefaultAxesXLim',[10,100]);
    % 线宽全部设置为2
        set(0,'DefaultLineLineWidth',2);
end


