function force_length_scale_factor = force_length_muscle(data_controller, lm)
    if lm >= 1.34
        force_length_scale_factor = polyval(data_controller.upper_bound_muscle_force_length_regression, lm);
    elseif lm <= 0.65
        force_length_scale_factor = polyval(data_controller.lower_bound_muscle_force_length_regression, lm);
    else
        force_length_scale_factor = feval(data_controller.muscle_force_length_regression, lm);
    end
end    