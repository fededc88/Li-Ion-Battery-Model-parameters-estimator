
function vOpt = Optimization()

% Create an experiment object to store the measured input/output data.
Exp = sdo.Experiment('SingleSOC_Batery_Model');

global voltage_buffer time_buffer Start Stop i

% Create an object to store the measured Terminal Voltage output.
TerminalV = Simulink.SimulationData.Signal;
TerminalV.Name      = 'TerminalV';
TerminalV.BlockPath = 'SingleSOC_Batery_Model/PS-Simulink Converter';
TerminalV.PortType  = 'outport';
TerminalV.PortIndex = 1;
TerminalV.Values    = timeseries(voltage_buffer,time_buffer);

%Add the measured terminal Voltahe data to the experiment as the expected output data.

Exp.OutputData = [ TerminalV ];

% Add the initial state for the Model blocks to the experiment. Set its Free field to true so that it is estimated.
% Check!
% Exp.InitialStates = sdo.getStateFromModel('SingleSOC_Batery_Model','R1');
% Exp.InitialStates.Minimum = 0;
% Exp.InitialStates.Free    = true;

%Create a simulation scenario using the experiment and obtain the simulated output.
Simulator    = createSimulator(Exp);
Simulator    = sim(Simulator, 'StartTime', Start, 'StopTime', Stop );

% Search for the Terminal Voltage signal in the logged simulation data.
SimLog       = find(Simulator.LoggedData,get_param('SingleSOC_Batery_Model','SignalLoggingName'));
TerminalVSignal = find(SimLog,'TerminalV');

figure
subplot(2,1,1);
plot(time_buffer, voltage_buffer, TerminalVSignal.Values.Time,TerminalVSignal.Values.Data);
str = sprintf('Simulated Response Vs Measured Response (Before Optimization) PULSE: %d', double(i));
title(str);
legend('Measured Terminal Voltage', 'Simulated Terminal Voltage');
xlabel('time [t]');
ylabel('Vterm [v]');

% Specify the Parameters to Estimate

p = sdo.getParameterFromModel('SingleSOC_Batery_Model',{'R1','C1','R2', 'C2', 'R0'});
p(1).Minimum = 0;   %R1
p(1).Maximum = 1;
p(2).Minimum = 0;   %C1
p(2).Maximum = 200;
p(3).Minimum = 0;   %R2
p(3).Maximum = 1;
p(4).Minimum = 0;   %C2
p(4).Maximum = 3000;
p(5).Minimum = 0;   %R0
p(5).Maximum = 1;   

% Get the actuator initial state value that is to be estimated from the experiment.
s = getValuesToEstimate(Exp);

% Group the model parameters and initial states to be estimated together.
v = [p;s]

% Define the Estimation Objective Function
estFcn = @(v) sdoVtermEstimation_Objective(v,Simulator,Exp);

%% Estimate the Parameters
% Use the sdo.optimize function to estimate the actuator parameter values and initial state.

opt = sdo.OptimizeOptions;
opt.Method = 'lsqnonlin';

vOpt = sdo.optimize(estFcn,v,opt)

%% Compare the Measured Output and the Final Simulated Output

%Update the experiments with the estimated parameter values.
Exp = setEstimatedValues(Exp,vOpt);

Simulator    = createSimulator(Exp,Simulator);
Simulator    = sim(Simulator,'StartTime', Start, 'StopTime', Stop);

% Search for the Terminal Voltage signal in the logged simulation data.
SimLog    = find(Simulator.LoggedData,get_param('SingleSOC_Batery_Model','SignalLoggingName'));
TerminalV = find(SimLog,'TerminalV');

subplot(2,1,2);
plot(time_buffer, voltage_buffer, TerminalV.Values.Time,TerminalV.Values.Data);
str = sprintf('Simulated Response Vs Measured Response (After Optimization) PULSE: %d', i);
title(str);
legend('Measured Terminal Voltage', 'Simulated Terminal Voltage');
xlabel('time [t]');
ylabel('Vterm [v]');

end


