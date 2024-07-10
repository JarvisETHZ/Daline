function [mpcreduced,BCIRC,ExBus] = DoReduction(DataB,ERP,CIndx,ExBus,NUMB,dim,BCIRC,newbusnum,oldbusnum,mpc)
% Subroutine DoReduction create the reduced network based on input network
% data.
%
%   [mpcreduced,BCIRC,ExBus] = DoReduction(DataB,ERP,CIndx,ExBus,NUMB,dim,BCIRC,newbusnum,oldbusnum,mpc,label)
%
% INPUT DATA:
%   DataB: 1*n array, admittance value in input admittance matrix
%   ERP: 1*n array, end of row pointer of the input admittance matrix
%   CIndx: 1*n array, column indices of every row of the input admittance
%       matrix.
%   ExBus: 1*n array, external bus indices
%   NUMB: 1*n array, bus indices
%   dim: scalar, dimension of the input admittance matrix (should be square)
%   BCIRC: 1*n array, branch circuit number
%   newbusnum: 1*n array, internal bus indices
%   oldbusnum: 1*n array, original bus indices
%
% OUTPUT DATA:
%   mpcreduced: struct, reduced model, without external generator placement
%       and load redistribution
%   BCIRC: updated branch circuit number
%   ExBus: updated external bus indices
%
% NOTE: The reduced model generated by this subroutine doesn't involve
% external generator placement and load redistribution. It's only good for
% analyze the reduced network (toplogy+reactance).

%   MATPOWER
%   Copyright (c) 2014-2016, Power Systems Engineering Research Center (PSERC)
%   by Yujia Zhu, PSERC ASU
%
%   This file is part of MATPOWER.
%   Covered by the 3-clause BSD License (see LICENSE file for details).
%   See http://www.pserc.cornell.edu/matpower/ for more info.

%% Define Boundary Buses
[BoundBus]=DefBoundary(mpc,ExBus);
%% Do Pivot including Tinney One
[DataB,ERP,CIndx,PivOrd,PivInd] = PivotData(DataB,ERP,CIndx,ExBus,NUMB,BoundBus);
%% Do LU factorization (Partial)
[ERPU,CIndxU,ERPEQ,CIndxEQ] = PartialSymLU(CIndx,ERP,dim,length(ExBus),BoundBus);
[DataEQ,DataShunt] = PartialNumLU (CIndx,CIndxU,DataB,dim,ERP,ERPU,length(ExBus),ERPEQ,CIndxEQ,BoundBus);
%% Create the reduced model in MATPOWER format
[mpcreduced,BCIRC,ExBus] = MakeMPCr(ERPEQ,DataEQ,CIndxEQ,DataShunt,ERP,DataB,ExBus,PivInd,PivOrd,BCIRC,newbusnum,oldbusnum,mpc,BoundBus);
end