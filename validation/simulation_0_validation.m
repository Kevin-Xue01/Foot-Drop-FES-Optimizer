function [foot_drop_moment_from_foot_weight, normal_moment_from_foot_weight] = simulation_0_validation(data_controller, x2_dot_offset, x3_dot_offset)
    time_step = Constants.time_step;
    
    foot_drop_ankle_angle_data = data_controller.foot_drop_ankle_angle_data;
    foot_drop_knee_angle_data = data_controller.foot_drop_knee_angle_data;
    foot_drop_hip_angle_data = data_controller.foot_drop_hip_angle_data;
    
    normal_ankle_angle_data = data_controller.normal_ankle_angle_data;
    normal_knee_angle_data = data_controller.normal_knee_angle_data;
    normal_hip_angle_data = data_controller.normal_hip_angle_data;

    foot_drop_moment_from_foot_weight = zeros([length(time_step) 1]);
    normal_moment_from_foot_weight = zeros([length(time_step) 1]);

    for i=1:length(time_step)
        foot_drop_moment_from_foot_weight(i) = get_moment_from_foot_weight(foot_drop_hip_angle_data(i, 2), foot_drop_knee_angle_data(i, 2), ...
            foot_drop_ankle_angle_data(i, 2));

        normal_moment_from_foot_weight(i) = get_moment_from_foot_weight(normal_hip_angle_data(i, 2), normal_knee_angle_data(i, 2), ...
            normal_ankle_angle_data(i, 2));
    end    
end