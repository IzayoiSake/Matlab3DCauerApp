function InvisibleButton(app,event)
    import Cauer3D.Model.*
    import Cauer3D.UI.*
    import Cauer3D.Nomenclature.*
    import Cauer3D.Plot.*
    import Cauer3D.Export.*
    import Cauer3D.IO.*
    import Cauer3D.Internal.*
    Value = app.Lable_5.Text;
    Value = string(Value);
    Value = double(Value);
    Value = Value + 1;
    app.Lable_5.Text = string(Value);
end