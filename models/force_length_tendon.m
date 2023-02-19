function normalize_tendon_tension = force_length_tendon(lt)
    slack_length_of_SE = Constants.slack_length_of_SE;
    
    if lt >= slack_length_of_SE
        normalize_tendon_tension = 10.*(lt-slack_length_of_SE)+240.*(lt-slack_length_of_SE)^2;
    else
        normalize_tendon_tension = 0;
    end

end