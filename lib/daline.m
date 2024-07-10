% Welcome to the daline Toolbox
% Daline: DatA-driven power flow LINEarization
classdef daline
    %% Properties
    properties
        Mengshuo_Jia_ETHZ = 'Hopes Daline can help you a bit. See www.shuo.science for more information!' 
    end
    
    %% Sub functions
    methods (Static)
        %% all: full cycle process for data & train & test & visualize 
        function varargout = all(casename, varargin)
            % E.g., model = daline.all('case118');
            % E.g., model = daline.all(mpc);
            % E.g., model = daline.all('case118', 'method.name', 'RR');
            % E.g., model = daline.all(mpc, 'method.name', 'RR');
            % E.g., opt   = daline.setopt('data.baseType', 'TimeSeriesRand', 'method.name', 'RR');
            %       model = daline.all('case118', opt);
            
            % Generate/pollute/clean/normalize data and train/test/visualize models
            [model, data, failure] = func_all(casename, varargin{:});
            % Generate selective outputs
            varargout{1} = model;
            if nargout == 2
                varargout{2} = data;
            elseif nargout == 3
                varargout{2} = data;
                varargout{3} = failure;
            end
        end
        
        %% data: pipeline to generate/pollute/clean/normalize data
        function varargout = data(varargin)
            % E.g., data = daline.data();
            % E.g., data = daline.data('case.name', 'case118');
            % E.g., data = daline.data('case.name', 'case118', 'noise.switchTrain', 1);
            % E.g., opt  = daline.setopt('case.mpc', mpc, 'data.baseType', 'TimeSeriesRand');
            %       data = daline.data(opt);
            
            % Get data
            [data, X, Y] = func_data_pipeline(varargin{:});
            % Generate selective outputs
            varargout{1} = data;
            if nargout == 3
                varargout{2} = X;
                varargout{3} = Y;
            elseif nargout == 2 
                varargout{2} = X;
            end
        end
        
        %% generate: generate training and testing data
        function data = generate(varargin)
            % E.g., data = daline.generate();
            % E.g., data = daline.generate('case.name', 'case118');
            % E.g., data = daline.generate('case.name', 'case118', 'data.baseType', 'TimeSeriesRand');
            % E.g., opt  = daline.setopt('case.mpc', mpc, 'data.baseType', 'TimeSeriesRand');
            %       data = daline.generate(opt);
            
            % Generate training and testing data
            data = func_generate(varargin{:});
        end
        
        %% noise: pollute training and/or testing data by adding noise
        function data = noise(data, varargin)
            % E.g., data = daline.noise(data, 'noise.switchTrain', 1)
            % E.g., opt  = daline.setopt('noise.switchTrain', 1, 'noise.SNR_dB', 46);
            %       data = daline.noise(data, opt);
            
            % Generate training and testing data
            data = func_add_noise(data, varargin{:});
        end
        
        %% outlier: pollute training and/or testing data by adding outliers
        function data = outlier(data, varargin)
            % E.g., data = daline.outlier(data, 'outlier.switchTrain', 1)
            % E.g., opt  = daline.setopt('outlier.switchTrain', 1, 'outlier.percentage', 3);
            %       data = daline.outlier(data, opt);
            
            % Generate training and testing data
            data = func_add_outlier(data, varargin{:});
        end
        
        %% denoise: filter noise from training and/or testing data
        function data = denoise(data, varargin)
            % E.g., data = daline.denoise(data, 'filNoi.switchTrain', 1)
            % E.g., opt  = daline.setopt('filNoi.switchTrain', 1, 'filNoi.useARModel', false);
            %       data = daline.denoise(data, opt);
            
            % Generate training and testing data
            data = func_filter_noise(data, varargin{:});
        end
        
        %% deoutlier: filter outliers from training and/or testing data
        function data = deoutlier(data, varargin)
            % E.g., data = daline.deoutlier(data, 'filOut.switchTrain', 1);
            % E.g., opt  = daline.setopt('filOut.switchTrain', 1, 'filOut.method', 'quartiles');
            %       data = daline.deoutlier(data, opt);
            
            % Generate training and testing data
            data = func_filter_outlier(data, varargin{:});
        end
        
        %% normalize: normalize training and testing data
        function data = normalize(data, varargin)
            % E.g., data = daline.normalize(data, 'norm.switch', 1);
            % E.g., opt  = daline.setopt('norm.switch', 1);
            %       data = daline.normalize(data, opt);
            
            % Generate training and testing data
            data = func_normalize(data, varargin{:});
        end
        
        %% fit: training and testing models
        function model = fit(data, varargin)
            % E.g., model = daline.fit(data);
            % E.g., model = daline.fit(data, 'method.name', 'RR', 'variable.predictor', {'P', 'Q', 'Vm2'}, 'variable.response', {'Vm2', 'Va', 'PF'})
            % E.g., opt   = daline.setopt('method.name', 'RR', 'RR.lambdaInterval', 0:1e-3:0.02);
            %       model = daline.fit(data, opt);
            
            % Train and test model
            model = func_fit(data, varargin{:});
        end
        
        %% setopt: define option structure according to user's input
        function opt = setopt(varargin)
            % E.g., opt = daline.setopt('method.name', 'RR');
            % E.g., opt = daline.setopt('case.name', 'case39', 'method.name', 'RR');
            
            % Define option structure
            opt = func_set_option(varargin{:});
        end
        
        %% getopt: show default but adjustable options according to user's choice
        function opt = getopt(varargin)
            % E.g., opt = daline.getopt('system', 'RR');
            % E.g., opt = daline.getopt('method');
            
            % Get the default settings for the query target
            opt = func_get_option(varargin{:});
        end
        
        %% plot: plot error results and indicate failed methods
        function varargout = plot(model, varargin)
            % E.g., failedMethod = daline.plot(model);
            % E.g., failedMethod = daline.plot(model, 'PLOT.response', {'Vm','Va'})
            % E.g., opt   = daline.setopt('PLOT.response', {'Vm','Va'});
            %       failedMethod = daline.plot(model, opt);
            
            % Plot error results
            failedMethod = func_plot(model, varargin{:});
            % Generate selective outputs
            if nargout == 1
                varargout{1} = failedMethod;
            end
        end
        
        % Compare and rank different training methods based on error
        function varargout = rank(data, methodList, varargin)
            % E.g., failedMethod = daline.rank(data, {'LS', 'LS_SVD', 'RR'});
            % E.g., [modelList, failedMethod] = daline.rank(data, {'LS', 'LS_SVD', 'RR'}, 'variable.response', {'Vm','Va'})
            % E.g., opt   = daline.setopt('PLOT.response', {'PF','QF'});
            %       [modelList, failedMethod] = daline.rank(data, {'LS', 'LS_SVD', 'RR'}, opt);
            
            % Train, testing, compare, rank, and plot results
            [failedMethod, modelList] = func_rank(data, methodList, varargin{:});
            % Generate selective outputs
            if nargout == 1
                varargout{1} = modelList;
            elseif nargout == 2
                varargout{1} = modelList;
                varargout{2} = failedMethod;
            end
        end
        
        % Compare training methods based on the computing efficiency
        function varargout = time(data, methodList, varargin)
            % E.g., time_list = daline.time(data, {'LS', 'LS_SVD', 'RR'});
            % E.g., [case_list, time_list] = daline.time(data, {'LS', 'LS_SVD', 'RR'}, 'PLOT.style', 'dark')
            % E.g., opt   = daline.setopt('PLOT.repeat', 5);
            %       [case_list, time_list] = daline.time(data, {'LS', 'LS_SVD', 'RR'}, opt);
            
            % Train, testing, compare, rank, and plot results
            [case_list, time_list] = func_efficiency(data, methodList, varargin{:});
            % Generate selective outputs
            varargout{1} = time_list;
            if nargout > 1
                varargout{2} = case_list;
            end
        end
        
    end
end
