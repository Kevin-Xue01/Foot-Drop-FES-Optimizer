function force_velocity_scale_factor = force_velocity_muscle(data_controller, vm)
    % Input Parameters
    % vm: muscle (contractile element) velocity)
    
    % Output
    % force-velocity scale factor

    
    function [output] = model_eval(input, ridge_coeff)
    % This is a nested function
    
        fun = @(x, mu, sigma) 1./(1+exp(-(x-mu)./sigma));
        X = [];
        for i = -1:0.2:-0.1
            X = [X fun(input, i, 0.15)];
        end
        output = ridge_coeff(1) + X*ridge_coeff(2:end);
    end
    
    
    if size(vm, 2) > size(vm, 1)
        vm = vm';
    end
    force_velocity_scale_factor = model_eval(vm, data_controller.muscle_force_velocity_regression);
end