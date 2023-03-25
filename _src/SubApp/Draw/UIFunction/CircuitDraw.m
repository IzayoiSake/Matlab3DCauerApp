function CircuitDraw(app)
    f = uiprogressdlg(app.UIFigure, 'Title' , 'Please wait...' , 'Message' , 'Calculating...' , ...
    'Cancelable' , 'off' , "Icon" , "info" , "Indeterminate" , "on");
    CheckBoxToNodeSelect(app);
    ModelStruct = app.CallerApp.ModelStruct;
    try
        ModelStruct.Result.CircuitResultPath;
        ModelStruct.Result.TransTemptPath;
        ModelStruct.Result.TransPowerPath;
        Out = ModelStruct.Result.CircuitData.Out;
        CauerValue = Out.ScopeData.signals.values;
        Time = Out.ScopeData.time(:);
        THeader = ModelStruct.Result.CircuitData.THeader;
        TData = ModelStruct.Result.CircuitData.TData;
        Ttime = ModelStruct.Result.CircuitData.Ttime;
    catch ME
        f.close();
        ErrorMessage = "Please Output the Circuit Result First!" ;
        errordlg(ErrorMessage);
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
                fit = createFit(Ttime, TempValue);
                Figure1Value(:, DrawPointer) = fit(Time);
                [ThisPos,ThisLay] = GetNodePosAndLay(ThisNodeName);
                Figure1Legend{1, DrawPointer} = "FFE: " + "P" + "(" + ThisPos + "," + ThisLay + ")";
                Figure1Value(:, DrawPointer + DrawNum) = CauerValue(i, 1, :);
                Figure1Legend{1, DrawPointer + DrawNum} = "3D Cauer: " + "P" + "(" + ThisPos + "," + ThisLay + ")";
                Figure2Value(:, DrawPointer) = (Figure1Value(:, DrawPointer) - Figure1Value(:, DrawPointer + DrawNum));
                Figure2Legend{1, DrawPointer} = "P" + "(" + ThisPos + "," + ThisLay + ")";
                DrawPointer = DrawPointer + 1;
            end
        end
        figure( 'Name' , 'Temperature' , 'NumberTitle' , 'off' );
        SetFigure();
        plot(Time, Figure1Value);
        legend(Figure1Legend);
        xlabel( 'Time (s)' );
        ylabel( 'Temperature (℃)' );
        title( 'FFE and 3D Cauer Comparison' );
        figure( 'Name' , 'Error' , 'NumberTitle' , 'off' );
        SetFigure();
        plot(Time, Figure2Value);
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


