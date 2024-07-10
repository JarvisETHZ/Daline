function methodsFail = func_visualize_single_error(model, opt)

% Get numbers
methodNum = length(model);

% If methodNum = 1 and model is a struct, convert it into a cell to align
% with the follow code
if methodNum == 1 && isstruct(model)
    model_temp{1} = model;
    model = model_temp;
end

% Define containers
methodNames = cell(methodNum, 1);
maxErrors   = zeros(methodNum, 1);
meanErrors  = zeros(methodNum, 1);

% Get selected error field
selectedField = opt.PLOT.response;

% Collect information
for n = 1:methodNum
    % Get method name
    methodNames{n} = model{n}.algorithm;
    
    % Get error fields
    errorFields = fieldnames(model{n}.error);
    
    % Check for NaN values and selected field presence
    hasSelectedFields = any(ismember(selectedField, errorFields));
    
    % If it has the selected field, record the mean and max error
    if hasSelectedFields
        maxErrors(n)  = max(model{n}.error.(selectedField{1})(:));
        meanErrors(n) = mean(model{n}.error.(selectedField{1})(:));
    % If it has not the selected field, set the mean and max error as NaN
    else
        maxErrors(n)  = NaN;
        meanErrors(n) = NaN;
    end
end

% Identify methods with NaN error => either doesn't have this field or has NaN error
nanIndices = isnan(meanErrors) | isnan(maxErrors);
methodsFail = methodNames(nanIndices);

% Remove the NaN values
maxErrorsClean = maxErrors(~nanIndices);
meanErrorsClean = meanErrors(~nanIndices);
methodNamesClean = methodNames(~nanIndices);

% Sort the clean arrays based on meanErrors
[sortedMeanErrors, sortIdx] = sort(meanErrorsClean, 'descend');
sortedMaxErrors = maxErrorsClean(sortIdx);
sortedMethodNames = methodNamesClean(sortIdx);

% Apply the log transformation
sortlogmaxErrors  = opt.PLOT.origin + log10(sortedMaxErrors);
sortlogmeanErrors = opt.PLOT.origin + log10(sortedMeanErrors);

% Plot the ranking (if requested)
if opt.PLOT.switch
    func_plot_errorLine_style(sortedMethodNames, sortlogmeanErrors, sortlogmaxErrors, opt.PLOT.style, opt.PLOT.origin, methodsFail, selectedField, opt.PLOT.titleHight, opt.PLOT.caseName, opt.PLOT.print);
end



