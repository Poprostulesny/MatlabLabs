function x = isSolvable(A)
%Checks whether the given matrix is solvable by the Jacobi method
% Input:
% A - Hessenberg Matrix
% Return:
% x - boolean true or false

%finding the iteration matrix
D = diag(A);
IT = -inv(diag(D))*(A-diag(D));
spect_radi= max(abs(eig(IT)));
if spect_radi>1.0
    x=false;
else
    x=true;
end
end