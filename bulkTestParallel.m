function [allPassed, passCount, failCount, failReason, A_fail, b_fail, x_alg, x_true, successBySize, medianErrorBySize, sizes] = bulkTestParallel(minSize, maxSize, opts)
% Bulk tests the SLE solver for consecutively larger, randomly generated
% Hessenberg matrices, parallelizing the per-size test runs with PARFOR.
%
% Author:
%   Mateusz Leśniczak
%
% Input:
% minSize - minimal size of matrix used during the testing
% maxSize - maximal size of matrix reached during the testing
% (optional) opts - named field of optional values:
%       maxVal - maximal value of a point in a matrix, defaults to 1e3
%       numPerSize - no. of times a single matrix size is tested, defaults to 100
%       tolerance - error tolerance, defaults to 1e-4
%       maxIter - maximal no. of solver iterations, defaults to 1e3
%       generator - function handle for the matrix generator, defaults to GenerateRandomHessenberg
%       stopAtFirst - accepted for compatibility; PARFOR cannot stop early
% Return:
% allPassed - whether all of the solutions passed
% passCount - number of passed tests
% failCount - number of failed tests
% failReason - reason for the last failure encountered
% A_fail - last matrix for which the solution failed
% b_fail - last vector for which the solution failed
% x_alg - answer to the last failed test from the algorithm
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

if opts.stopAtFirst
    warning("bulkTestParallel ignores stopAtFirst because PARFOR iterations cannot exit early.");
end

sizes = ceil(minSize):(maxSize);
medianErrorBySize = NaN(numel(sizes), 1);
successBySize = zeros(numel(sizes), 1);
allPassed = true;
failCount = 0;
passCount = 0;
A_fail = [];
b_fail = [];
x_alg = [];
x_true = [];
failReason = "ok";
tic
for y = 1:numel(sizes)
    s = sizes(y);

    errors = NaN(opts.numPerSize, 1);
    success_flags = false(opts.numPerSize, 1);
    fail_reasons_local = strings(opts.numPerSize, 1);
    A_local = cell(opts.numPerSize, 1);
    b_local = cell(opts.numPerSize, 1);
    x_alg_local = cell(opts.numPerSize, 1);
    x_true_local = cell(opts.numPerSize, 1);
    parfor i = 1:opts.numPerSize
        [A_i, b_i] = opts.generator(s, maxVal=opts.maxVal);
        [errors(i), success_flags(i), fail_reasons_local(i), x_alg_i, x_true_i] = ...
            validateSolver(A_i, b_i, tolerance=opts.tolerance, maxIter=opts.maxIter);

        A_local{i} = A_i;
        b_local{i} = b_i;
        x_alg_local{i} = x_alg_i;
        x_true_local{i} = x_true_i;
    end

    successBySize(y) = sum(success_flags);
    passCount = passCount + successBySize(y);

    failed_idx = find(~success_flags);
    failCount = failCount + numel(failed_idx);
    if ~isempty(failed_idx)
        allPassed = false;
        last_fail = failed_idx(end);
        A_fail = A_local{last_fail};
        b_fail = b_local{last_fail};
        x_alg = x_alg_local{last_fail};
        x_true = x_true_local{last_fail};
        failReason = fail_reasons_local(last_fail);
    end

    valid_errors = abs(errors);
    medianErrorBySize(y) = median(valid_errors, "omitnan");
    if all(isnan(valid_errors))
        medianErrorBySize(y) = NaN;
    end
end
toc
end
