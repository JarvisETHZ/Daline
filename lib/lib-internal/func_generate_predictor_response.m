function [X_train, X_test, Y_train, Y_test, numY, pList, rList, pIdx, rIdx] = func_generate_predictor_response(data, opt)
% Generate X_train, X_test, Y_train, Y_test for methods

% Divide the data into predictor X and response Y, for training and testing
[X, Y, xIdx, yIdx] = func_generate_XY(data);

% Select predictors for X_train and X_test
[X_train,   ~] = func_combine_fields(X.train, xIdx, opt.variable.predictor);
[X_test, pIdx] = func_combine_fields(X.test,  xIdx, opt.variable.predictor);
[Y_train,   ~] = func_combine_fields(Y.train, yIdx, opt.variable.response);
[Y_test, rIdx] = func_combine_fields(Y.test,  yIdx, opt.variable.response);

% Add intercept to X 
X_train = [ones(size(X_train, 1), 1), X_train];
X_test  = [ones(size(X_test, 1), 1),  X_test];

% Lift the dimension of X if requested
if opt.variable.lift
    % if opt.variable.liftX = 1, then use func_lift_dimension_X
    if opt.variable.liftX
        % Note: need to lift training and testing data together
        Xl = func_lift_dimension_X([X_train; X_test], opt);
    else % use func_lift_dimension_Xi
        % Note: need to lift training and testing data together
        Xl = func_lift_dimension_Xi([X_train; X_test], opt); 
    end
    % Separate Xl into training and testing datasets
    X_train = Xl(1:size(X_train, 1),     :);
    X_test  = Xl(size(X_train, 1)+1:end, :);
    % Get the symbol for X_lift
    X_lift = 'Lifted Variables';
else
    % Get the symbol for X_lift
    X_lift = '';
end

% Get predictor/response list; note: 1 doesn't have an index because it is
% just a constant 1-by-1; X_lift doesn't have an index list because it
% doesn't have any physical meaning
pList = ['1', opt.variable.predictor, X_lift];
rList = opt.variable.response;

% get numbers for later error separations
numY.Vm = size(Y.test.Vm, 2);
numY.Vm2= size(Y.test.Vm2,2);
numY.Va = size(Y.test.Va, 2);
numY.PF = size(Y.test.PF, 2);
numY.PT = size(Y.test.PT, 2);
numY.QF = size(Y.test.QF, 2);
numY.QT = size(Y.test.QT, 2);
numY.P  = size(Y.test.P,  2);
numY.Q  = size(Y.test.Q,  2);