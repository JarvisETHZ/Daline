function [errorStruct, predStruct, trueStruct] = func_split_error_BDLY2(Y, error, Y_pred, Y_true)
%
%  Only valid when Y_test = Y.test.all and when using partial least squares
%  with bundling variables
%  The columns of error are sorted as:
%  Y.test.Va, Y.test.Vm, Y.test.PF, Y.test.PT, Y.test.QF, Y.test.QT, Y.test.P, Y.test.Q

% get numbers for error separations
num_Y_Va = size(Y.test.Va, 2);
num_Y_Vm = size(Y.test.Vm, 2);
num_Y_PF = size(Y.test.PF, 2);
num_Y_PT = size(Y.test.PT, 2);
num_Y_QF = size(Y.test.QF, 2);
num_Y_QT = size(Y.test.QT, 2);
num_Y_P  = size(Y.test.P,  2);
num_Y_Q  = size(Y.test.Q,  2);

% separate the error into different categories
count = 0;
errorStruct.Va = error(:,  count + 1 : count + num_Y_Va);
predStruct.Va = Y_pred(:,  count + 1 : count + num_Y_Va);
trueStruct.Va = Y_true(:,  count + 1 : count + num_Y_Va);

count = count + num_Y_Va;
errorStruct.Vm = error(:,  count + 1 : count + num_Y_Vm);
predStruct.Vm = Y_pred(:,  count + 1 : count + num_Y_Vm);
trueStruct.Vm = Y_true(:,  count + 1 : count + num_Y_Vm);

count = count + num_Y_Vm;
errorStruct.PF = error(:,  count + 1 : count + num_Y_PF);
predStruct.PF = Y_pred(:,  count + 1 : count + num_Y_PF);
trueStruct.PF = Y_true(:,  count + 1 : count + num_Y_PF);

count = count + num_Y_PF;
errorStruct.PT = error(:,  count + 1 : count + num_Y_PT);
predStruct.PT = Y_pred(:,  count + 1 : count + num_Y_PT);
trueStruct.PT = Y_true(:,  count + 1 : count + num_Y_PT);

count = count + num_Y_PT;
errorStruct.QF = error(:,  count + 1 : count + num_Y_QF);
predStruct.QF = Y_pred(:,  count + 1 : count + num_Y_QF);
trueStruct.QF = Y_true(:,  count + 1 : count + num_Y_QF);

count = count + num_Y_QF;
errorStruct.QT = error(:,  count + 1 : count + num_Y_QT);
predStruct.QT = Y_pred(:,  count + 1 : count + num_Y_QT);
trueStruct.QT = Y_true(:,  count + 1 : count + num_Y_QT);

count = count + num_Y_QT;
errorStruct.P = error(:,  count + 1 : count + num_Y_P);
predStruct.P = Y_pred(:,  count + 1 : count + num_Y_P);
trueStruct.P = Y_true(:,  count + 1 : count + num_Y_P);

count = count + num_Y_P;
errorStruct.Q = error( :,  count + 1 : count + num_Y_Q);
predStruct.Q  = Y_pred(:,  count + 1 : count + num_Y_Q);
trueStruct.Q  = Y_true(:,  count + 1 : count + num_Y_Q);

errorStruct.all = error;