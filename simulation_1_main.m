%% Simulation 1 - Experiment 0 Trapezoid Function
clear
clc
close all

amp = 0.8;
start_on = false;
time_step = Constants.time_step;
rise_fall_time = 0.15*length(time_step);
t_on = 0.6*length(time_step) - rise_fall_time;
t_off = 1*length(time_step) - (rise_fall_time);

tibialis_activation_func = generate_trap_func(amp, start_on, rise_fall_time,t_on,t_off);

data_controller = DataController();
[state, tibialis_state, state_offset, state_offset_validation, moment_from_foot_weight_validation] = get_offset(data_controller);

LineWidth = 1.5;

corrected_state = simulation_1(tibialis_activation_func, data_controller, state_offset);

heel_error = heel_strike_error(corrected_state,data_controller.normal_ankle_angle_data);
swing_error = swing_error(corrected_state,data_controller.normal_ankle_angle_data);
fatigue = activation_fatigue(tibialis_activation_func);

figure()
plot(time_step, tibialis_activation_func, 'LineWidth', LineWidth)
xlabel("% gait")
ylabel("FES Signal")
title("Simulation 1 - FES Signal")

figure()
subplot(3,1,1)
plot(time_step, corrected_state(1, :), 'LineWidth', 3), hold on
plot(time_step, data_controller.foot_drop_ankle_angle_data(:, 2), 'LineWidth', LineWidth), hold on
plot(time_step, data_controller.normal_ankle_angle_data(:, 2), 'LineWidth', LineWidth), hold off
xlabel("% gait")
ylabel("Ankle Angle")
title("Simulation 1 - Ankle Angle")
legend('Modeled Ankle Angle','Foot Drop Ankle Angle from Data','Normal Ankle Angle from Data', 'Location','southwest','FontSize',8)

subplot(3,1,2)
plot(time_step, corrected_state(2, :), 'LineWidth', 3), hold on
plot(time_step, data_controller.foot_drop_ankle_angular_speed_data(:, 2), 'LineWidth', LineWidth), hold on
plot(time_step, data_controller.normal_ankle_angular_speed_data(:, 2), 'LineWidth', LineWidth), hold off
xlabel("% gait")
ylabel("Angular Speed")
title("Simulation 1 - Angular Speed")
legend('Modeled Ankle Anglular Speed','Foot Drop Ankle Angular Speed from Data','Normal Ankle Angular Speed from Data', 'Location','southwest','FontSize',8)

subplot(3,1,3)
plot(time_step, corrected_state(3, :), 'LineWidth', 3), hold on
xlabel("% gait")
ylabel("Normalized Muscle Length")
title("Simulation 1 - Normalized Muscle Length")
legend('Modeled Normalized Muscle Length Speed', 'Location','southwest','FontSize',8)

%% Simulation 1 - Experiment 1 Pulse Train Function
clear
clc
close all

time_step = Constants.time_step;

amp = 0.6;          % VARY
frequency = 6;      % 
duty_cycle = 70;    % THESE
start_offset = 50;  % PARAMETERS
H=zeros(10,1)
for kar =1:10
    amp=kar/10.0
    tibialis_activation_func = generate_pulse_func(amp, frequency, duty_cycle, start_offset);
    
    data_controller = DataController();
    [state, tibialis_state, state_offset, state_offset_validation, moment_from_foot_weight_validation] = get_offset(data_controller);
    
    LineWidth = 1.5;
    
    corrected_state = simulation_1(tibialis_activation_func, data_controller, state_offset);
    
    heel_error = heel_strike_error(corrected_state, data_controller.normal_ankle_angle_data);
    %swing_error = swing_error(corrected_state, data_controller.normal_ankle_angle_data);
    fatigue = activation_fatigue(tibialis_activation_func);
    if (heel_error<=25)
        H(kar)=amp
    end
    fprintf('%.2f,' , [heel_error amp fatigue])
end

disp(H)
amp = 0.6;          % VARY
frequency = 6;      % 
duty_cycle = 70;    % THESE
start_offset = 50;  % PARAMETERS
I=zeros(10,1)
for kar =1:10
    frequency=kar
    tibialis_activation_func = generate_pulse_func(amp, frequency, duty_cycle, start_offset);
    
    data_controller = DataController();
    [state, tibialis_state, state_offset, state_offset_validation, moment_from_foot_weight_validation] = get_offset(data_controller);
    
    LineWidth = 1.5;
    
    corrected_state = simulation_1(tibialis_activation_func, data_controller, state_offset);
    
    heel_error = heel_strike_error(corrected_state, data_controller.normal_ankle_angle_data);
    %swing_error = swing_error(corrected_state, data_controller.normal_ankle_angle_data);
    fatigue = activation_fatigue(tibialis_activation_func);
    if (heel_error<=25)
        I(kar)=frequency
    end
    fprintf('%.2f,' , [heel_error frequency fatigue])
end
disp(I)

amp = 0.6;          % VARY
frequency = 6;      % 
duty_cycle = 70;    % THESE
start_offset = 50;  % PARAMETERS

J=zeros(10,1)
for kar =1:10
    duty_cycle=kar*10
    tibialis_activation_func = generate_pulse_func(amp, frequency, duty_cycle, start_offset);
    
    data_controller = DataController();
    [state, tibialis_state, state_offset, state_offset_validation, moment_from_foot_weight_validation] = get_offset(data_controller);
    
    LineWidth = 1.5;
    
    corrected_state = simulation_1(tibialis_activation_func, data_controller, state_offset);
    
    heel_error = heel_strike_error(corrected_state, data_controller.normal_ankle_angle_data);
    %swing_error = swing_error(corrected_state, data_controller.normal_ankle_angle_data);
    fatigue = activation_fatigue(tibialis_activation_func);
    if (heel_error<=25)
        J(kar)=duty_cycle
    end
    fprintf('%.2f,' , [heel_error duty_cycle fatigue])
end
disp(J)

%found errors are similar upon graphing manually; made weighted eq. based
%on lit; however dont have to optimize for correct angle, just gotta get
%foot of the floor without tiring them out so they can continue to be
%active and walk; therefore considered all params that allowed error to be
%under 5 threshold so foot has enough clearance; saved those params and ran
%them simultaneously in nested loop to optimize for lowest fatigue.
%justified bc unlike sim 1, this is harder to eyeball bw tradeoffs thru
%manual graphing of param combos; what we did earlier didn't consider
%fatigue, just optimized for angle which doesn't meet both goals
Hnew=nonzeros(H)
Inew=nonzeros(I)
Jnew=nonzeros(J)

fnew=1000
ans=zeros(5,1)
for ctr1=1:length(Hnew)
    for ctr2=1:length(Inew)
        for ctr3=1:length(Jnew)
            amp = Hnew(ctr1);          % VARY
            frequency = Inew(ctr2);      % 
            duty_cycle = Jnew(ctr3);    % THESE
            start_offset = 50;  % PARAMETERS

            tibialis_activation_func = generate_pulse_func(amp, frequency, duty_cycle, start_offset);
    
            data_controller = DataController();
            [state, tibialis_state, state_offset, state_offset_validation, moment_from_foot_weight_validation] = get_offset(data_controller);
            
            LineWidth = 1.5;
            
            corrected_state = simulation_1(tibialis_activation_func, data_controller, state_offset);
            
            heel_error = heel_strike_error(corrected_state, data_controller.normal_ankle_angle_data);
            %swing_error = swing_error(corrected_state, data_controller.normal_ankle_angle_data);
            fatigue = activation_fatigue(tibialis_activation_func);
            if ((fatigue<fnew) && (heel_error<=25))
                fnew=fatigue
                ans(1)=fatigue;
                ans(2)=amp;
                ans(3)=frequency;
                ans(4)=duty_cycle;
                ans(5)=heel_error
                disp(ans)
            end
        end
    end
end
disp(ans)
disp("HERE")

%%%

%% Simulation 1 Reform - Experiment 1 Pulse Train Function
clear
clc
close all

time_step = Constants.time_step;
amp = 0.5;          % VARY
frequency = 3;      % 
duty_cycle = 40;    % THESE
start_offset = 50;  % PARAMETERS

tibialis_activation_func = generate_pulse_func(amp, frequency, duty_cycle, start_offset);
    
data_controller = DataController();
[state, tibialis_state, state_offset, state_offset_validation, moment_from_foot_weight_validation] = get_offset(data_controller);
    
LineWidth = 1.5;
    
corrected_state = simulation_1(tibialis_activation_func, data_controller, state_offset);
    
heel_error = heel_strike_error(corrected_state, data_controller.normal_ankle_angle_data);
    %swing_error = swing_error(corrected_state, data_controller.normal_ankle_angle_data);
fatigue = activation_fatigue(tibialis_activation_func);
    
fprintf('%.2f,' , [heel_error amp fatigue])


figure()
plot(time_step, tibialis_activation_func, 'LineWidth', LineWidth)
xlabel("% gait")
ylabel("FES Signal")
title("Simulation 2 - FES Signal")

figure()
subplot(3,1,1)
plot(time_step, corrected_state(1, :), 'LineWidth', 3), hold on
plot(time_step, data_controller.foot_drop_ankle_angle_data(:, 2), 'LineWidth', LineWidth), hold on
plot(time_step, data_controller.normal_ankle_angle_data(:, 2), 'LineWidth', LineWidth), hold off
xlabel("% gait")
ylabel("Ankle Angle")
title("Simulation 2 - Ankle Angle")
legend('Modeled Ankle Angle','Foot Drop Ankle Angle from Data','Normal Ankle Angle from Data', 'Location','southwest','FontSize',8)

subplot(3,1,2)
plot(time_step, corrected_state(2, :), 'LineWidth', 3), hold on
plot(time_step, data_controller.foot_drop_ankle_angular_speed_data(:, 2), 'LineWidth', LineWidth), hold on
plot(time_step, data_controller.normal_ankle_angular_speed_data(:, 2), 'LineWidth', LineWidth), hold off
xlabel("% gait")
ylabel("Angular Speed")
title("Simulation 2 - Angular Speed")
legend('Modeled Ankle Anglular Speed','Foot Drop Ankle Angular Speed from Data','Normal Ankle Angular Speed from Data', 'Location','southwest','FontSize',8)

subplot(3,1,3)
plot(time_step, corrected_state(3, :), 'LineWidth', 3), hold on
xlabel("% gait")
ylabel("Normalized Muscle Length")
title("Simulation 2 - Normalized Muscle Length")
legend('Modeled Normalized Muscle Length Speed', 'Location','southwest','FontSize',8)
