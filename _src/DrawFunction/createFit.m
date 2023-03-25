function [fitresult, gof] = createFit(t, Tt)
%CREATEFIT1(T,TT)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : t
%      Y Output: Tt
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  另请参阅 FIT, CFIT, SFIT.

%  由 MATLAB 于 24-Sep-2022 21:56:25 自动生成


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( t, Tt );

% Set up fittype and options.
ft = 'linearinterp';%'nearestinterp';

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, 'Normalize', 'on' );

% Plot fit with data.
% figure( 'Name', 'untitled fit 1' );
% h = plot( fitresult, xData, yData );
% legend( h, 'Tt vs. t', 'untitled fit 1', 'Location', 'NorthEast', 'Interpreter', 'none' );
% % Label axes
% xlabel( 't', 'Interpreter', 'none' );
% ylabel( 'Tt', 'Interpreter', 'none' );
% grid on


