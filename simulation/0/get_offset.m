function [state, tibialis_state, state_offset, state_offset_validation, moment_from_foot_weight_validation] = get_offset(data_controller)
    % params:
    %   data_controller
    %       .foot_drop_ankle_angle_data (Nx2)
    %       .foot_drop_knee_angle_data (Nx2)
    %       .foot_drop_hip_angle_data (Nx2)
    %       .foot_drop_ankle_angular_speed_data (Nx2)
    % returns:
    %   state (3xN):
    %   tibialis_state (3xN): 
    %   state_offset (2xN):
    %   state_offset_validation (2xN):
    %   moment_from_foot_weight_validation (1xN):

    % retrieve data from controller
    foot_drop_ankle_angle_data = data_controller.foot_drop_ankle_angle_data;
    foot_drop_knee_angle_data = data_controller.foot_drop_knee_angle_data;
    foot_drop_hip_angle_data = data_controller.foot_drop_hip_angle_data;
    foot_drop_ankle_angular_speed_data = data_controller.foot_drop_ankle_angular_speed_data;
    
    % create return matrices
    state_offset = zeros([2 length(Constants.time_step)]);
    state_offset_validation = zeros([2 length(Constants.time_step)]);
    state = zeros([3 length(Constants.time_step)]);
    tibialis_state = zeros([3 length(Constants.time_step)]);
    moment_from_foot_weight_validation = zeros([1 length(Constants.time_step)]);

    current_state = zeros([3 1]);

    tibialis = TibialisMuscleModel(data_controller);

    for i=1:length(Constants.time_step)
        if i <= Constants.foot_drop_neutral_index 
            state(1:2, i) = [foot_drop_ankle_angle_data(i, 2) foot_drop_ankle_angular_speed_data(i, 2)]';
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

            tibialis_state(:, i) = [tibialis.current_muscle_tendon_length, tibialis.current_normalized_muscle_length, tibialis.current_normalized_tendon_length];
            state(:, i) = current_state;
            moment_from_foot_weight_validation(i) = moment_from_foot_weight;
            
            % calculations for next state not needed for last timestep
            if i == length(Constants.time_step) 
                break
            end
            
            empirical_next_state = [foot_drop_ankle_angle_data(i+1, 2) foot_drop_ankle_angular_speed_data(i+1, 2)]';

            vm_func_as_func_of_a = tibialis.get_vm_func_as_func_of_a();

            get_current_state_derivative = @(a) [current_state(2); (tibialis.get_force()*Constants.tibialis_moment_arm - ...
                moment_from_foot_weight)/Constants.foot_MOI_about_ankle; 
                fzero(vm_func_as_func_of_a(a), 0)];

            current_state_derivative = get_current_state_derivative(Constants.foot_drop_activation);

            state_offset(:,i) = empirical_next_state - current_state(1:2) - Constants.step_size.*current_state_derivative(1:2);
            state_offset_validation(:, i) = current_state(1:2) + Constants.step_size.*current_state_derivative(1:2) + state_offset(:, i) - empirical_next_state;
            current_state(1:2) = current_state(1:2) + Constants.step_size.*(current_state_derivative(1:2)) + state_offset(:, i);
            current_state(3) = current_state(3) + Constants.step_size.*current_state_derivative(3);

        end
    end
        
end
