function x_new = Iterate(A, b, x)
% Computes one iteration of the Jacobi method for a Hessenberg matrix
% Input:
% A - Hessenberg Matrix
% b - answer vector
% x - current solution vector
% Return:
% x_new - updated solution array
D=diag(A);
R= A-diag(D);
x_new = (b-R*x) ./D;

end