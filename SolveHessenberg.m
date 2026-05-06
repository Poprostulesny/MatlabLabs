function [x, success, steps] = SolveHessenberg(A, b, opts)
% Solves a SLE Ax=b by the Jacobi Method for a Hessenberg Matrix
% Input params:
% A - Hessenberg Matrix, 
% b - result vector, 
% (optional)x - initial guess,
% (optional)tolerance - tolerance with which we want to find the answer,
% (optional)maxIter - maximum number of iterations,
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


success=true;
res = opts.tolerance*10;
steps = 0;


while res>opts.tolerance

    try
        x_new=Iterate(A,b,x);
    catch exc
        error=exc.message;
        success=false;
        x=x_new;
        error(error+" Program execution stopped prematurely.")
    end
    
    steps=steps+1;
    res = norm(x-x_new,inf);
    x=x_new;
    if steps>=opts.maxIter
        success=false;
        return 
    end

end



end
