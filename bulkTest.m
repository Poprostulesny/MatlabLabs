function [allPassed, passCount, failCount, failReason, A_fail, b_fail, x_alg, x_true, successBySize, medianErrorBySize, sizes] = bulkTest(minSize, maxSize, opts)
% Bulk tests the SLE solver for consecutively larger, randomly generated
% Hessenberg matrices.
% Input:
% minSize - minimal size of matrix used during the testing
% maxSize - maximal size of matrix reached during the testing
% (optional) opts - named field of optional values:
%       maxVal - maximal value of a point in a matrix, defaults to 1e3
%       numPerSize - no. of times a single matrix size is tested, defaults to 100
%       tolerance - error tolerance, defaults to 1e-4
%       maxIter - maximal no. of solver iterations, defaults to 1e3
%       generator - function handle for the matrix generator, defaults to GenerateRandomHessenberg
%       stopAtFirst - boolean flag describing whether the function should stop at the first failed matrix, however then most of the analysis tables will be incomplete, defaults to false
% Return:
% allPassed - whether all of the solutions passed
% passCount - number of passed tests
% failCount - number of failed tests
% failReason - reason for the last failure encountered
% A_fail - last matrix for which the solution failed
% b_fail - last vector for which the solution failed
% x_alg - answer to the last test from the algorithm
% x_true - ground truth answer from MATLAB's built-in solver
% successBySize - number of passed tests for each matrix size
% medianErrorBySize - median error for each matrix size
% sizes - vector of tested matrix sizes

arguments
    minSize
    maxSize
    opts.maxVal = 1e3
    opts.numPerSize = 3
    opts.tolerance = 1e-4
    opts.maxIter = 1000
    opts.generator = @GenerateRandomHessenberg
    opts.stopAtFirst = false;
end

% Initialize return values.
sizes = ceil(minSize):maxSize;
medianErrorBySize = NaN(numel(sizes), 1);
successBySize = zeros(numel(sizes), 1);
allPassed = true;
failCount = 0;
passCount = 0;
A_fail = [];
b_fail = [];
x_alg = [];
x_true = [];
sizeIdx = 1;
failReason = "ok";

% Testing phase.
for s = sizes
    successCountForSize = 0;
    errors = NaN(opts.numPerSize, 1);

    % Testing pass for a given size.
    for i = 1:opts.numPerSize

        [A, b] = opts.generator(s, maxVal=opts.maxVal);
        [errors(i), isAccepted, failureReason, x_alg, x_true] = validateSolver(A, b, tolerance=opts.tolerance, maxIter=opts.maxIter);

        if isAccepted == true
            passCount = passCount + 1;
            successCountForSize = successCountForSize + 1;
        else
            allPassed = false;
            failCount = failCount + 1;
            A_fail = A;
            b_fail = b;
            failReason = failureReason;
            if opts.stopAtFirst
                warning("Stopped prematurely due to the stopAtFirst flag being set. Most analysis arrays will therefore be incomplete.")
                return;
            end
        end
       
    end
    
    % Calculate data used for analysis.
    valid_errors = abs(errors);
    medianErrorBySize(sizeIdx) = median(valid_errors, "omitnan");

    if all(isnan(valid_errors))
        medianErrorBySize(sizeIdx) = NaN;
    end
    successBySize(sizeIdx) = successCountForSize;

    sizeIdx = sizeIdx + 1;
end

end
