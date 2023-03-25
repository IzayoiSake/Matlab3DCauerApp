function DrawStartup(app,CallerApp)
    app.CallerApp = CallerApp;
    drawnow;
    f = uiprogressdlg(app.UIFigure, 'Title' , 'Please wait...' , 'Message' , 'Generating CheckBoxes...' , ...
    'Cancelable' , 'off' , "Icon" , "info" , "Indeterminate" , "on");
    try
        ModelStruct = CallerApp.ModelStruct;
        if ModelStruct.Temp.State ~= "End"
            error("");
        end
    catch
        ErrorMessage = "The model is not ready to be plotted. Please run the model first.";
        uialert(app.UIFigure,ErrorMessage,"Error",'Icon','error');
        return;
    end
    NodeNameEffective = ModelStruct.NodeNameEffective;
    [Pos,Lay] = GetNodePosAndLay(NodeNameEffective);
    AllPos = unique(Pos);
    AllLay = unique(Lay);
    ModelStruct.Result.Draw.AllPos = AllPos;
    ModelStruct.Result.Draw.AllLay = AllLay;
    CheckBoxRowNum = numel(AllLay);
    CheckBoxColNum = numel(AllPos);
    % change the size of the NodeSelectPanel to fit the number of nodes.(Each node has a checkbox,and size is [80,20].)
    CheckBoxWidth = 120;
    CheckBoxHeight = 30;
    InterSpace = 5;
    % create the checkboxes
    try
        Row = 1;
        Col = 1;
        Position = [InterSpace + (Col - 1) * (CheckBoxWidth + InterSpace),...
            480 - InterSpace - (Row - 1) * (CheckBoxHeight + InterSpace),CheckBoxWidth,CheckBoxHeight];
        app.CheckBoxesSA = uicheckbox(app.NodeSelectPanel);
        Text = "全选";
        app.CheckBoxesSA.Text = Text;
        app.CheckBoxesSA.Position = Position;

        for Row = 1:CheckBoxRowNum
            Col = 1;
            Position = [InterSpace + (Col - 1) * (CheckBoxWidth + InterSpace),...
                480 - InterSpace - (Row) * (CheckBoxHeight + InterSpace),CheckBoxWidth,CheckBoxHeight];
            app.CheckBoxesSL{Row} = uicheckbox(app.NodeSelectPanel);
            Text = "第" + num2str(AllLay(Row)) + "层-全选";
            app.CheckBoxesSL{Row}.Text = Text;
            app.CheckBoxesSL{Row}.Position = Position;
        end
        for Col = 1:CheckBoxColNum
            Row = 1;
            Position = [InterSpace + (Col) * (CheckBoxWidth + InterSpace),...
                480 - InterSpace - (Row - 1) * (CheckBoxHeight + InterSpace),CheckBoxWidth,CheckBoxHeight];
            app.CheckBoxesSP{Col} = uicheckbox(app.NodeSelectPanel);
            Text = "第" + num2str(AllPos(Col)) + "位置-全选";
            app.CheckBoxesSP{Col}.Text = Text;
            app.CheckBoxesSP{Col}.Position = Position;
        end
        for Row = 1:CheckBoxRowNum
            for Col = 1:CheckBoxColNum
                ThisPos = AllPos(Col);
                ThisLay = AllLay(Row);
                Index = ismember([Pos,Lay],[ThisPos,ThisLay],'rows');
                if sum(Index) == 0
                    continue;
                end
                app.CheckBoxes{Row,Col} = uicheckbox(app.NodeSelectPanel);
                ThisNodeName = NodeNameEffective(Index);
                Text = ThisNodeName;
                app.CheckBoxes{Row,Col}.Text = Text;
                Position = [InterSpace + (Col) * (CheckBoxWidth + InterSpace),...
                    480 - InterSpace - (Row) * (CheckBoxHeight + InterSpace),CheckBoxWidth,CheckBoxHeight];
                app.CheckBoxes{Row,Col}.Position = Position;
            end
        end
        CallerApp.ModelStruct = ModelStruct;
        NodeSelectToCheckBox(app);
        % add callbacks function to CheckBoxesSA,CheckBoxesSL,CheckBoxesSP,CheckBoxes
        app.CheckBoxesSA.UserData.app = app;
        app.CheckBoxesSA.ValueChangedFcn = @(src,event)CheckBoxesSAValueChanged(src,event);
        for Row = 1:CheckBoxRowNum
            app.CheckBoxesSL{Row}.UserData.app = app;
            app.CheckBoxesSL{Row}.ValueChangedFcn = @(src,event)CheckBoxesSLValueChanged(src,event);
        end
        for Col = 1:CheckBoxColNum
            app.CheckBoxesSP{Col}.UserData.app = app;
            app.CheckBoxesSP{Col}.ValueChangedFcn = @(src,event)CheckBoxesSPValueChanged(src,event);
        end
    catch ME
        ErrorMessage = "Unkonw Error.";
        uialert(app.UIFigure,ErrorMessage,"Error",'Icon','error');
        close(f);
        % wait for the user to close the error message box.
        uiwait;
        delete(app);
        return;
    end
    close(f);
end