function [A, b] = GenerateRandomHessenberg(matrixSize, opts)
% Generates a random Hessenberg matrix with a reasonable condition number
% and no zeros on the diagonal.
% Input params:
% matrixSize - desired size of the square matrix
% (optional) opts - named field of optional values:
%       maxVal - absolute value of the largest possible element in the matrix, defaults to 1e3
% Returns:
% A - Hessenberg matrix
% b - right-hand-side vector

arguments
    matrixSize
    opts.maxVal = 1e3
end

A = randi([-opts.maxVal, opts.maxVal], matrixSize, matrixSize);

if randi([0, 1], 1, 1) == 1
    A = tril(A, 1); % Lower Hessenberg
else
    A = triu(A, -1); % Upper Hessenberg
end

while rcond(A) < 1e-10
    A = randi([-opts.maxVal, opts.maxVal], matrixSize, matrixSize);

    if randi([0, 1], 1, 1) == 1
        A = tril(A, 1); % Lower Hessenberg
    else
        A = triu(A, -1); % Upper Hessenberg
    end
end

% Draw the right-hand-side vector.
b = randi([-opts.maxVal, opts.maxVal], matrixSize, 1);
end
