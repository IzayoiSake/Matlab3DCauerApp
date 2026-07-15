function ModelStruct = PrepareTransientTestData(ModelStruct, temperaturePath, powerPath)
    import Cauer3D.Model.*
    import Cauer3D.UI.*
    import Cauer3D.Nomenclature.*
    import Cauer3D.Plot.*
    import Cauer3D.Export.*
    import Cauer3D.IO.*
    import Cauer3D.Internal.*
% PrepareTransientTestData Read and normalize transient comparison data.

    [temperatureData, temperatureType] = ReadFile(temperaturePath);
    if temperatureType ~= "TTS"
        error("The selected transient temperature file is not valid.");
    end
    [powerData, powerType] = ReadFile(powerPath);
    if powerType ~= "TPS"
        error("The selected transient power file is not valid.");
    end

    temperatureHeader = ConvertNodeName(temperatureData(1, 2:end), ...
        ModelStruct.Temp.Nomenclature);
    powerHeader = ConvertNodeName(powerData(1, 2:end), ...
        ModelStruct.Temp.Nomenclature);
    [temperatureHeader, temperatureIndex] = SortByNodeName( ...
        temperatureHeader, ModelStruct.NodeName);
    [powerHeader, powerIndex] = SortByNodeName(powerHeader, ModelStruct.NodeName);

    temperatureTime = double(temperatureData(2:end, 1));
    temperatureValue = double(temperatureData(2:end, 1 + temperatureIndex));
    powerTime = double(powerData(2:end, 1));
    powerValue = double(powerData(2:end, 1 + powerIndex));

    validateTransientData(temperatureTime, temperatureValue, "temperature");
    validateTransientData(powerTime, powerValue, "power");

    testData.TransTemptPath = string(temperaturePath);
    testData.TransPowerPath = string(powerPath);
    testData.THeader = temperatureHeader;
    testData.Ttime = temperatureTime;
    testData.TData = temperatureValue;
    testData.PHeader = powerHeader;
    testData.Ptime = powerTime;
    testData.PData = powerValue;
    ModelStruct.Result.TestData = testData;
    ModelStruct.Result.TransTemptPath = testData.TransTemptPath;
    ModelStruct.Result.TransPowerPath = testData.TransPowerPath;
end

function validateTransientData(time, value, dataName)
    import Cauer3D.Model.*
    import Cauer3D.UI.*
    import Cauer3D.Nomenclature.*
    import Cauer3D.Plot.*
    import Cauer3D.Export.*
    import Cauer3D.IO.*
    import Cauer3D.Internal.*
    if isempty(time) || size(value, 1) ~= numel(time)
        error("The transient " + dataName + " data has inconsistent dimensions.");
    end
    if any(~isfinite([time(:); value(:)]))
        error("The transient " + dataName + " data contains NaN or Inf.");
    end
    if any(diff(time) <= 0)
        error("The transient " + dataName + " time vector must be strictly increasing.");
    end
    if time(1) > 0 || time(end) <= 0
        error("The transient " + dataName + " data must cover simulation time zero.");
    end
end
