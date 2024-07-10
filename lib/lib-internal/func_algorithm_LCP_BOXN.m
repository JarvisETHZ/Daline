function model = func_algorithm_LCP_BOXN(data, varargin)
% func_algorithm_LCP_BOXN: Linearly constrained programming without box constraints,
% as a comparison of linearly constrained programming with box constraints.
%
% It simply solves the least squares problem using programing, i.e.,
% minimize ||Y-X*Beta||_2^2
%
% Ref. Y.Liu,B.Xu,A.Botterud,N.Zhang,and C.Kang,“Bounding regression errors 
% in data-driven power grid steady-state models,” IEEE Transactions on 
% Power Systems, vol. 36, no. 2, pp. 1023–1033, 2020.

%% Start

% Specify the algorithm
model.algorithm = 'LCP_BOXN';

% Finalize options based on the default options of this method and the inputted options
opt = func_finalize_opt_method(model.algorithm, varargin{:});

% Set warning off if requested
func_warning_switch_singleCPU(opt.warning.switch)

% Mandatory predictor and response for input
opt.variable.predictor = {'P',  'Q'};  
opt.variable.response  = {'Va', 'Vm'}; 

% Mandatory predictor and response for output; but they will have indices as they are not messed up
model.predictorList = 'Fixed: P, Q';
model.responseList  = 'Fixed: Va, Vm';

% Specify and transform input and output
[X_train, X_test, Y_train, Y_test, numY, ~, ~, model.predictorIdx, model.responseIdx] = func_generate_predictor_response(data, opt);

% Get numbers again; num_X_var and num_Y_var are used in cvx; ignore the reminder from MATLAB
[~, num_X_var] = size(X_train);
[~, num_Y_var] = size(Y_train);


% Start CVX to solve the linearly constrained programming with box (bound) 
% constraints for Beta
if opt.LCP.cvxQuiet
    cvx_quiet(true);          % Suppress CVX output
    disp('cvx starts to solve LCP_BOXN')
else
    cvx_quiet(false); 
end
func_cvx_solver(opt.LCP.solver)  % set solver
cvx_begin
    % Define Beta as a variable
    variable B(num_X_var, num_Y_var)
    % Define the objective function
    minimize(sum(sum((Y_train - X_train*B).^2)))
cvx_end

% Test the model
model.Beta = B;
Y_prediction = X_test * model.Beta;
error  = abs(Y_prediction - Y_test) ./ abs(Y_test);

% Summarize error/y_pred/y_test/model type based on the options
[model.error, model.yPrediction, model.yTrue, model.type, model.note] ...
    = func_summarize_result(model.Beta, error, numY, Y_prediction, Y_test, opt);

% Test the results if succeed
if strcmp(cvx_status, 'Solved')
    % Store the status
    model.success = 1;
else
    % Store the status
    model.success = 0;
end

% display
disp([model.algorithm, ' training & testing are done!'])

