%% Simulation 0 - Experiment 1.0 - Offset
clear
clc
close all

time_step = Constants.time_step;
data_controller = DataController();
[state, tibialis_state, state_offset, state_offset_validation, moment_from_foot_weight_validation] = get_offset(data_controller);

LineWidth = 1.5;

% Plotting State Offset
figure()
subplot(2,1,1)
plot(time_step, state_offset(1, :), 'LineWidth', LineWidth)
xlabel("% gait")
ylabel("x_1 offset")
title("Simulation 0 - Experiment 1 - x_1 offset")

subplot(2,1,2)
plot(time_step, state_offset(2, :), 'LineWidth', LineWidth)
xlabel("% gait")
ylabel("x2 offset")
% title("Simulation 0 - Experiment 1 - x2 offset")

% Plotting State
figure()
subplot(3,1,1)
plot(time_step, state(1, :), 'LineWidth', 3, 'Color', 'r'), hold on
plot(time_step, data_controller.foot_drop_ankle_angle_data(:, 2), 'LineWidth', LineWidth, 'Color', 'b'), hold off
xlabel("% gait")
ylabel("x_1")
title("Ankle Angle Offset")
legend('Modeled Foot Drop Ankle Angle','Ankle Angle from Data', 'Location','southwest')

subplot(3,1,2)
plot(time_step, state(2, :), 'LineWidth', 3, 'Color', 'r'), hold on
plot(time_step, data_controller.foot_drop_ankle_angular_speed_data(:, 2), 'LineWidth', LineWidth, 'Color', 'b'), hold off
xlabel("% gait")
ylabel("x_2")
% title("Simulation 0 - Experiment 1 - Ankle Angular Speed")
legend('Modeled Ankle Angular Speed','Ankle Angular Speed from Data', 'Location','southwest')

subplot(3,1,3)
plot(time_step, state(3, :), 'LineWidth', LineWidth, 'Color', 'r'), hold on
xlabel("% gait")
ylabel("x_3 - Normalized Muscle Length")
title("Simulation 0 - Experiment 1 - Modeled Normalized Muscle Length")

% Plotting Tibialis State
figure()
subplot(3,1,1)
plot(time_step, tibialis_state(1, :), 'LineWidth', LineWidth, 'Color', 'r')
xlabel("% gait")
ylabel("Muscle Tendon Length")
title("Simulation 0 - Experiment 1 - Muscle Tendon Length")

subplot(3,1,2)
plot(time_step, tibialis_state(2, :), 'LineWidth', LineWidth, 'Color', 'r')
xlabel("% gait")
ylabel("Normalized Muscle Length")
title("Simulation 0 - Experiment 1 - Normalized Muscle Length")

subplot(3,1,3)
plot(time_step, tibialis_state(3, :), 'LineWidth', LineWidth, 'Color', 'r')
xlabel("% gait")
ylabel("Normalized Tendon Length")
title("Simulation 0 - Experiment 1 - Normalized Tendon Length")

% Validating State Offset
figure()
subplot(2,1,1)
plot(time_step, state_offset_validation(1, :), 'LineWidth', LineWidth)
xlabel("% gait")
ylabel("x1 dot offset")
title("Simulation 0 - Experiment 1 - x1 dot offset validation")

subplot(2,1,2)
plot(time_step, state_offset_validation(2, :), 'LineWidth', LineWidth)
xlabel("% gait")
ylabel("x2 dot offset")
title("Simulation 0 - Experiment 1 - x2 dot offset validation")

% Validating Moment from Foot Weight
figure()
plot(time_step, moment_from_foot_weight_validation, 'LineWidth', LineWidth)
xlabel("% gait")
ylabel("Moment from Foot Weight")
title("Simulation 0 - Experiment 1 - Moment from Foot Weight validation")
