function x_new = Iterate(A, b, x, isUpper)
% Computes one iteration of the Jacobi method for a Hessenberg matrix.
%
% Author:
%   Mateusz Leśniczak
%
% Input:
% A - Hessenberg matrix
% b - right-hand-side vector
% x - current solution vector
% isUpper - whether the given Hessenberg matrix is an upper Hessenberg matrix
% Return:
% x_new - updated solution vector

n = size(A, 1);
x_new = zeros(n, 1);
D = diag(A);


% Detect whether we are working with an upper or lower Hessenberg matrix.


for y = 1:n
    rowSum = 0;

    % Calculate column bounds for nonzero entries in the current row.
    if isUpper == true
         xStart = max(1, y - 1);
         xEnd = n;
    else
        xStart = 1;
        xEnd = min(n, y + 1);
    end
    
    % Compute the next Jacobi iterate.
    for xi = xStart:xEnd
        if y == xi
            continue
        end
        rowSum = rowSum + A(y, xi) * x(xi);
    end

    % Detect division-by-zero errors.
    if D(y) == 0
        error("Division by zero encountered")
    end
    
    x_new(y) = (b(y) - rowSum) / D(y);
end
end
