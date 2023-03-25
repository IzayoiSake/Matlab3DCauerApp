function CloseAppPreProcess(app,event)
    % remove the "src" folder and all subfolders from the path
    rmpath(genpath('_src'));
end