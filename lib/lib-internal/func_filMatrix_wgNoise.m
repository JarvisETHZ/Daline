function [X_clean, estimated_noise] = func_filMatrix_wgNoise(X, known_noise_dB, useARModel, orderNum, Q_level, zeroInitial)
% Karlman filter
%
% Note:
% 
% The tricky part is how to set matrix A, the process matrix (state
% transition matrix), which describes how the state evolves from one time
% step to the next, i.e., should capture the underlying dynamics and
% relationships between observations. However, this is not easy to set. 
%
% In this code, there are two ways. First, assume A as an identity matrix,
% as done in the second ref (Manandhar2014)., i.e., assuming that each observation is independent of the others. This
% is not very realistic for time series data. Second, try to capture the
% underlying dynamics within observations using AR model in MATLAB. Then
% use the dynamics to formulate A. However, the challenging part is how to
% set the order of the AR model. This can lead to error. 
%
% In the case of time series noisy data. Using identical A is better than
% using AR to set A, as the latter way can significantly change the
% observations. However, even for the identical A, the filtered data can
% only achieve a slightly better accuracy level. Tested on LS and PLS_SIM, getting very
% similar mean error, around 0.0363 (if A is built by AR => error is 4.9171). That is,
% given the unclear way of tuning A, Karlman filter cannot handle the
% noise inside X very well. 
%
% The second tricky part is how to set Q, the Process noise covariance.
% Process noise represents Processnoise represents the unmodeled system
% dynamics or the disturbance inputs in the system model (ref.2). Different
% from the Gaussian white noise, identifying the process noise can be challenging
% because it represents the inherent uncertainties in the system's
% dynamics, which might not be directly observable. However, there is one
% thing for sure, Q is not equal to R, the covariance of measurement noise.
% After manual tuning (i.e., see the accuracy of regression, or the curve
% after noise reducetion), we set Q as eye(numVariables) * 100, which can
% achieve a better accurate level, i.e., mean error is around 0.03 <
% 0.0363. We now set 100 as a user input.
%
% The third tricky part is how to set the initial value of X_est. While in the two
% reference papers, X_est is initialized as zero, this initial
% estimates from the Kalman filter might not be accurate, especially if the
% true initial state is far from zero. This can result in a transient
% period at the beginning where the filter is "catching up" to the true
% state. Also, if X_est0 is zero, and the first observation in X_clean is
% X_est0, X_clean would have a all zero observation. How to deal with this
% is also tricky (remove/replace?). Here, we suggest use the first
% observation in X as X_est0. Of course, users have thier own option. 
%
% Ref. Y. Liu, Z. Li and S. Sun, "A Data-Driven Method for Online
% Constructing Linear Power Flow Model," in IEEE Transactions on Industry
% Applications, doi: 10.1109/TIA.2023.3287152.  
% 
% Ref. K. Manandhar, X. Cao, F. Hu and Y. Liu, "Detection of Faults and
% Attacks Including False Data Injection Attack in Smart Grid Using Kalman
% Filter," in IEEE Transactions on Control of Network Systems, vol. 1, no.
% 4, pp. 370-379, Dec. 2014, doi: 10.1109/TCNS.2014.2357531.   


%% start

% Number of observations and variables
[numObservations, numVariables] = size(X);

% If noise degree is not provided, estimate it
if nargin < 2 || isempty(known_noise_dB)
    estimated_noise = 45;
else
    estimated_noise = known_noise_dB;
end

% Convert dB to power
noise_power = 10^(estimated_noise/10);

% Set A matrix
if useARModel
    % Placeholder for AR coefficients
    AR_coeffs = zeros(numVariables, orderNum); 

    % Model identification for each column
    for i = 1:numVariables
        bestFit = -Inf;
        bestOrder = 1;
        for order = 1:orderNum 
            data = iddata(X(:, i), [], 1); % Convert column to iddata format
            ar_model = arx(data, order);
            if ar_model.Report.Fit.FitPercent > bestFit
                bestFit = ar_model.Report.Fit.FitPercent;
                bestOrder = order;
            end
        end
        % Estimate the best AR model for the column
        data = iddata(X(:, i), [], 1);
        ar_model = arx(data, bestOrder);
        AR_coeffs(i, 1:bestOrder) = -ar_model.A(2:end);
    end

    % Construct the A matrix
    A = eye(numVariables);
    for i = 1:numVariables
        for j = 1:orderNum 
            if AR_coeffs(i, j) ~= 0 && i-j+1 > 0
                A(i, i-j+1) = AR_coeffs(i, j);
            end
        end
    end
else
    A = eye(numVariables);
end

% Set H as identity matrix
H = eye(numVariables);

% Kalman filter parameters
% Q = eye(numVariables) * noise_power; % Process noise covariance
Q = eye(numVariables) * Q_level;       % Process noise covariance, very small
R = eye(numVariables) * noise_power; % Measurement noise covariance
P = eye(numVariables); % Initial estimation error covariance
X_est = zeros(numObservations, numVariables); % Estimated state

% Initialize the first estimate; zeroInitial=1: X_est(1, :) = 0;
if ~zeroInitial
    X_est(1, :) = X(1, :);
end

% Kalman filtering
for k = 2:numObservations
    % Prediction
    X_pred = A * X_est(k-1, :)';
    P_pred = A * P * A' + Q;

    % Update
    K = P_pred * H' / (H * P_pred * H' + R); % Kalman gain
    X_est(k, :) = (X_pred + K * (X(k, :)' - H * X_pred))';
    P = (eye(numVariables) - K * H) * P_pred;
end

% output X_clean; zeroInitial=1: remove X_est(1, :)
if zeroInitial
    X_clean = X_est(2:end, :);
else
    X_clean = X_est;
end

