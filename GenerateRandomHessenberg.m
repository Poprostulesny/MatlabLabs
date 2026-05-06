function [A,b] = GenerateRandomHessenberg(size, opts)
% Generates a random Hessenberg matrix, with a sensible conditional number and no zeros on the diagonal
% Input params:
% size - desired size of the square matrix
% (optional) opts - named field of optional values:
%       maxVal - absolute value of the biggest possible element in the matrix, defaults to 1e5
% Returns:
% A - Hessenberg Matrix, 
% b - RHS of equation, 

arguments
    size
    opts.maxVal = 1e3
end

A=randi([-opts.maxVal, opts.maxVal],size,size);

if randi([0,1],1,1)==1
    A = tril(A,1);%lower hessenberg
else
    A = triu(A,-1);%upper hessenberg
end
while rcond(A)<1e-10
    A=randi([-opts.maxVal, opts.maxVal],size,size);

    if randi([0,1],1,1)==1
        A = tril(A,1);%lower hessenberg
    else
        A = triu(A,-1);%upper hessenberg
    end
end
%losowanie b
b = randi([-opts.maxVal, opts.maxVal],size,1);
end
