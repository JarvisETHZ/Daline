function model = func_algorithm_DRC_XYD(data, varargin)
% Distributionally robust chance-constrained
% programming, consider X and Y as random variables, divergence-based
% ambiguity set
%
% Much faster than the other DRC methods.
%
% Ref. Y. Liu, Z. Li and J. Zhao, "Robust Data-Driven Linear Power Flow 
% Model With Probability Constrained Worst-Case Errors," in IEEE 
% Transactions on Power Systems, vol. 37, no. 5, pp. 4113-4116, Sept. 2022, 
% doi: 10.1109/TPWRS.2022.3189543.
%
% W. Wei, “Data-driven robust stochastic program,” in Tutorials on
% Advanced Optimization Methods. New York, NY, USA: Springer, 2020, pp.
% 134–135.  

%% Start

% Specify the algorithm
model.algorithm = 'DRC_XYD';  

% Get prepared for options, predictors, responses, and their lists, indices
[opt, X_train, X_test, Y_train, Y_test, numY, ...
 model.predictorList, model.responseList, model.predictorIdx, model.responseIdx] ... 
 = func_opts_predictor_response_multiCPU(model.algorithm, data, varargin{:});

% Find the infimum of h(x) using either fzero or bisection search;
% Usually, the results are the same
switch opt.DRC.infMethod
    case 'fzero'
        [~, h_inf] = func_solve_infimum_fzero(opt.DRC.d, 1-opt.DRC.probThreshold/100, opt.DRC.delta);
    case 'bisec'
        [~, h_inf] = func_solve_infimum_bisec(opt.DRC.d, 1-opt.DRC.probThreshold/100, opt.DRC.delta, 1-opt.DRC.delta, opt.DRC.bisecTol);
end

% Get new alpha
alpha_prime = 1 - h_inf;
alpha_plus = max(alpha_prime, 0);

% Solve the problem individually for each response
[model.Beta, model.success] = func_solve_DRCC_randXY_divergence(X_train, Y_train, opt, alpha_plus);

% test the result
Y_prediction = X_test * model.Beta;
error = abs(Y_prediction - Y_test) ./ abs(Y_test);

% Summarize error/y_pred/y_test/model type based on the options
[model.error, model.yPrediction, model.yTrue, model.type, model.note] ...
    = func_summarize_result(model.Beta, error, numY, Y_prediction, Y_test, opt);

% display
disp([model.algorithm, ' training & testing are done!'])
