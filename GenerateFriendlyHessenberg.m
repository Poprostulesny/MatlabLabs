function [A, x] = GenerateFriendlyHessenberg(matrixSize, opts)
% Generates random Hessenberg matrices that satisfy the necessary
% solvability criterion and have strong diagonal dominance, making them
% ideal candidates for the Jacobi method.
%
% Author:
%   Mateusz Leśniczak
%
% Input params:
% matrixSize - desired size of the square matrix
% (optional) opts - named field of optional values:
%       maxVal - absolute value of the largest possible element in the matrix, defaults to 1e5
% Returns:
% A - Hessenberg matrix
% b - right-hand-side vector

arguments
    matrixSize
    opts.maxVal = 1e5
end

A = randi([-opts.maxVal, opts.maxVal], matrixSize, matrixSize);

if randi([0, 1], 1, 1) == 1
    A = tril(A, 1); % Lower Hessenberg
else
    A = triu(A, -1); % Upper Hessenberg
end

D = diag(diag(A));
rowSums = sum(abs(A - D), 2);

% Draw diagonal values larger than the off-diagonal row sum(2*sum + some random value).
diagVals = 2 * rowSums + randi([1, max(1, opts.maxVal)], matrixSize, 1);

% Draw random signs for the diagonal entries.
signs = 2 * randi([0, 1], matrixSize, 1) - 1;
A = A - D + diag(diagVals .* signs);

% Draw the right-hand-side vector.
x = randi([-opts.maxVal, opts.maxVal], matrixSize, 1);
end
