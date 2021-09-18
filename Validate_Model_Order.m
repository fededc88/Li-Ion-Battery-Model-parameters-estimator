%% Load dependencies

disp('Change Current Folder to active file name location');
cd  (fileparts(matlab.desktop.editor.getActiveFilename));

disp('adding... ./Lib path');
addpath('./Lib');

%% Load data to workspace from dataset

% The included tests were performed at the University of Wisconsin-Madison
% by Dr. Phillip Kollmeyer (phillip.kollmeyer@gmail.com).

% Five pulse discharge HPPC test (0.5, 1, 2, 4, 6C) performed at 100, 95,
% 90, 80, 70..., 30, 25, 20, 15, 10, 5, 0 % SOC.
% The logged data file only includes the pulses, and does not include the
% subsequent discharges between the pulses, refer to the amp-hour data to
% determine the SOC for each pulse set. 

disp('loading ... Five pulse discharge HPPC test Data');
load('Panasonic-18650PF-Data/Panasonic 18650PF Data/25degC/5 pulse disch/03-11-17_08.47 25degC_5Pulse_HPPC_Pan18650PF.mat');

Current = [ meas.Time, meas.Current];
Voltage = meas.Voltage;
Time = meas.Time;

%% Rescue flanks positions

% Rescato las posiciones del vector Current donde hay flancos.
flancos = flanks(meas.Current, 50);

i = 1;
for( n = 1 : length(flancos) )

    if(flancos(n) == 1)
        index(i).s = n; %index(i).Start
    end
    
    if (flancos(n) == - 1)
        index(i).e = n; %index(i).End
        i = i+1;
    end
    
end


%% Selecting the Number of R-C Branches

% Tomo el n semiperiodo de relajaci�n para ajustar una curva
% polinomial y decidir que orden utilizar.
n = 10;
sample_v = Voltage(index(n).s : index(n).e);
sample_time = Time (index(n).s : index(n).e);
plot(sample_time,sample_v)

% Fit: 'Eq_RC_Circuit'.
[xData, yData] = prepareCurveData( sample_time, sample_v );

% Set up fittype and options.
% exp1 => Y = a*exp(b*x)
ft1 = fittype( 'exp1' );
opts1 = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts1.Display = 'Off';
opts1.Normalize = 'on';
opts1.StartPoint = [-0.00080023 -3.5629];

% Fit model to data.
[fitresult1, gof] = fit( xData, yData, ft1, opts1 );

% Set up fittype and options.
% exp2 => Y = a*exp(b*x)+c*exp(d*x)
ft = fittype( 'exp2' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Normalize = 'on';
opts.StartPoint = [4.0866 -1.1738e-05 -0.00080023 -3.5629];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit vs data and conclude.
figure( 'Name', 'exp orden 2' );
title('Curve fit to determine number of R-C model branches')
h = plot( fitresult, xData, yData, 'b.');
hold on;
hg = plot( fitresult1, 'c--' );
legend( [h;hg], 'experimental data', 'exp2 aproximation', 'exp1 aproximation', 'Location', 'NorthEast' );
xlabel ('time [s]');
ylabel ('Voltage [v]');
grid on

%%

