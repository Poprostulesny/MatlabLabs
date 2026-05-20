function [max_error, success, reason, x_my, x_true] = validateSolver(A, x_ref, opts)
% Tests a Hessenberg linear solver on a system built from a known solution.
%
% Author:
%   Mateusz Leśniczak
%
% Input:
% A - Hessenberg matrix
% x_ref - reference solution vector used to construct b = A * x_ref
% (optional) opts - named field of optional values:
%       tolerance - maximum allowed difference between answer and reference solution defaults to 1e-3
%       maxIter - maximum number of iterations defaults to 1e3
% Return:
% max_error - largest difference between the computed and reference solution vectors
% success - boolean flag, true if max_error < tolerance
% reason - reason for failing
% x_my - solution vector returned by the solver
% x_true - reference solution vector
arguments
    A
    x_ref
    opts.tolerance = 1e-3
    opts.maxIter = 1000
end
success=false;
max_error=inf;
x_my=[]; 
x_true=x_ref;
b=A*x_ref;

try
    [x_my, solver_success, reason, ~]= SolveHessenberg(A, b, tolerance=opts.tolerance, maxIter=opts.maxIter);

catch exc
    warning(exc.message)
    reason=exc.message;
    return;
end
max_error=norm(x_my-x_true,inf);
if solver_success~=true
    return;
end

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
