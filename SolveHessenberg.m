function [x, success, steps] = SolveHessenberg(A,b, x, tolerance, maxIter)
% Solves a SLE Ax=b by the Jacobi Method for a Hessenberg Matrix
% Input params:
% A - Hessenberg Matrix, 
% b - result vector, 
% (optional)x - initial guess,
% (optional)tolerance - tolerance with which we want to find the answer,
% (optional)maxIter - maximum number of iterations,
% Returns:
% x - the solution array, 
% success - whether the method succeeded,
% steps - the number of steps it took
arguments
    A 
    b 
    x = zeros(size(A,1),1)
    tolerance = 1e-6
    maxIter = 10000
end
end