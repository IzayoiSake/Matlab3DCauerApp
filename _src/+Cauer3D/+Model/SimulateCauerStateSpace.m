function [time, temperature] = SimulateCauerStateSpace(ModelStruct)
    import Cauer3D.Model.*
    import Cauer3D.UI.*
    import Cauer3D.Nomenclature.*
    import Cauer3D.Plot.*
    import Cauer3D.Export.*
    import Cauer3D.IO.*
    import Cauer3D.Internal.*
% SimulateCauerStateSpace Simulate the fitted Cauer model using Tustin steps.

    if ModelStruct.Temp.State ~= "End"
        error("Parameter identification must finish before comparison simulation.");
    end
    testData = ModelStruct.Result.TestData;
    stepSize = ModelStruct.Temp.StepSize;
    if ~isscalar(stepSize) || ~isfinite(stepSize) || stepSize <= 0
        error("The calculation step size must be a positive finite scalar.");
    end

    effectiveNames = string(ModelStruct.NodeNameEffective(:));
    allNames = string(ModelStruct.NodeName(:));
    temperatureHeader = string(testData.THeader(:));
    powerHeader = string(testData.PHeader(:));
    ambientNames = allNames(~ismember(allNames, effectiveNames));

    temperatureIndex = requireNodeColumns(effectiveNames, temperatureHeader, "temperature");
    powerIndex = requireNodeColumns(effectiveNames, powerHeader, "power");
    ambientIndex = requireNodeColumns(ambientNames, temperatureHeader, "ambient temperature");

    stopTime = min(testData.Ttime(end), testData.Ptime(end));
    timeMask = testData.Ttime >= 0 & testData.Ttime <= stopTime;
    time = testData.Ttime(timeMask);
    if isempty(time)
        error("The test data does not contain comparison samples at or after time zero.");
    end
    simulationTime = createSimulationTime(stopTime, stepSize);

    power = interp1(testData.Ptime, testData.PData(:, powerIndex), ...
        simulationTime, "linear");
    if isempty(ambientIndex)
        heatFlow = power;
    else
        ambientTemperature = interp1(testData.Ttime, ...
            testData.TData(:, ambientIndex), simulationTime, "linear");
        heatFlow = power + ambientTemperature*ModelStruct.Ga.';
    end

    capacitance = double(ModelStruct.C);
    conductance = double(ModelStruct.G);
    nodeCount = numel(effectiveNames);
    if ~isequal(size(capacitance), [nodeCount, nodeCount]) || ...
            ~isequal(size(conductance), [nodeCount, nodeCount])
        error("The fitted C and G matrices do not match the effective node count.");
    end
    if any(~isfinite([capacitance(:); conductance(:); heatFlow(:)]))
        error("The state-space model or test input contains NaN or Inf.");
    end

    initialTemperature = interp1(testData.Ttime, ...
        testData.TData(:, temperatureIndex), 0, "linear").';
    temperatureOnGrid = zeros(numel(simulationTime), nodeCount);
    temperatureOnGrid(1, :) = initialTemperature.';
    identity = eye(nodeCount);
    previousStep = NaN;

    for k = 1:(numel(simulationTime) - 1)
        currentStep = simulationTime(k + 1) - simulationTime(k);
        stepTolerance = 8*eps(max([1, abs(currentStep), abs(previousStep)]));
        if isnan(previousStep) || abs(currentStep - previousStep) > stepTolerance
            leftMatrix = capacitance + currentStep*conductance/2;
            transition = leftMatrix\(capacitance - currentStep*conductance/2);
            inputGain = leftMatrix\(currentStep*identity/2);
            previousStep = currentStep;
        end
        currentTemperature = temperatureOnGrid(k, :).';
        nextTemperature = transition*currentTemperature + ...
            inputGain*(heatFlow(k, :) + heatFlow(k + 1, :)).';
        temperatureOnGrid(k + 1, :) = nextTemperature.';
    end

    temperature = interp1(simulationTime, temperatureOnGrid, time, "linear");
end

function index = requireNodeColumns(nodeNames, header, dataName)
    import Cauer3D.Model.*
    import Cauer3D.UI.*
    import Cauer3D.Nomenclature.*
    import Cauer3D.Plot.*
    import Cauer3D.Export.*
    import Cauer3D.IO.*
    import Cauer3D.Internal.*
    if isempty(nodeNames)
        index = zeros(0, 1);
        return;
    end
    [isFound, index] = ismember(nodeNames, header);
    if any(~isFound)
        missingNames = strjoin(nodeNames(~isFound), ", ");
        error("The test " + dataName + " data is missing nodes: " + missingNames + ".");
    end
end

function simulationTime = createSimulationTime(stopTime, stepSize)
    import Cauer3D.Model.*
    import Cauer3D.UI.*
    import Cauer3D.Nomenclature.*
    import Cauer3D.Plot.*
    import Cauer3D.Export.*
    import Cauer3D.IO.*
    import Cauer3D.Internal.*
    simulationTime = (0:stepSize:stopTime).';
    if simulationTime(end) < stopTime
        simulationTime(end + 1, 1) = stopTime;
    end
end
