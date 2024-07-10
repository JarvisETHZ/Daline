function [sorted_time, sorted_methods] = func_sortMethodTime(time_list, methodList)
    % This function sorts the time_list in ascending order and rearranges
    % the methodList correspondingly.
    
    % Sort the time_list while keeping the indices
    [sorted_time, idx] = sort(time_list);
    
    % Rearrange the methodList based on the sorting indices
    sorted_methods = methodList(idx);
end