%% Foot Weight Moment Validation
clear
clc
close all

time_step = Constants.time_step;
data_controller = DataController();

[foot_drop_moment_from_foot_weight, normal_moment_from_foot_weight] = get_moment_from_foot_weight_validation( ...
    data_controller);

LineWidth = 1.5;

figure()
subplot(2,1,1)
plot(time_step, foot_drop_moment_from_foot_weight, 'LineWidth', LineWidth)
xlabel("% gait")
ylabel("Foot Drop foot weight moment")
title("Validation - Experiment 0 - Foot Drop foot weight moment")

subplot(2,1,2)
plot(time_step, normal_moment_from_foot_weight, 'LineWidth', LineWidth)
xlabel("% gait")
ylabel("Foot Drop foot weight moment")
title("Validation - Experiment 0 - Normal foot weight moment")

