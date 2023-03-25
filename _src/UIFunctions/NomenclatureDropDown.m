function NomenclatureDropDown(app,event)
    if event.EventName == "DropDownOpening"
        app.NomenclatureDropDown.Items=GetNomenclatureList(0);
    end
    
    if event.EventName == "ValueChanged"
        Value=app.NomenclatureDropDown.Value;
        [NomenclatureList,Description,Example]=GetNomenclatureList(2);
        Value=string(Value);
        ValueIndex=find(NomenclatureList==Value);
        DescriptionLine=Description(ValueIndex);
        DescriptionLine = DescriptionLine + newline + Example(ValueIndex);
        app.NomenclatureLabel.Text=DescriptionLine;
    end
end