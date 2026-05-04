function [allPassed, pass_num, fail_num, fail_reason, A_fail, b_fail, x_alg, x_true, success_by_size,median_err_by_size, sizes] = bulkTest(minSize, maxSize, opts)
% Bulk tests the SLE solver for consecutively larger, randomly generated
% Hessenberg matrices. Stops when first divergence encountered
% Input:
% numTest - number of iterations of testing
% minSize - minimal size of matrix used during the testing
% maxSize - maximal size of matrix reached during the testing
% maxVal - maximal value of a point in a matrix
% numPerSize - no. of times a single matrix size is tested
% (optional)tolerance - error tolerance
% Return:
% success - whether the the solution passed
% pass_num - number of the test on which it stopped
% A - last matrix tested
% b - last solution vector tested
% x_a - answer to the last test from the algorithm
% x_g - ground truth answer by matlabs built in function

arguments
    minSize
    maxSize
    opts.maxVal = 1e3
    opts.numPerSize = 3
    opts.tolerance = 1e-4
    opts.maxIter = 1000
    opts.generator = @GenerateRandomHessenberg
end


sizes= ceil(minSize):(maxSize);
median_err_by_size = zeros(size(sizes,1),1);
success_by_size = zeros(size(sizes,1),1);
allPassed=true;
fail_num=0;
pass_num=0;
A_fail=[];
b_fail=[];
x_alg=[];
x_true=[];
y=1;
fail_reason="ok";
for s = sizes
    succ_loc=0;
    errors = zeros(opts.numPerSize,1);
    for i=1:opts.numPerSize
        [A,b] = opts.generator(s, maxVal=opts.maxVal);
        
        [errors(i), is_acc, fr,~, x_alg, x_true]= validateSolver(A, b, tolerance=opts.tolerance, maxIter=opts.maxIter);
        if is_acc==true
            pass_num=pass_num+1;
            succ_loc=succ_loc+1;
        else
            allPassed=false;
            fail_num=fail_num+1;
            A_fail=A;
            b_fail=b;
            fail_reason=fr;
        end
       
    end
    median_err_by_size(y)=median(abs(errors));
    success_by_size(y)=succ_loc;
    y=y+1;
end
end
