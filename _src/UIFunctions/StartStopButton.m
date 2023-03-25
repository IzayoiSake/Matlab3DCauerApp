function StartStopButton(app,event)
% check the state of the button
    if app.StartStopButton.Value == 1
        app.StartStopButton.Text = "暂时停止" + newline + "(暂停耗时较长,需等待)";
        % draw the app
        drawnow;
        ModelStructSettingsGetFromUI(app,event);
        Loop = 1;
        app.UsersData.Signal.Pause = 0;
        while Loop
            try
                [ModelStruct] = CauerApp(app.ModelStruct);
            catch ME
                ErrorMessage = CatchProcess(ME);
                app.StartStopButton.Text = '重新开始计算';
                app.ModelStruct = [];
                uialert(app.UIFigure,ErrorMessage,'错误','Icon','error');
                break;
            end
            app.ModelStruct = ModelStruct;
            app.MessageTextArea.Value = string(ModelStruct.Message);
            drawnow;
            drawnow;
            drawnow;
            Loop = ~strcmp(app.ModelStruct.Temp.State,"End");
            if ~Loop
                app.ModelStruct = ModelStruct;
                app.StartStopButton.Text = '开始计算';
                break;
            elseif app.UsersData.Signal.Pause == 1
                app.StartStopButton.Text = '继续计算';
                app.StartStopButton.Value = 0;
                break;
            end
        end
        app.StartStopButton.Value = 0;
        app.UsersData.Signal.Pause = 1;
    else
        app.StartStopButton.Value = 0;
        app.StartStopButton.Text = '继续计算';
        app.UsersData.Signal.Pause = 1;
    end
end