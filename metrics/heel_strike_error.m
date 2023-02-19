function [error] = heel_strike_error(corrected_state,literature_data)
    
    disp('--Error @ Heel Strike--')
    disp('Drop Foot Model Ankle Angle:')
    disp(corrected_state(1, 191))
    disp('Normal Foot Model Ankle Angle')
    disp(literature_data(188,2))

    % assuming heel strike is at 0.95 for FD and 0.935 for normal
    
    error = (corrected_state(1, 191) - literature_data(188,2))^2;
    
    disp('Squared Error:')
    disp(error)

end