classdef DataController 
    properties
        raw_data_filepath = "data/raw_data.xlsx"
        processed_data_filepath = "data/processed_data.xlsx"

        % When running without 'new_interpolation_time', (expect fields: mfld, mfvd, avpad) 
        % size(*_data, 1) = # of time_steps,
        % size(*_data, 2) = 2
        % col 1 = time
        % col 2 = actual data
        
        foot_drop_ankle_angle_data 
        foot_drop_knee_angle_data
        foot_drop_hip_angle_data

        foot_drop_ankle_angle_data_interpolated % only used when running with 'new_interpolation_time'
        normal_ankle_angle_data_interpolated % only used when running with 'new_interpolation_time'

        normal_ankle_angle_data
        normal_knee_angle_data
        normal_hip_angle_data

        muscle_force_length_data % aka mfld
        muscle_force_velocity_data % aka mfvd
        activation_vs_penn_angle_data % aka avpad

        muscle_force_length_regression
        lower_bound_muscle_force_length_regression
        upper_bound_muscle_force_length_regression

        muscle_force_velocity_regression
        activation_vs_penn_angle_regression

        foot_drop_ankle_angular_speed_data % only used when running without 'new_interpolation_time'
        foot_drop_ankle_angular_acceleration_data % only used when running without 'new_interpolation_time'
        normal_ankle_angular_speed_data % only used when running without 'new_interpolation_time'
        normal_ankle_angular_acceleration_data % only used when running without 'new_interpolation_time' 

        foot_drop_norm_tendon_length_data % only used when running without 'new_interpolation_time'
        foot_drop_norm_muscle_length_data % only used when running without 'new_interpolation_time'
        foot_drop_norm_muscle_velocity_data % only used when running without 'new_interpolation_time'

        normal_norm_tendon_length_data % only used when running without 'new_interpolation_time'
        normal_norm_muscle_length_data % only used when running without 'new_interpolation_time'
        normal_norm_muscle_velocity_data % only used when running without 'new_interpolation_time'

    end
    
    methods
        function obj = DataController(new_interpolation_time)

            obj.muscle_force_length_data = obj.load_muscle_force_length_data();
            obj.muscle_force_velocity_data = obj.load_muscle_force_velocity_data();
            obj.activation_vs_penn_angle_data = obj.load_activation_vs_penn_angle_data();

            obj.muscle_force_length_regression = obj.load_muscle_force_length_regression();
            obj.muscle_force_velocity_regression = obj.load_muscle_force_velocity_regression();
            obj.activation_vs_penn_angle_regression = obj.load_activation_vs_penn_angle_regression();

            [obj.lower_bound_muscle_force_length_regression, obj.upper_bound_muscle_force_length_regression] = obj.load_muscle_force_length_bounds_regression();

            if nargin >= 1
                obj.foot_drop_ankle_angle_data = obj.load_foot_drop_ankle_angle_data(obj.raw_data_filepath);
                obj.foot_drop_knee_angle_data = obj.load_foot_drop_knee_angle_data(obj.raw_data_filepath);
                obj.foot_drop_hip_angle_data = obj.load_foot_drop_hip_angle_data(obj.raw_data_filepath);
    
                obj.normal_ankle_angle_data = obj.load_normal_ankle_angle_data(obj.raw_data_filepath);
                obj.normal_knee_angle_data = obj.load_normal_knee_angle_data(obj.raw_data_filepath);
                obj.normal_hip_angle_data = obj.load_normal_hip_angle_data(obj.raw_data_filepath);

                % VERY IMPORTANT STEP - Modifying Data
                obj.foot_drop_ankle_angle_data = obj.offset_ankle_angle_data(obj.foot_drop_ankle_angle_data);
                obj.normal_ankle_angle_data = obj.offset_ankle_angle_data(obj.normal_ankle_angle_data);
                % -------------------------------------------------------------------------------------
        
                obj.foot_drop_ankle_angle_data_interpolated = obj.generate_foot_drop_ankle_angle_interpolation(new_interpolation_time);
                obj.generate_foot_drop_knee_angle_interpolation(new_interpolation_time);
                obj.generate_foot_drop_hip_angle_interpolation(new_interpolation_time);

                obj.normal_ankle_angle_data_interpolated = obj.generate_normal_ankle_angle_interpolation(new_interpolation_time);
                obj.generate_normal_knee_angle_interpolation(new_interpolation_time);
                obj.generate_normal_hip_angle_interpolation(new_interpolation_time);

                obj.generate_angular_speed_and_angular_acceleration(new_interpolation_time);

                obj.generate_lengths_and_velocities(new_interpolation_time);
            else
                obj.foot_drop_ankle_angle_data = obj.load_foot_drop_ankle_angle_data(obj.processed_data_filepath);
                obj.foot_drop_knee_angle_data = obj.load_foot_drop_knee_angle_data(obj.processed_data_filepath);
                obj.foot_drop_hip_angle_data = obj.load_foot_drop_hip_angle_data(obj.processed_data_filepath);
    
                obj.normal_ankle_angle_data = obj.load_normal_ankle_angle_data(obj.processed_data_filepath);
                obj.normal_knee_angle_data = obj.load_normal_knee_angle_data(obj.processed_data_filepath);
                obj.normal_hip_angle_data = obj.load_normal_hip_angle_data(obj.processed_data_filepath);

                obj.foot_drop_ankle_angular_speed_data = obj.load_foot_drop_ankle_angular_speed_data();
                obj.foot_drop_ankle_angular_acceleration_data = obj.load_foot_drop_ankle_angular_acceleration_data();
                obj.normal_ankle_angular_speed_data = obj.load_normal_ankle_angular_speed_data();
                obj.normal_ankle_angular_acceleration_data = obj.load_normal_ankle_angular_acceleration_data();

                obj.normal_norm_tendon_length_data = obj.load_normal_norm_tendon_length_data();
                obj.normal_norm_muscle_length_data = obj.load_normal_norm_muscle_length_data();
                obj.normal_norm_muscle_velocity_data = obj.load_normal_norm_muscle_velocity_data();
                
                obj.foot_drop_norm_tendon_length_data = obj.load_foot_drop_norm_tendon_length_data();
                obj.foot_drop_norm_muscle_length_data = obj.load_foot_drop_norm_tendon_length_data();
                obj.foot_drop_norm_muscle_velocity_data = obj.load_foot_drop_norm_muscle_velocity_data();
                

            end
            
        end
        
        %% Load data: mfld, mfvd, avpad
        function muscle_force_length_data = load_muscle_force_length_data(obj)
            muscle_force_length_data = table2array(readtable(obj.raw_data_filepath, "Sheet", ...
                "muscle_force_length", 'ReadVariableNames',true, 'PreserveVariableNames',true));
        end

        function muscle_force_velocity_data = load_muscle_force_velocity_data(obj)
            muscle_force_velocity_data = table2array(readtable(obj.raw_data_filepath, "Sheet", ...
                "muscle_force_velocity", 'ReadVariableNames',true, 'PreserveVariableNames',true));
        end

        function activation_vs_penn_angle_data = load_activation_vs_penn_angle_data(obj)
            activation_vs_penn_angle_data = table2array(readtable(obj.raw_data_filepath, "Sheet", ...
                "activation_vs_penn_angle", 'ReadVariableNames',true, 'PreserveVariableNames',true));
        end
        
        %% Loading: angular speed + angular acceleration
        function foot_drop_ankle_angular_speed = load_foot_drop_ankle_angular_speed_data(obj)
            foot_drop_ankle_angular_speed = table2array(readtable(obj.processed_data_filepath, "Sheet", ...
                "foot_drop_ankle_angular_speed", 'ReadVariableNames',true, 'PreserveVariableNames',true));
        end

        function foot_drop_ankle_angular_acceleration = load_foot_drop_ankle_angular_acceleration_data(obj)
            foot_drop_ankle_angular_acceleration = table2array(readtable(obj.processed_data_filepath, "Sheet", ...
                "foot_drop_ankle_angular_acc", 'ReadVariableNames',true, 'PreserveVariableNames',true));
        end

        function normal_ankle_angular_speed = load_normal_ankle_angular_speed_data(obj)
            normal_ankle_angular_speed = table2array(readtable(obj.processed_data_filepath, "Sheet", ...
                "normal_ankle_angular_speed", 'ReadVariableNames',true, 'PreserveVariableNames',true));
        end

        function normal_ankle_angular_acceleration = load_normal_ankle_angular_acceleration_data(obj)
            normal_ankle_angular_acceleration = table2array(readtable(obj.processed_data_filepath, "Sheet", ...
                "normal_ankle_angular_acc", 'ReadVariableNames',true, 'PreserveVariableNames',true));
        end


        %% Loading data: norm tendon length, norm muscle length, norm muscle velocity
        function normal_norm_tendon_length_data = load_normal_norm_tendon_length_data(obj)
            normal_norm_tendon_length_data = table2array(readtable(obj.processed_data_filepath, "Sheet", ...
                "normal_norm_tendon_length", 'ReadVariableNames',true, 'PreserveVariableNames',true));
        end

        function normal_norm_muscle_length_data = load_normal_norm_muscle_length_data(obj)
            normal_norm_muscle_length_data = table2array(readtable(obj.processed_data_filepath, "Sheet", ...
                "normal_norm_muscle_length", 'ReadVariableNames',true, 'PreserveVariableNames',true));
        end

        function normal_norm_muscle_velocity_data = load_normal_norm_muscle_velocity_data(obj)
            normal_norm_muscle_velocity_data = table2array(readtable(obj.processed_data_filepath, "Sheet", ...
                "normal_norm_muscle_velocity", 'ReadVariableNames',true, 'PreserveVariableNames',true));
        end

        function foot_drop_norm_tendon_length_data = load_foot_drop_norm_tendon_length_data(obj)
            foot_drop_norm_tendon_length_data = table2array(readtable(obj.processed_data_filepath, "Sheet", ...
                "foot_drop_norm_tendon_length", 'ReadVariableNames',true, 'PreserveVariableNames',true));
        end

        function foot_drop_norm_muscle_length_data = load_foot_drop_norm_muscle_length_data(obj)
            foot_drop_norm_muscle_length_data = table2array(readtable(obj.processed_data_filepath, "Sheet", ...
                "foot_drop_norm_muscle_length", 'ReadVariableNames',true, 'PreserveVariableNames',true));
        end

        function foot_drop_norm_muscle_velocity_data = load_foot_drop_norm_muscle_velocity_data(obj)
            foot_drop_norm_muscle_velocity_data = table2array(readtable(obj.processed_data_filepath, "Sheet", ...
                "foot_drop_norm_muscle_velocity", 'ReadVariableNames',true, 'PreserveVariableNames',true));
        end
        
        %% Regressions for: mfld, mfvd, avpad
        function muscle_force_length_regression = load_muscle_force_length_regression(obj)
            % relevant props:
            %   obj.muscle_force_length_data: Nx2 array where col 1 is length, 2 is force
            % return:
            %   muscle_force_length_regression: cfit gaussian of normailize
            %       force-length muscle data

            data = obj.muscle_force_length_data; 
            muscle_force_length_regression = fit(data(:,1),data(:,2),'gauss2');
        end

        function [lower_bound_muscle_force_length_regression, upper_bound_muscle_force_length_regression] = load_muscle_force_length_bounds_regression(obj)
            % relevant props:
            %   obj.muscle_force_length_data: Nx2 array where col 1 is length, 2 is force
            % return:
            %   muscle_force_length_regression: cfit gaussian of normailize
            %       force-length muscle data

            data = obj.muscle_force_length_data; 
            num_samples = length(data);
            lower_bound_muscle_force_length_regression = polyfit(data(1:9,1),data(1:9,2),4);
            upper_bound_muscle_force_length_regression = polyfit(data(num_samples -9:num_samples,1),data(num_samples -9:num_samples,2),4);
        end

        function muscle_force_velocity_regression = load_muscle_force_velocity_regression(obj)
            % relevant props:
            %   obj.muscle_force_velocity_data: Nx2 array where col 1 is velocity, 2 is force
            % return:
            %   muscle_force_velocity_regression: 

            data = obj.muscle_force_velocity_data;
            velocity = data(:,1); % Nx1
            force = data(:,2); % Nx1
            
            fun = @(x, mu, sigma) 1./(1+exp(-(x-mu)./sigma));
            X = [];  % Nx5
            for i = -1:0.2:-0.1  % 1x5
                X = [X fun(velocity, i, 0.15)];
            end
            muscle_force_velocity_regression = ridge(force, X, 1, 0);
        end

        function activation_vs_penn_angle_regression = load_activation_vs_penn_angle_regression(obj)
            data = obj.activation_vs_penn_angle_data;
            activation_vs_penn_angle_regression = polyfit(data(:,1),data(:,2),1);
        end
        
        
        %% Interpolating data
        function interpolation_y = generate_foot_drop_ankle_angle_interpolation(obj, interpolation_x)
            data = obj.foot_drop_ankle_angle_data;
            interpolation_y = interp1(data(:,1), data(:, 2), interpolation_x, 'spline');
            interpolated_table = table(interpolation_x', interpolation_y', ...
                'VariableNames', {'% gait', 'theta'});
            writetable(interpolated_table, obj.processed_data_filepath, 'Sheet', ...
                'foot_drop_ankle_angle');
        end
        
        function generate_foot_drop_knee_angle_interpolation(obj, interpolation_x)
            data = obj.foot_drop_knee_angle_data;
            interpolation_y = interp1(data(:,1), data(:, 2), interpolation_x, 'spline');
            interpolated_table = table(interpolation_x', interpolation_y', ...
                'VariableNames', {'% gait', 'theta'});
            writetable(interpolated_table, obj.processed_data_filepath, 'Sheet', ...
                'foot_drop_knee_angle');
        end

        function generate_foot_drop_hip_angle_interpolation(obj, interpolation_x)
            data = obj.foot_drop_hip_angle_data;
            interpolation_y = interp1(data(:,1), data(:, 2), interpolation_x, 'spline');
            interpolated_table = table(interpolation_x', interpolation_y', ...
                'VariableNames', {'% gait', 'theta'});
            writetable(interpolated_table, obj.processed_data_filepath, 'Sheet', ...
                'foot_drop_hip_angle');
        end

        function interpolation_y = generate_normal_ankle_angle_interpolation(obj, interpolation_x)
            data = obj.normal_ankle_angle_data;
            interpolation_y = interp1(data(:,1), data(:, 2), interpolation_x, 'spline');
            interpolated_table = table(interpolation_x', interpolation_y', ...
                'VariableNames', {'% gait', 'theta'});
            writetable(interpolated_table, obj.processed_data_filepath, 'Sheet', ...
                'normal_ankle_angle');
        end
        
        function generate_normal_knee_angle_interpolation(obj, interpolation_x)
            data = obj.normal_knee_angle_data;
            interpolation_y = interp1(data(:,1), data(:, 2), interpolation_x, 'spline');
            interpolated_table = table(interpolation_x', interpolation_y', ...
                'VariableNames', {'% gait', 'theta'});
            writetable(interpolated_table, obj.processed_data_filepath, 'Sheet', ...
                'normal_knee_angle');
        end

        function generate_normal_hip_angle_interpolation(obj, interpolation_x)
            data = obj.normal_hip_angle_data;
            interpolation_y = interp1(data(:,1), data(:, 2), interpolation_x, 'spline');
            interpolated_table = table(interpolation_x', interpolation_y', ...
                'VariableNames', {'% gait', 'theta'});
            writetable(interpolated_table, obj.processed_data_filepath, 'Sheet', ...
                'normal_hip_angle');
        end
        
        %% Generating data: angular speed + angular acceleration
        function generate_angular_speed_and_angular_acceleration(obj, time)
            
            normal_ankle_angular_speed = obj.get_angular_speed([time' obj.normal_ankle_angle_data_interpolated']);
            foot_drop_ankle_angular_speed = obj.get_angular_speed([time' obj.foot_drop_ankle_angle_data_interpolated']);

            normal_ankle_angular_acceleration = obj.get_angular_acceleration([time' normal_ankle_angular_speed]);
            foot_drop_ankle_angular_acceleration = obj.get_angular_acceleration([time' foot_drop_ankle_angular_speed]);

            interpolated_table = table(time', normal_ankle_angular_speed, ...
                'VariableNames', {'% gait', 'theta_dot'});
            writetable(interpolated_table, obj.processed_data_filepath, 'Sheet', ...
                'normal_ankle_angular_speed');
            
            interpolated_table = table(time', foot_drop_ankle_angular_speed, ...
                'VariableNames', {'% gait', 'theta_dot'});
            writetable(interpolated_table, obj.processed_data_filepath, 'Sheet', ...
                'foot_drop_ankle_angular_speed');
            
            interpolated_table = table(time', normal_ankle_angular_acceleration, ...
                'VariableNames', {'% gait', 'theta_ddot'});
            writetable(interpolated_table, obj.processed_data_filepath, 'Sheet', ...
                'normal_ankle_angular_acc');
            
            interpolated_table = table(time', foot_drop_ankle_angular_acceleration, ...
                'VariableNames', {'% gait', 'theta_ddot'});
            writetable(interpolated_table, obj.processed_data_filepath, 'Sheet', ...
                'foot_drop_ankle_angular_acc');

        end

        %% Generating data: norm tendon length, norm muscle length, norm muscle velocity

        function generate_lengths_and_velocities(obj, new_interpolation_time)

                foot_drop_tibialis = TibialisMuscleModel(obj);
                normal_tibialis = TibialisMuscleModel(obj);
                
                foot_drop_normalized_tendon_length = zeros([length(new_interpolation_time) 1]);
                normal_normalized_tendon_length = zeros([length(new_interpolation_time) 1]);
                foot_drop_normalized_muscle_length = zeros([length(new_interpolation_time) 1]);
                normal_normalized_muscle_length = zeros([length(new_interpolation_time) 1]);

                for i=1:length(new_interpolation_time)

                    foot_drop_tibialis = foot_drop_tibialis.update_muscle_state(obj.foot_drop_ankle_angle_data_interpolated(i));
                    normal_tibialis = normal_tibialis.update_muscle_state(obj.normal_ankle_angle_data_interpolated(i));

                    foot_drop_normalized_muscle_length(i) = foot_drop_tibialis.current_normalized_muscle_length;
                    normal_normalized_muscle_length(i) = normal_tibialis.current_normalized_muscle_length;

                    foot_drop_normalized_tendon_length(i) = foot_drop_tibialis.current_normalized_tendon_length;
                    normal_normalized_tendon_length(i) = normal_tibialis.current_normalized_tendon_length;
                end

                foot_drop_normalized_muscle_velocity = gradient(foot_drop_normalized_muscle_length, new_interpolation_time);
                normal_normalized_muscle_velocity = gradient(normal_normalized_muscle_length, new_interpolation_time);

                interpolated_table = table(new_interpolation_time', foot_drop_normalized_tendon_length, ...
                    'VariableNames', {'% gait', 'foot_drop_norm_tendon_length'});
                writetable(interpolated_table, obj.processed_data_filepath, 'Sheet', ...
                    'foot_drop_norm_tendon_length');

                interpolated_table = table(new_interpolation_time', normal_normalized_tendon_length, ...
                    'VariableNames', {'% gait', 'normal_norm_tendon_length'});
                writetable(interpolated_table, obj.processed_data_filepath, 'Sheet', ...
                    'normal_norm_tendon_length');

                interpolated_table = table(new_interpolation_time', foot_drop_normalized_muscle_length, ...
                    'VariableNames', {'% gait', 'foot_drop_norm_muscle_length'});
                writetable(interpolated_table, obj.processed_data_filepath, 'Sheet', ...
                    'foot_drop_norm_muscle_length');

                interpolated_table = table(new_interpolation_time', normal_normalized_muscle_length, ...
                    'VariableNames', {'% gait', 'normal_norm_muscle_length'});
                writetable(interpolated_table, obj.processed_data_filepath, 'Sheet', ...
                    'normal_norm_muscle_length');

                interpolated_table = table(new_interpolation_time', foot_drop_normalized_muscle_velocity, ...
                    'VariableNames', {'% gait', 'foot_drop_norm_muscle_velocity'});
                writetable(interpolated_table, obj.processed_data_filepath, 'Sheet', ...
                    'foot_drop_norm_muscle_velocity');

                interpolated_table = table(new_interpolation_time', normal_normalized_muscle_velocity, ...
                    'VariableNames', {'% gait', 'normal_norm_muscle_velocity'});
                writetable(interpolated_table, obj.processed_data_filepath, 'Sheet', ...
                    'normal_norm_muscle_velocity');
            
        end
    end

    methods(Static)
        %% Differentiation
        function angular_speed = get_angular_speed(ankle_angle_data)
            angle = ankle_angle_data(:,2);
            time = ankle_angle_data(:,1)';
            angular_speed = gradient(angle, time);
        end
        
        function angular_acceleration = get_angular_acceleration(ankle_angular_speed_data)
            angular_speed = ankle_angular_speed_data(:,2);
            time = ankle_angular_speed_data(:,1)';
            angular_acceleration = gradient(angular_speed, time);
        end

        %% Modifying Data
        function new_ankle_angle_data = offset_ankle_angle_data(ankle_angle_data)
            new_ankle_angle_data = [ankle_angle_data(:, 1) 90 - ankle_angle_data(:, 2)];
        end
        
        %% Loading Data
        function foot_drop_ankle_angle_data = load_foot_drop_ankle_angle_data(filepath)
            foot_drop_ankle_angle_data = table2array(readtable(filepath, "Sheet", ...
                "foot_drop_ankle_angle", 'ReadVariableNames',true, 'PreserveVariableNames',true));
        end

        function foot_drop_knee_angle_data = load_foot_drop_knee_angle_data(filepath)
            foot_drop_knee_angle_data = table2array(readtable(filepath, "Sheet", ...
                "foot_drop_knee_angle", 'ReadVariableNames',true, 'PreserveVariableNames',true));
        end

        function foot_drop_hip_angle_data = load_foot_drop_hip_angle_data(filepath)
            foot_drop_hip_angle_data = table2array(readtable(filepath, "Sheet", ...
                "foot_drop_hip_angle", 'ReadVariableNames',true, 'PreserveVariableNames',true));
        end

        function normal_ankle_angle_data = load_normal_ankle_angle_data(filepath)
            normal_ankle_angle_data = table2array(readtable(filepath, "Sheet", ...
                "normal_ankle_angle", 'ReadVariableNames',true, 'PreserveVariableNames',true));
        end

        function normal_knee_angle_data = load_normal_knee_angle_data(filepath)
            normal_knee_angle_data = table2array(readtable(filepath, "Sheet", ...
                "normal_knee_angle", 'ReadVariableNames',true, 'PreserveVariableNames',true));
        end

        function normal_hip_angle_data = load_normal_hip_angle_data(filepath)
            normal_hip_angle_data = table2array(readtable(filepath, "Sheet", ...
                "normal_hip_angle", 'ReadVariableNames',true, 'PreserveVariableNames',true));
        end
    end

end

