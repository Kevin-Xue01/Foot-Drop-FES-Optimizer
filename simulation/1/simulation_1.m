function corrected_state = simulation_1(tibialis_activation_func, data_controller, state_offset)
    
    foot_drop_ankle_angle_data = data_controller.foot_drop_ankle_angle_data;
    foot_drop_ankle_angular_speed_data = data_controller.foot_drop_ankle_angular_speed_data;
    foot_drop_knee_angle_data = data_controller.foot_drop_knee_angle_data;
    foot_drop_hip_angle_data = data_controller.foot_drop_hip_angle_data;
    %foot_drop_norm_muscle_length_data = data_controller.foot_drop_norm_muscle_length_data;
    tibialis = TibialisMuscleModel(data_controller);

    tibialis_state = zeros([3 length(Constants.time_step)]);
    current_state = zeros([3 1]);
   
    corrected_state = zeros([3 length(Constants.time_step)]);    
        
    for i=1:length(Constants.time_step)
        if i <= Constants.foot_drop_neutral_index
            corrected_state(1:2, i) = [foot_drop_ankle_angle_data(i, 2) foot_drop_ankle_angular_speed_data(i, 2)]';
        else
            if i == Constants.foot_drop_neutral_index + 1
                tibialis = tibialis.update_state(foot_drop_ankle_angle_data(i, 2), 1);
                current_state = [foot_drop_ankle_angle_data(i, 2) foot_drop_ankle_angular_speed_data(i, 2) tibialis.current_normalized_muscle_length]';
            else
                tibialis = tibialis.update_state(current_state(1), current_state(3));
            end

            if i <= Constants.foot_drop_toe_off_point_index
                moment_from_foot_weight = 0;
            else
                moment_from_foot_weight = get_moment_from_foot_weight(foot_drop_hip_angle_data(i, 2), foot_drop_knee_angle_data(i, 2), ...
                    current_state(1));
            end
            
            % output states
            tibialis_state(:, i) = [tibialis.current_muscle_tendon_length, tibialis.current_normalized_muscle_length, tibialis.current_normalized_tendon_length];
            corrected_state(:, i) = current_state;
            
            if i == length(Constants.time_step)
                break
            end

            vm_func_as_func_of_a = tibialis.get_vm_func_as_func_of_a();

            get_current_state_derivative = @(a) [current_state(2); (tibialis.get_force()*Constants.tibialis_moment_arm - ...
                moment_from_foot_weight)/Constants.foot_MOI_about_ankle; 
                fzero(vm_func_as_func_of_a(a), 0)];
            
            % input activation a, into state space
            current_state_derivative = get_current_state_derivative(tibialis_activation_func(i));
           
            % update state
            current_state(1:2) = current_state(1:2) + Constants.step_size.*(current_state_derivative(1:2)) + state_offset(:, i);
            current_state(3) = current_state(3) + Constants.step_size.*current_state_derivative(3);

        end
    end    
end