function [rotation_matrix] = get_rotation_matrix(angle)
rotation_matrix = [cosd(angle) -sind(angle); sind(angle) cosd(angle)];
end

