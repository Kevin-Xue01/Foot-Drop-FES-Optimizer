function [u] = generate_trap_func(amp, start_on, rise_fall_time, t_on,t_off)
    % amp: signal amplitude
    % start on (bool): to start at max amplitude for both stance phase and swing
    % rise_fall_time: rise and fall delay as a % of gait

    % Want amplitude to be at max during swing phase (60-100% of gait cycle)
    step = Constants.time_step;
    for i = 1:length(step)
        if start_on  %starts already turned on, so ignore t_on
            if i < t_off
                u(i) = amp;
            elseif i < (t_off + rise_fall_time)
                u(i) = amp - (amp / rise_fall_time) * (i - t_off);
            else
                u(i) = 0;
            end
        else
            if i < t_on
                u(i) = 0;
            elseif i < (t_on + rise_fall_time)
                u(i) = (amp / rise_fall_time) * (i - t_on);
            elseif i < t_off
                u(i) = amp;
            elseif i < (t_off + rise_fall_time)
                u(i) = amp - (amp / rise_fall_time) * (i - t_off);
            else
                u(i) = 0;
            end
        end
    end
end