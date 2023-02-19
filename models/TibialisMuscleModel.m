 classdef TibialisMuscleModel
    properties
        resting_muscle_length
        resting_tendon_length
        resting_muscle_tendon_length

        
        current_muscle_length
        current_tendon_length
        current_muscle_tendon_length

        current_normalized_muscle_length
        current_normalized_tendon_length

        
        data_controller
        f0M = Constants.tibialis_f0M
        damping_coeff = Constants.damping_coeff
        
    end
    
    methods
        
        function obj = TibialisMuscleModel(data_controller)
            obj.data_controller = data_controller;
            obj.resting_muscle_tendon_length = obj.get_muscle_tendon_length(Constants.ankle_angle_rest);

            obj.resting_muscle_length = Constants.muscle_length_percent_at_rest * obj.resting_muscle_tendon_length;
            obj.resting_tendon_length = Constants.tendon_length_percent_at_rest * obj.resting_muscle_tendon_length;
        end

        %% Dynamics Equations
        function muscle_tension = get_force(obj)
            muscle_tension = obj.f0M * force_length_tendon(obj.current_normalized_tendon_length);
        end

        function force_as_func_of_a_and_vm = get_force_as_func_of_a_and_vm(obj)
            % 
%             force_as_func_of_a_and_vm = @(a, vm) (obj.f0M*(a*force_length_muscle(obj.data_controller, ...
%              obj.current_normalized_muscle_length)*force_velocity_muscle(obj.data_controller, vm) + ...
%              force_length_parallel(obj.current_normalized_muscle_length) ...
%             + obj.damping_coeff*vm)*cosd(polyval(obj.data_controller.activation_vs_penn_angle_regression, a)));
            force_as_func_of_a_and_vm = @(a, vm) (obj.f0M*(a*force_length_muscle(obj.data_controller, ...
                 obj.current_normalized_muscle_length)*force_velocity_muscle(obj.data_controller, vm) + ...
                 force_length_parallel(obj.current_normalized_muscle_length) ...
                + obj.damping_coeff*vm)*cosd(polyval(obj.data_controller.activation_vs_penn_angle_regression, 0)));

        end

        function vm_func = get_vm_func_as_func_of_a(obj)
            vm_func = @(a) (@(vm) (obj.f0M*(a*force_length_muscle(obj.data_controller, ...
                 obj.current_normalized_muscle_length)*force_velocity_muscle(obj.data_controller, vm) + ...
                 force_length_parallel(obj.current_normalized_muscle_length) ...
                + obj.damping_coeff*vm)*cosd(polyval(obj.data_controller.activation_vs_penn_angle_regression, a)) ...
                    - obj.get_force()));
        end
        
        %% Update State
        function obj = update_state(obj, ankle_angle, normalized_muscle_length)
            obj.current_muscle_tendon_length = obj.get_muscle_tendon_length(ankle_angle);
            obj.current_normalized_muscle_length = normalized_muscle_length;
            obj.current_normalized_tendon_length = (obj.current_muscle_tendon_length - ...
                obj.resting_muscle_length * obj.current_normalized_muscle_length) / obj.resting_tendon_length;
        end
    end

    methods(Static)
        function muscle_tendon_length = get_muscle_tendon_length(ankle_angle)
            origin = get_rotation_matrix(ankle_angle) * Constants.tibialis_insertion_shank_wrt_shank_axis;
            insertion = Constants.tibialis_insertion_foot;
            
            difference = origin - insertion;
            muscle_tendon_length = sqrt(difference(1)^2 + difference(2)^2);
                
        end
    end
    
end