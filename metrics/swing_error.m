function [error] = swing_error(corrected_state,normal_literature_data)
    
    disp('--Error During Swing--')    
    model = corrected_state(1, Constants.foot_drop_toe_off_point_index:188);
    literature = normal_literature_data(Constants.foot_drop_toe_off_point_index:188,2);
        
    trans_lit = transpose(literature);
    error = sqrt(immse(model,trans_lit));
    
    disp('Root Mean Squared Error:')
    disp(error)

end