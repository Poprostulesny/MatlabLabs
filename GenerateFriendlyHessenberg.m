function [A,b] = GenerateFriendlyHessenberg(size, opts)
% Generates random Hessenberg matrices which sattisfy the necessary
% solvability criterion, and have strong diagonal dominance - ideal candidates for solving by Jacobi method
% Input params:
% size - desired size of the square matrix
% (optional) opts - named field of optional values:
%       maxVal - absolute value of the biggest possible element in the matrix, defaults to 1e5
% Returns:
% A - Hessenberg Matrix, 
% b - RHS of equation, 

arguments
    size
    opts.maxVal = 1e5
end
A=randi([-opts.maxVal, opts.maxVal],size,size);

if randi([0,1],1,1)==1
    A = tril(A,1);%lower hessenberg
else
    A = triu(A,-1);%upper hessenberg
end



D = diag(diag(A));
rowSums= sum(abs(A-D),2);

%losowanie wartości na przekatnej (suma wartosci w rzedzie + losowa liczba)
diagVals = 2*rowSums + randi([1, max(1, opts.maxVal)],size,1);
%losowanie znaku dla przekatnej
signs = 2*randi([0,1],size,1)-1;
A = A-D+diag(diagVals.*signs);

%losowanie b
b = randi([-opts.maxVal, opts.maxVal],size,1);
end
