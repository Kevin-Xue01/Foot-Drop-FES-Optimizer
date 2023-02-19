function moment_from_foot_weight = get_moment_from_foot_weight(hip_angle, knee_angle, ankle_angle)

%%% Inputs
% *neutral position means standing

% hip_angle: deviation angle, in degrees, of upper leg segment from neutral position 
% knee_angle: deviation angle, in degrees, of lower leg segment from neutral position 
% ankle_angle: deviation angle, in degrees, of foot segment from neutral position

%%% Output
% foot_weight: foot weight column vector in the coordinate space of the ankle joint 

mass_of_foot = Constants.foot_mass;
g = Constants.gravity_acc;

foot_weight_vector = (get_rotation_matrix(ankle_angle - 90)*get_rotation_matrix(knee_angle ...
    - 90)*get_rotation_matrix(-hip_angle)*[mass_of_foot*g 0]')';


moment_from_foot_weight = abs(det([Constants.foot_COM_vector; foot_weight_vector]));
end
