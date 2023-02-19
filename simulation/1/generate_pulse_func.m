function [u] = generate_pulse_func(amp, freq, duty, start_index)
    % amp (double): signal amplitude
    % freq (double): frequency, how many cycles you want to occur
    % duty (int): between 0 and 100, percent of period with active signal
    % inactive_start (
    % u (1xN double): pulse signal with above specifications
    
    time_step = Constants.time_step;
    wave = amp/2 * square(2 * pi * freq .* time_step, duty) + amp/2;
    u = zeros(size(time_step));

    end_index = size(time_step, 2);
    u(start_index:end_index) = wave(1: end_index-start_index+1);
    plot(time_step, u)
end