function func_cvx_solver(solver_str)

switch solver_str
    case 'Mosek'
        cvx_solver 'Mosek'
    case 'Gurobi'
        cvx_solver 'Gurobi'
    case 'SDPT3'
        cvx_solver 'SDPT3'
    case 'SeDuMi'
        cvx_solver 'SeDuMi'
end