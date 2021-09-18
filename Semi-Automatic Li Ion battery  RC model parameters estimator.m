%% Lets Obtain parameters!

% Semi-Automatic  Li-Ion battery RC model parameters estimator
% Developed by Federico Ceccarelli for a Li-Ion BMS. In
% collaboration with Martin Moya and Lucio Santos

% Submission are welcome to fededc88@gmail.com

%%
clc;
clear all;
close all;

fprintf('<strong> >> Semi-Automatic  Li-Ion battery RC model parameters estimator << </strong>\n\r');
%% Load dependencies
fprintf('<strong> Load dependencies </strong>\n');

disp('Change Current Folder to active file name location');
cd  (fileparts(matlab.desktop.editor.getActiveFilename));
disp('adding... ./Lib path');
addpath('./Lib');
disp('adding... ./Simulink Models path');
addpath('./Simulink Models');
disp('adding... ./Panasonic-18650PF-Data path');
addpath('./Panasonic-18650PF-Data');
disp('adding... /Lib/Optimizer path');
addpath('./Lib/Optimizer');

%% Load data to workspace from dataset
fprintf('<strong>Load data to workspace from dataset </strong>\n');

% The included tests were performed at the University of Wisconsin-Madison
% by Dr. Phillip Kollmeyer (phillip.kollmeyer@gmail.com).

% Five pulse discharge HPPC test (0.5, 1, 2, 4, 6C) performed at 100, 95,
% 90, 80, 70..., 30, 25, 20, 15, 10, 5, 0 % SOC.
% The logged data file only includes the pulses, and does not include the
% subsequent discharges between the pulses, refer to the amp-hour data to
% determine the SOC for each pulse set. 

disp('loading ... Five pulse discharge HPPC test Data');
load('Panasonic-18650PF-Data/Panasonic 18650PF Data/25degC/5 pulse disch/03-11-17_08.47 25degC_5Pulse_HPPC_Pan18650PF.mat');

% Make BEBUG_PLOT = 1 if you want to see graphics in every subsection
DEBUG_PLOT = 1;

Current = [meas.Time, meas.Current];
Voltage = [meas.Time,meas.Voltage];

% plot the HPPC curve
if DEBUG_PLOT
    figure();
    ax1 = subplot(211);
    plot(meas.Time, meas.Voltage);
    title('25degC 5Pulse HPPC Curve Pan18650PF')
    xlabel('t [s]')
    ylabel('V_{out} [V]');
    ax2 = subplot(212);
    plot(meas.Time, meas.Current);
    xlabel('t [s]');
    ylabel('I [A]');
    linkaxes([ax1, ax2], 'x');
    
    % Clean Workspace
    clear ax1 ax2;
end

%% Determine SOC
fprintf('<strong>Determine SOC </strong>\n');

% From amp-hour data determine the SOC for the entire test time.
min_ah = -1*min(meas.Ah);
SOC = (meas.Ah + min_ah)/min_ah;
SOC_table = [meas.Time,SOC];

% Clean Workspace
clear min_ah;

% Check SOC grapicaly
if DEBUG_PLOT
    figure();
    plot(meas.Time,SOC);
    title( 'SOC ');
    xlabel('t [s]');
    ylabel('SOC');
end

%% Rescue flanks positions on Current Vector
fprintf('<strong>Rescue flanks positions on Current Vector </strong>\n');

Current_flanks = flanks(meas.Current, 50);

% Check Flanks vs Current and Voltage
if DEBUG_PLOT
    figure();
    plot( meas.Time, Current_flanks, meas.Time, meas.Current, meas.Time, meas.Voltage);
    legend( 'flanks','meas.Current','meas.Voltage');
    title( 'Flanks vs meas.Current vs meas.Voltage');
    xlabel('t [s]');
end

%% Rescue OCV values
fprintf('<strong>Rescue OCV values </strong>\n');
% Rescue OCV and indexes position from dataset
disp('Rescuing OCV and indexes position from dataset...');
n=1;
for i = 1 : length(meas.Voltage)
    if(Current_flanks(i) == -1)
        OCV(n,1) = meas.Voltage(i);
    end
    if(Current_flanks(i) == 1)
        OCV(n,2) = i;
        n = n+1;
    end
end

% 
n=1;
for( i = 1 : length(meas.Time) )
    Vocv(i,1) = OCV(n,1);
    if ( i == OCV(n,2))
        if(n<length(OCV(:,1)))
            n = n+1;
        end
    end
end

Vocv_table = [meas.Time,Vocv];

% Clean Workspace
clear i n OCV;


% Check graphically Voltage Vs Vocv
if DEBUG_PLOT
    figure();
    plot(meas.Time, meas.Voltage,Vocv_table(:,1),Vocv_table(:,2));
    legend( 'meas.Voltage','Vocv');
    title( 'Voltage Vs Vocv');
end

%% Rescue SOC values for Look Up table
fprintf('<strong>Rescue SOC values for Look Up table </strong>\n');

n = 1;
for i = 1 : length(SOC)
    if(Current_flanks(i) == 1)
        SOC_lutable(n,1) = SOC(i);
        n = n+1;
    end
end

%% Valid Data periods
fprintf('<strong>Valid Data periods </strong>\n');

indexes = struct('start',0,'end',0);

% Find and saves elemen number where start and end every relaxation Preriode
disp('Finding and saving relaxation start and stop point');
i=1;
for( n = 1 : length(Current_flanks) )

    if(Current_flanks(n) == -1)
            indexes(i).start = n;
            if( i ~= 1)
                indexes(i-1).end = n;
            end
            i = i+1;
    end
end

% Validates Voltage relaxation periods graphically 
if DEBUG_PLOT
    figure();
    delta = 100;
    
    for (i = 1 : 67)
    disp(sprintf('Validates Voltage relaxation period %d graphically ',i));
    plot(meas.Time((indexes(i).start-delta):indexes(i).end),meas.Voltage((indexes(i).start-delta):indexes(i).end))
    title(sprintf('meas.Voltage((indexes(%d).start-%d):indexes(%d).end)', i, delta, i));
   
    disp('Press any key to continue, Ctrl C to end.');
    pause;
    end
end

% Clean Workspace
clear i n delta;

%% Initialize Parameters
 fprintf('<strong>Initialize Parameters</strong>\n');
 
 %Average R0
 disp('Average R0 ... ');
 
% R0 value is obtained averaging the R0(i) calculated from every discharge pulse for each SOC 
% Value should be close to R0 = 0.0256 in our case.
R0 = Average_R0(meas.Current,meas.Voltage)

% Set initial values for R1, C1, R2 & C2
 disp('Set initial values for R1, C1, R2 & C2 ... ');
R1 = [0.0273228292774916]
C1 = [172.286830453445]
R2 = [0.120006294781068]
C2 = [485.470579532194]

%% Iterative Optimizer! 
 fprintf('<strong>Iterative Optimizer!</strong>\n');
 
% Globlasl variables
global Start Stop voltage_buffer time_buffer

for i = 1:length(indexes)-1
    
    % If you want to calculate and approximate parameters from a single discharge pulse uncomment i value:
    %i = 12;
  
    disp(sprintf('Proccesing discharge pulse number %d ...', i));

    % Start Delta
    ds = 100;
    % End Delta
    de = 0;
    
    n_samples = (indexes(i).end+de)-(indexes(i).start-ds) + 1;
    
    index_dsStart = (indexes(i).start-ds);
    index_deStop = (indexes(i).end+de);
    
    % Guardar Tiempos entre rangos 
    time_buffer = meas.Time(index_dsStart:index_deStop);
    % Guarda el Vocv entre rangos
    Vocv_buffer =  Vocv(index_dsStart:index_deStop);
    % Guarda el voltage entre rangos
    voltage_buffer = meas.Voltage(index_dsStart:index_deStop);
    %Guardo la corriente entre rangos
    current_buffer = meas.Current(index_dsStart:index_deStop);
   
    %Generate imputs for simulation
   
    clear Vocv_buffer_table current_buffer_table;
    Vocv_buffer_table(:,1) =  time_buffer;
    Vocv_buffer_table(:,2) = Vocv_buffer;
    current_buffer_table(:,1) = time_buffer;
    current_buffer_table(:,2) = current_buffer;
    
    dStart = meas.Time(index_dsStart);
    dStop = meas.Time(indexes(i).end+de);
    
    Start = sprintf('%d', dStart);
    Stop = sprintf('%d', dStop);
    
%     % DEPRECATED! 

%     % Guarda el Ro*I entre rangos
%     R0xI_buffer = R0*current_buffer;
%  
% 
% %        V'(t)   v(t) - Vocv(SOC) - R0*i(t)
% %   Gs = ---- = ----------------------------
% %        I(t)               i(t)
%     Vprima =  voltage_buffer - Vocv_buffer  - R0xI_buffer;
    
    %plot
    if DEBUG_PLOT
        figure();
        ax1 = subplot(2,1,1)
        plot(time_buffer,current_buffer );
        title(sprintf('time buffer vs current buffer PULSE: %d', i));
        xlabel('time [t]');
        ylabel('current_buffer [I]');
        grid on;
        
        ax2 = subplot(2,1,2)
        plot(time_buffer,voltage_buffer);
        title(sprintf('time buffer vs voltage buffer PULSE: %d', i));
        linkaxes([ax1, ax2], 'x');
        xlabel('time [t]');
        ylabel('voltage_buffer [v]');
        grid on;
        
        % DEPRECATED! 
        % figure();
        % plot(meas.Time((indexes(i).start-ds):(indexes(i).end+de)),voltage_buffer,meas.Time((indexes(i).start-ds):(indexes(i).end+de)),Vprima);
        % grid on;
        
%         figure ();
%         plot(meas.Time(indexes(i).inicio:indexes(i).fin),Vprima,meas.Time(indexes(i).inicio:indexes(i).fin),meas.Voltage(indexes(i).inicio:indexes(i).fin));
    end

    vOpt = Optimization(i)

    % Rescue optimized parameters on lookup table's vectors
    R1 = vOpt(1).Value;
    R1_lutable(i,1) = vOpt(1).Value;
    C1 = vOpt(2).Value;
    C1_lutable(i,1) = vOpt(2).Value;
    R2 = vOpt(3).Value;
    R2_lutable(i,1) = vOpt(3).Value;
    C2 = vOpt(4).Value;
    C2_lutable(i,1) = vOpt(4).Value;
    R0 = vOpt(5).Value;
    R0_lutable(i,1) = vOpt(5).Value;
    
   % pause
end

%% Compare graphicaly the Measured data and Vs Simulated Terminal Voltage Output

% Simulate complete Baterty test with Look Up Table model
sim('Batery_Model');
 
%plot
figure()
plot(meas.Time,meas.Voltage,Vterm_sim.time,Vterm_sim.data);
title('meas.Voltage Vs Vterm simulation');
legend('Measured Terminal Voltage', 'Simulated Terminal Voltage');
xlabel('time [t]');
ylabel('Vterm [v]');


%% Calc Error
%TODO
