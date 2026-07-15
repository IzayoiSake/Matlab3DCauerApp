function Cr = MatlabOperation(Exp_T, R, P, Ptime, T, Ttime, StepSize)
    import Cauer3D.Model.*
    import Cauer3D.UI.*
    import Cauer3D.Nomenclature.*
    import Cauer3D.Plot.*
    import Cauer3D.Export.*
    import Cauer3D.IO.*
    import Cauer3D.Internal.*
% MatlabOperation Identify one thermal capacitance without Simulink.

    [Exp_T, R, P, Ptime, T, Ttime] = normalizeInputs(Exp_T, R, P, Ptime, T, Ttime);
    validateInputs(Exp_T, R, P, Ptime, T, Ttime, StepSize);

    conductance = 1./R;
    totalConductance = sum(conductance);
    stopTime = min(Ttime(end), Ptime(end));
    sampleMask = Ttime >= 0 & Ttime <= stopTime;
    measurementTime = Ttime(sampleMask);
    measuredTemperature = Exp_T(sampleMask);
    initialTemperature = Exp_T(1);

    simulationTime = createSimulationTime(stopTime, StepSize);
    powerOnGrid = interp1(Ptime, P, simulationTime, "linear");
    if isempty(R)
        heatFlow = powerOnGrid;
    else
        linkedTemperature = interp1(Ttime, T, simulationTime, "linear");
        heatFlow = powerOnGrid + linkedTemperature*conductance;
    end

    objective = @(capacitance) trackingError(capacitance, totalConductance, ...
        heatFlow, simulationTime, measurementTime, measuredTemperature, initialTemperature);
    options = optimoptions("patternsearch", "Display", "off");
    Cr = patternsearch(objective, 1, [], [], [], [], eps, Inf, [], options);
end

function [Exp_T, R, P, Ptime, T, Ttime] = normalizeInputs(Exp_T, R, P, Ptime, T, Ttime)
    import Cauer3D.Model.*
    import Cauer3D.UI.*
    import Cauer3D.Nomenclature.*
    import Cauer3D.Plot.*
    import Cauer3D.Export.*
    import Cauer3D.IO.*
    import Cauer3D.Internal.*
    Exp_T = double(Exp_T(:));
    R = double(R(:));
    P = double(P(:));
    Ptime = double(Ptime(:));
    T = double(T);
    Ttime = double(Ttime(:));

    if isvector(T) && isscalar(R)
        T = T(:);
    end
end

function validateInputs(Exp_T, R, P, Ptime, T, Ttime, StepSize)
    import Cauer3D.Model.*
    import Cauer3D.UI.*
    import Cauer3D.Nomenclature.*
    import Cauer3D.Plot.*
    import Cauer3D.Export.*
    import Cauer3D.IO.*
    import Cauer3D.Internal.*
    if ~isscalar(StepSize) || ~isfinite(StepSize) || StepSize <= 0
        error("The identification step size must be a positive finite scalar.");
    end
    if numel(Exp_T) ~= numel(Ttime) || size(T, 1) ~= numel(Ttime)
        error("Temperature data and its time vector must have matching row counts.");
    end
    if numel(P) ~= numel(Ptime)
        error("Power data and its time vector must have matching row counts.");
    end
    if size(T, 2) ~= numel(R)
        error("Each linked-node temperature signal must have one corresponding resistance.");
    end
    if any(~isfinite([Exp_T; P; Ptime; Ttime; T(:)]))
        error("Temperature, power, or time data contains NaN or Inf.");
    end
    if any(~isfinite(R)) || any(R <= 0)
        error("Every active thermal resistance must be finite and positive.");
    end
    if any(diff(Ptime) <= 0) || any(diff(Ttime) <= 0)
        error("Power and temperature time vectors must be strictly increasing.");
    end
    if Ptime(1) > 0 || Ttime(1) > 0
        error("Power and temperature data must begin at or before simulation time zero.");
    end
    if min(Ttime(end), Ptime(end)) <= 0
        error("Identification data must extend beyond simulation time zero.");
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

function errorValue = trackingError(capacitance, totalConductance, heatFlow, ...
        simulationTime, measurementTime, measuredTemperature, initialTemperature)
            import Cauer3D.Model.*
    import Cauer3D.UI.*
    import Cauer3D.Nomenclature.*
    import Cauer3D.Plot.*
    import Cauer3D.Export.*
    import Cauer3D.IO.*
    import Cauer3D.Internal.*
    simulatedTemperature = zeros(size(simulationTime));
    simulatedTemperature(1) = initialTemperature;

    for k = 1:(numel(simulationTime) - 1)
        step = simulationTime(k + 1) - simulationTime(k);
        numerator = (1 - step*totalConductance/(2*capacitance))*simulatedTemperature(k) + ...
            step*(heatFlow(k) + heatFlow(k + 1))/(2*capacitance);
        denominator = 1 + step*totalConductance/(2*capacitance);
        simulatedTemperature(k + 1) = numerator/denominator;
    end

    temperatureAtMeasurements = interp1(simulationTime, simulatedTemperature, ...
        measurementTime, "linear");
    residual = temperatureAtMeasurements - measuredTemperature;
    errorValue = mean(residual.^2);

    if ~isfinite(errorValue)
        errorValue = realmax;
    end
end
