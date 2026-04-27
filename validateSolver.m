function [max_error, is_accurate] = validateSolver(A, b, tolerance)
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
    tolerance = 1e-5
end

end