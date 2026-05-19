function x_new = Iterate(A, b, x)
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

n = size(A, 1);
x_new = zeros(n, 1);
D = diag(A);
isUpper = true;

% Detect whether we are working with an upper or lower Hessenberg matrix.
if size(A, 1) > 2 && A(size(A, 1), 1) ~= 0
    isUpper = false;
end

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
