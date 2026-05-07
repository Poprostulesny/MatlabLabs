function [A, b] = GenerateNotFriendlyHessenberg(matrixSize, opts)
% Generates random Hessenberg matrices that satisfy the necessary
% solvability criterion, but take longer to solve.
%   A = D + R
%   Bj = -D^(-1)*R
%   We first choose the matrix Bj with p(Bj) < 1
%   Then R = -DBj
%   Therefore A = D - DBj = D(I - Bj)
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

d = 1 + rand(matrixSize, 1);
D = diag(d);

% Randomly choose an upper or lower Hessenberg matrix.
if randi([0, 1], 1, 1) == 1
    B = tril(randn(matrixSize), 1);
else
    B = triu(randn(matrixSize), -1);
end

% Set diagonal entries to zero.
B(1:matrixSize + 1:end) = 0;

% Force B to have rho(B) < 1.
target_rhoB = 0.95 + (0.999 - 0.95) * rand(1);
rhoB = max(abs(eig(B)));
if rhoB > target_rhoB
    B = target_rhoB * B / rhoB;
end
A = D * (eye(matrixSize) - B);

% Draw the right-hand-side vector.
b = randi([-opts.maxVal, opts.maxVal], matrixSize, 1);
end
