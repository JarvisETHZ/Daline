function func_check_structFields(opt_benchmark, opt_user)
    % Check top-level fields
    benchmark_fields = fieldnames(opt_benchmark);
    user_fields = fieldnames(opt_user);
    
    % Ensure all user fields exist in benchmark
    missing_fields = setdiff(user_fields, benchmark_fields);
    if ~isempty(missing_fields)
        if length(missing_fields) > 1
            error('Options ''%s'' are not supported by the toolbox. Please check the manual or func_default_option_category.m to see the supported options.', strjoin(missing_fields, ', '));
        else
            error('Option ''%s'' is not supported by the toolbox. Please check the manual or func_default_option_category.m to see the supported options.', strjoin(missing_fields, ', '));
        end
    end

    % Iterate over each field in user input
    for i = 1:length(user_fields)
        % Get each top-level field name from opt_user and opt_benchmark
        user_field = user_fields{i};
        benchmark_field = benchmark_fields{strcmp(benchmark_fields, user_field)};
        
        % Get the sub-field names of the top-level field
        benchmark_subfields = fieldnames(opt_benchmark.(benchmark_field));
        user_subfields = fieldnames(opt_user.(user_field));
        
        % Ensure all user sub-field names exist in the benchmark sub-field names
        missing_subfields = setdiff(user_subfields, benchmark_subfields);
        if ~isempty(missing_subfields)
            formatted_missing_subfields = strcat(user_field, '.', missing_subfields);
            if length(formatted_missing_subfields) > 1
                error(['Sub options ''%s'' are not supported by the toolbox. Please check the manual or func_default_option_category.m to see the supported sub options.'], strjoin(formatted_missing_subfields, ', '));
            else
                error(['Sub option ''%s'' is not supported by the toolbox. Please check the manual or func_default_option_category.m to see the supported sub options.'], strjoin(formatted_missing_subfields, ', '));
            end
        end
    end
end