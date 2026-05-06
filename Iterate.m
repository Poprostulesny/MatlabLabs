function x_new = Iterate(A, b, x)
% Computes one iteration of the Jacobi method for a Hessenberg matrix
% Input:
% A - Hessenberg Matrix
% b - answer vector
% x - current solution vector
% Return:
% x_new - updated solution array

n = size(A,1);
x_new = zeros(n,1);
D = diag(A);
is_upper=true;

% detecting whether we deal with an upper or a lower hessenberg matrix
if size(A,1)>2 && A(size(A,1),1)~=0
    is_upper=false;
end

for y = 1:n
    rowSum = 0;

    % calculating column coordinates for a given row which are nonzero
    if is_upper==true
         xstart = max(1, y-1);
         xend = n;
    else
        xstart = 1;
        xend = min(n,y+1);
    end
    
    % iteration
    for xi = xstart:xend
        if y==xi
            continue
        end
        rowSum = rowSum + A(y,xi)*x(xi);
    end

    % detecting division by zero errors
    if D(y)==0
        error("Division by zero encountered")
    end
    
    x_new(y) = (b(y)-rowSum)/D(y);
end
end
