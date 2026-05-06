function [max_error, is_accurate, reason, solver_success, x_my, x_true] = validateSolver(A, b, opts)
% Tests a Hessenberg matrix solving algorithm for Ax=b SLE
% Input:
% A - Hessenberg Matrix
% b - answer vector
% (optional)tolerance - maximum allowed difference between answer and
% ground truth
% Return:
% max_error - largest difference between the two solution vectors
% is_accurate - boolean flag, true if max_error<tolerance
arguments
    A
    b
    opts.tolerance = 1e-3
    opts.maxIter = 1000
end
is_accurate=false;
max_error=inf;
solver_success=false;
x_my=[]; 
x_true=A\b;


try
    [x_my, solver_success, steps]= SolveHessenberg(A, b, tolerance=opts.tolerance, maxIter=opts.maxIter);

catch exc
    warning(exc.message)
    reason=exc.message;
    return;
end

max_error=norm(x_my-x_true,inf);

if steps >= opts.maxIter
    reason = "Didn't converge in specified time";
    return;
end

if any(~isfinite(x_my))
    reason = "Returned NaN or inf";
    return
end

if max_error>=opts.tolerance
    is_accurate=false;
    reason = "Solution inaccurate";
else
    is_accurate=true;
    reason="ok";
end

end
