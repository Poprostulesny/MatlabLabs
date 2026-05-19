function x_new = IterateVectorized(A, b, x)
% Computes one iteration of the Jacobi method for a Hessenberg matrix.
%
% Author:
%   Mateusz Leśniczak
%
% Input:
% A - Hessenberg matrix
% b - right-hand-side vector
% x - current solution vector
% Return:
% x_new - updated solution vector
D = diag(A);
R = A - diag(D);
x_new = (b - R * x) ./ D;

end
