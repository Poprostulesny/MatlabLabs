function [x, success, reason, steps] = SolveHessenberg(A, b, opts)
% Solves the linear system Ax = b using the Jacobi method for a Hessenberg matrix.
% Input params:
% A - Hessenberg matrix
% b - right-hand-side vector
% (optional) opts - named field of optional values:
%       tolerance - tolerance with which we want to find the answer, defaults to 1e-6
%       maxIter - maximum number of iterations, defaults to 1e3
% Returns:
% x - solution vector
% success - whether the method succeeded
% reason - reason for failure, or "ok" on success
% steps - number of iterations performed
arguments
    A
    b
    opts.tolerance = 1e-6
    opts.maxIter = 1000
end

x = zeros(size(A, 1), 1);

% Initialize return values.
success = true;
steps = 0;
reason = "ok";

% Iteration loop.
while true

    try
        x_new = Iterate(A, b, x);
    catch exc
        success = false;
        reason = exc.message;
        return;
    end
    
    steps = steps + 1;
    
    % Evaluate stopping conditions on the new iterate.
    res = norm(x - x_new, inf);
    residual = norm(A * x_new - b, inf);
    x = x_new;

    if res <= opts.tolerance || residual <= opts.tolerance
        break;
    end

    if steps >= opts.maxIter
        success = false;
        reason = "Solving took too long";
        return
    end

end

end
