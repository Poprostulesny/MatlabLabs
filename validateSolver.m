function [max_error, success, reason, x_my, x_true] = validateSolver(A, b, opts)
% Tests a Hessenberg matrix solving algorithm for Ax=b SLE. Tests against Matlabs built-in function
% Input:
% A - Hessenberg Matrix
% b - answer vector
% (optional) opts - named field of optional values:
%       tolerance - maximum allowed difference between answer and ground truth defaults to 1e-3
%       maxIter - maximum number of iterations defaults to 1e3
% Return:
% max_error - largest difference between the two solution vectors
% success - boolean flag, true if max_error<tolerance
% reason - reason for failing
% x_my - solution vector returned by the solver
% x_true - solution vector obtained by matlabs built-in function
arguments
    A
    b
    opts.tolerance = 1e-3
    opts.maxIter = 1000
end
success=false;
max_error=inf;
x_my=[]; 
x_true=A\b;


try
    [x_my, solver_success, reason, ~]= SolveHessenberg(A, b, tolerance=opts.tolerance, maxIter=opts.maxIter);

catch exc
    warning(exc.message)
    reason=exc.message;
    return;
end

if solver_success~=true
    return;
end


max_error=norm(x_my-x_true,inf);

if any(~isfinite(x_my))
    reason = "Returned NaN or inf";
    return
end


if max_error>=opts.tolerance
    success=false;
    reason = "Solution inaccurate";
else
    success=true;
    reason="ok";
end


end