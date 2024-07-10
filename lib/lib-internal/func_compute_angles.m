function angles = func_compute_angles(sin_diff, cos_diff, num_nodes, known_node, known_angle, angle_Fbus, angle_Tbus)
% func_compute_angles derives the angles of nodes in an undirected graph.
%
% INPUTS:
% - sin_diff: Matrix where each row is an observation and each column represents the sine of the angle difference between two nodes.
% - cos_diff: Matrix where each row is an observation and each column represents the cosine of the angle difference between two nodes.
% - num_nodes: Total number of nodes in the graph.
% - known_node: Index of the node for which the angle is known.
% - known_angle: Vector where each entry is the known angle (in radians) of the known_node for the corresponding observation.
% - angle_Fbus: Vector indicating the "from" node for each angle difference.
% - angle_Tbus: Vector indicating the "to" node for each angle difference.
%
% OUTPUT:
% - angles: Matrix where each row is an observation and each column represents the angle (in radians) of a node.
%
% USAGE:
% angles = computeAngles(sin_diff, cos_diff, num_nodes, known_node, known_angle, angle_Fbus, angle_Tbus);

% Number of observations
num_observations = size(sin_diff, 1);

% Initialize the output angles matrix
angles = NaN(num_observations, num_nodes);

for obs = 1:num_observations
    % Initialize angles for this observation
    angles_obs = NaN(1, num_nodes);
    angles_obs(known_node) = known_angle(obs);

    % Create a list of visited nodes
    visited = false(1, num_nodes);
    visited(known_node) = true;

    % Compute angles for this observation
    while any(~visited)
        % For every pair, we do
        for n = 1:length(angle_Fbus)
            i = angle_Fbus(n);
            j = angle_Tbus(n);
            
            % If we know the angle i but don't know angle j
            if visited(i) && ~visited(j)
                % Compute angle difference
                angle_diff = atan2(sin_diff(obs,n), cos_diff(obs,n));

                % Compute angle of node j
                angles_obs(j) = angles_obs(i) - angle_diff;

                % Mark node j as visited
                visited(j) = true;
            
            % If we know the angle j but don't know angle i
            elseif visited(j) && ~visited(i)
                % Compute angle difference
                angle_diff = atan2(sin_diff(obs,n), cos_diff(obs,n));

                % Compute angle of node i
                angles_obs(i) = angles_obs(j) + angle_diff;

                % Mark node i as visited
                visited(i) = true;
            end
        end
    end
    % Store the angles for this observation
    angles(obs, :) = angles_obs;
end
