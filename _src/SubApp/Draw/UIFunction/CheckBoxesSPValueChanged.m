function CheckBoxesSPValueChanged(src,event)
    app = src.UserData.app;
    Value = src.Value;
    Text = src.Text;
    ModelStruct = app.CallerApp.ModelStruct;
    if Value == 1
        src.Value = 1;
    else
        src.Value = 0;
        app.CheckBoxesSA.Value = 0;
    end
    
    NumberString = regexp(Text,'\d*','Match');
    NumberString = string(NumberString);
    Pos = str2double(NumberString{1});
    AllLay = ModelStruct.Result.Draw.AllLay;
    AllPos = ModelStruct.Result.Draw.AllPos;
    Index = find(AllPos == Pos);
    for Row = 1:numel(AllLay)
        Col = Index;
        app.CheckBoxes{Row,Col}.Value = Value;
    end
    app.CallerApp.ModelStruct = ModelStruct;
end