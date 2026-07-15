function NomenclatureDropDown(app,event)
    import Cauer3D.Model.*
    import Cauer3D.UI.*
    import Cauer3D.Nomenclature.*
    import Cauer3D.Plot.*
    import Cauer3D.Export.*
    import Cauer3D.IO.*
    import Cauer3D.Internal.*
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