function normalize_PE_force = force_length_parallel(lm)
    slack_length_of_PE = Constants.slack_length_of_PE;
    if lm >= slack_length_of_PE
        normalize_PE_force = 3.*(lm-slack_length_of_PE)^2/(0.6+lm-slack_length_of_PE);
    else
        normalize_PE_force = 0;
    end

end