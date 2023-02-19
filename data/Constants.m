classdef Constants 
    
    properties (Constant)
        %% Data Dependant Values
        step_size = 0.005
        % values with ** appended need to be adjusted based on step_size
        time_step = 0:0.005:1 % **
        foot_drop_toe_off_point_index = 140 % **
        normal_toe_off_point_index = 126 % **

        foot_drop_neutral_index = 37; % **
        foot_drop_neutral_ankle_angle_data_difference = 90.0625552825791 - 90; % **

        normal_neutral_index = 25; %**
        normal_neutral_ankle_angle_data_difference = 90.3268941547308 - 90; % **
        
        %% User Defined Assumptions
        foot_drop_activation = 0;
        maximum_activation = 1;
        activation_step_size = 0.1;
        %% Commonly Known Values
        ankle_angle_rest = 90
        gravity_acc = 9.81
        %% Assumptions from lectures and assignments
        slack_length_of_PE = 1
        slack_length_of_SE = 1

        damping_coeff = 0.1
        tibialis_f0M  = 2000 
        tibialis_moment_arm = 0.03
        tibialis_insertion_foot = [0.06 -0.03]'
        tibialis_insertion_shank_wrt_shank_axis = [0.3 -0.03]'
        muscle_length_percent_at_rest = 0.6 
        tendon_length_percent_at_rest = 0.4 
        
        foot_neutral_angle = 26.56505118        
        %% Values found from literature
        foot_mass = 1.05 % kg
        foot_COM = 0.13 % meters
        foot_COM_vector = [0.13*cosd(26.56505118) -0.13*sind(26.56505118)]
        foot_MOI_about_ankle = 9.45 * (10^-4) % kg m^2
    end
end

