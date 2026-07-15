function CloseMainApp(app, event)
% CloseMainApp Persist application data before closing the main window.

    Cauer3D.UI.CloseAppPreProcess(app, event);
    delete(app);
end
