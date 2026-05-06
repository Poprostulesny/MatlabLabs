function [x, success, reason, steps] = SolveHessenberg(A, b, opts)
% Solves a SLE Ax=b by the Jacobi Method for a Hessenberg Matrix.
% Input params:
% A - Hessenberg Matrix, 
% b - result vector, 
% (optional) opts - named field of optional values:
%       x - initial guess, defaults to zero vector,
%       tolerance - tolerance with which we want to find the answer defaults to 1e-6,
%       maxIter - maximum number of iterations defaults to 1e3,
% Returns:
% x - the solution array, 
% success - whether the method succeeded, or error value
% steps - the number of steps it took
arguments
    A
    b
    opts.tolerance = 1e-6
    opts.maxIter = 1000
end


x = zeros(size(A,1),1);

% initializing return values
success=true;
res = opts.tolerance*10;
steps = 0;
reason="ok";

% testing loop
while res>opts.tolerance && residual>opts.tolerance

    try
        x_new=Iterate(A,b,x);
    catch exc
       
        success=false;
        reason=exc.message;
        return;
    end
    
    steps=steps+1;
    
    % calculating stoping condition 
    residual = norm(A*x-b,inf);
    res = norm(x-x_new,inf);
    x=x_new;

    if steps>=opts.maxIter
        success=false;
        reason="Solving took too long";
        return 
    end

end

end
