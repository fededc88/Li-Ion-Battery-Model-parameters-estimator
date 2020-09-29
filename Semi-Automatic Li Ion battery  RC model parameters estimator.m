

%% Let Obtain parameters!

% Semi-Automatic  Li-Ion battery RC model parameters estimator

% Developed by Federico Ceccarelli for a Li-Ion BMS. In
% collaboration with Matin Moya and Lucio Santos

% Submission are welcome to fededc88@gmail.com 

%% Load data to workspace from dataset

% The included tests were performed at the University of Wisconsin-Madison
% by Dr. Phillip Kollmeyer (phillip.kollmeyer@gmail.com).

% Five pulse discharge HPPC test (0.5, 1, 2, 4, 6C) performed at 100, 95,
% 90, 80, 70..., 30, 25, 20, 15, 10, 5, 0 % SOC.
% The logged data file only includes the pulses, and does not include the
% subsequent discharges between the pulses, refer to the amp-hour data to
% determine the SOC for each pulse set. 

disp('loading ... Five pulse discharge HPPC test Data');
load('../dataset_18650pf/25degC/5 pulse disch/03-11-17_08.47 25degC_5Pulse_HPPC_Pan18650PF.mat');

% Make BEBUG_PLOT = 1 if you want to see graphics in every subsection
DEBUG_PLOT = 0;

Current = [meas.Time, meas.Current];
Voltage = [meas.Time,meas.Voltage];

%% Determine SOC

% From amp-hour data determine the SOC for the entire test time.

min_ah = -1*min(meas.Ah);
SOC = (meas.Ah + min_ah)/min_ah;
SOC_table = [meas.Time,SOC];

% Clean Workspace
clear min_ah;

% Check SOC grapicaly
if DEBUG_PLOT
    plot(meas.Time,SOC);
    title( 'SOC ');
end

%% Rescue flanks positions on Current Vector

Current_flanks = flanks(meas.Current, 50);

% Check Flanks vs Current and Voltage
if DEBUG_PLOT
    plot( meas.Time, Current_flanks, meas.Time, meas.Current, meas.Time, meas.Voltage);
    legend( 'flanks','meas.Current','meas.Voltage');
    title( 'Flanks vs meas.Current vs meas.Voltage');
end

%% Rescue OCV values

% Rescue OCV and indexes position from dataset 
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
    plot(meas.Time, meas.Voltage,Vocv_table(:,1),Vocv_table(:,2));
    legend( 'meas.Voltage','Vocv');
    title( 'Voltage Vs Vocv');
end

%% %% Rescue SOC values for Look Up table
n = 1;
for i = 1 : length(SOC)
%     if(Current_flanks(i) == -1)
%         SOC_lutable(n,1) = SOC(i);
%         n = n+1;
%     end
    if(Current_flanks(i) == 1)
        SOC_lutable(n,1) = SOC(i);
        n = n+1;
    end
end

%% Valid Data periods

indexes = struct('start',0,'end',0);

%Rescato el numero de muestras donde inician y terminan los periodos de
%relajación

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



% Check graphically Voltage valid data periods
if DEBUG_PLOT
    for (i = 1 : 67)
i= 10;
    delta = 100;
    figure(i)
    plot(meas.Time((indexes(i).start-delta):indexes(i).end),meas.Voltage((indexes(i).start-delta):indexes(i).end))
    str = sprintf('meas.Voltage((indexes(%d).start-%d):indexes(%d).end)', i, delta, i)
    title( str );

    pause;

    end
end

% Clean Workspace
clear i n delta str;

 %% Initialize Parameters
 
 %Average R0
 disp('Average R0 ... ')
% Valor de R0 Obtenido a partir de promediar todos los R0(i) de cada pulso
% de descarga en todos los SOC
% Da muy cercana al valor ajustado por lucho, R0 = 0.0256
R0 = Average_R0(meas.Current,meas.Voltage);

R1 = [0.0273228292774916];
C1 = [172.286830453445];
R2 = [0.120006294781068];
C2 = [485.470579532194];






%% Iterative Optimization! 


for i = 1:length(indexes)-1
    
    %Para una sola muestra, debe estar comentado
%     i = 67;
    i= 15;
    str = sprintf('procesando ensayo numero %d ...', i);
    disp(str);

    % Delta Start
    ds = 100;
    % Delta end
    de = 0;
    
    n_samples = (indexes(i).end+de)-(indexes(i).start-ds) + 1;
    
    % Guardar Tiempos entre rangos 
    time_buffer = meas.Time((indexes(i).start-ds):(indexes(i).end+de));
    % Guarda el Vocv entre rangos
    Vocv_buffer =  Vocv((indexes(i).start-ds):(indexes(i).end+de));
    % Guarda el voltage entre rangos
    voltage_buffer = meas.Voltage((indexes(i).start-ds):(indexes(i).end+de));
    %Guardo la corriente entre rangos
    current_buffer = meas.Current((indexes(i).start-ds):(indexes(i).end+de));
   
    %Generate imputs for simulation
   
    clear Vocv_buffer_table current_buffer_table;
    Vocv_buffer_table(:,1) =  time_buffer;
    Vocv_buffer_table(:,2) = Vocv_buffer;
    current_buffer_table(:,1) = time_buffer;
    current_buffer_table(:,2) = current_buffer;
    
    Start = sprintf('%d',  meas.Time(indexes(i).start-ds));
    Stop = sprintf('%d',  meas.Time(indexes(i).end+de));
    
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
        figure(1)
        subplot(2,1,1)
        plot(meas.Time((indexes(i).start-ds):(indexes(i).end+de)),current_buffer );
        subplot(2,1,2)
        plot(meas.Time((indexes(i).start-ds):(indexes(i).end+de)),voltage_buffer);
        grid on;
        
        figure(2)
        plot(meas.Time((indexes(i).start-ds):(indexes(i).end+de)),voltage_buffer,meas.Time((indexes(i).start-ds):(indexes(i).end+de)),Vprima);
        grid on;
        
%         figure (3)
%         plot(meas.Time(indexes(i).inicio:indexes(i).fin),Vprima,meas.Time(indexes(i).inicio:indexes(i).fin),meas.Voltage(indexes(i).inicio:indexes(i).fin));
    end

    vOpt = Optimization()

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
