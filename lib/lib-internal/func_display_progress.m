function backspaces = func_display_progress(method, backspaces, progress)
pro_str = sprintf([method, ' training complete percentage: %3.1f'], progress);
fprintf([backspaces, pro_str]);
backspaces = repmat(sprintf('\b'), 1, length(pro_str)); % Subtract 1 to account for the newline character