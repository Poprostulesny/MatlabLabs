function [allPassed, pass_num, fail_num, fail_reason, A_fail, b_fail, x_alg, x_true, success_by_size,median_err_by_size, sizes] = bulkTest(minSize, maxSize, opts)
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
% pass_num - number of passed tests
% fail_num - number of failed tests
% fail_reason - reason for the last failure encountered
% A_fail - last matrix for which the solution failed
% b_fail - last vector for which the solution failed
% x_alg - answer to the last test from the algorithm
% x_true - ground truth answer by matlabs built in function
% success_by_size - no. of passed tests for each matrix size
% median_err_by_size - median error for each matrix size
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

% initializing return values
sizes= ceil(minSize):(maxSize);
median_err_by_size = NaN(numel(sizes),1);
success_by_size = zeros(numel(sizes),1);
allPassed=true;
fail_num=0;
pass_num=0;
A_fail=[];
b_fail=[];
x_alg=[];
x_true=[];
y=1;
fail_reason="ok";

% testing phase
for s = sizes
    succ_loc=0;
    errors = NaN(opts.numPerSize,1);

    % testing pass for a given size
    for i=1:opts.numPerSize

        [A,b] = opts.generator(s, maxVal=opts.maxVal);
        [errors(i), is_acc, fr, x_alg, x_true]= validateSolver(A, b, tolerance=opts.tolerance, maxIter=opts.maxIter);

        if is_acc==true
            pass_num=pass_num+1;
            succ_loc=succ_loc+1;
        else
            allPassed=false;
            fail_num=fail_num+1;
            A_fail=A;
            b_fail=b;
            fail_reason=fr;
            if opts.stopAtFirst
                warning("Stopped prematurely due to the stopAtFirst flag being set. Most analysis arrays will therefore be incomplete.")
                return;
            end
        end
       
    end
    
    %calculating data used for analysis
    valid_errors = abs(errors);
    median_err_by_size(y) = median(valid_errors, "omitnan");

    if(all(isnan(valid_errors)))
        median_err_by_size(y)=Nan;
    end
    success_by_size(y)=succ_loc;

    y=y+1;
end
end
