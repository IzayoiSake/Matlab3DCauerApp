function AppStartup(app)
% add folder "src" and subfolders to path
    addpath(genpath('_src'));
% NomenclatureDropDown
    NomenclatureL = GetNomenclatureList();
    app.NomenclatureDropDown.Items = NomenclatureL;
    app.NomenclatureDropDown.Value = NomenclatureL(2);
% NomenclatureLable
    [NomenclatureList,Description,Example] = GetNomenclatureList(2);
    Value = NomenclatureList(2);
    app.NomenclatureDropDown.Value = Value;
    DescriptionLine = Description(2) + newline + Example(2);
    app.NomenclatureLabel.Text=DescriptionLine;
% All the Tables
    % Find all the tables
    Tables = findobj(app.UIFigure,'Type','uitable');
    % Set the data of the tables
    for i = 1:length(Tables)
        Tables(i).Data = '';
    end
% All the NumericEditField
    % Find all the NumericEditField
    NumericEditField = findobj(app.UIFigure,'Type','uieditfield');
    % Set the data of the NumericEditField
    for i = 1:length(NumericEditField)
        NumericEditField(i).Value = 0;
    end
    app.ParPoolEditField.Value = 10;
    app.StepSizeEditField.Value = 1e-4;
% All the TextArea
    % Find all the TextArea
    TextArea = findobj(app.UIFigure,'Type','uitextarea');
    % Set the data of the TextArea
    for i = 1:length(TextArea)
        TextArea(i).Value = '';
    end


    app.ModelStruct = [];
    app.UsersData = [];
end