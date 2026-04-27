function [success, pass_num, A,b, x_a, x_g] = bulkTest(numIter, maxSize, tolerance)
% Bulk tests the SLE solver for consecutively larger, randomly generated
% Hessenberg matrices. Stops when first divergence encountered
% Input:
% numIter - number of iterations of testing
% maxSize - maximal size of matrix reached during the testing
% (optional)tolerance - error tolerance
% Return:
% success - whether the the solution passed
% pass_num - number of the test on which it stopped
% A - last matrix tested
% b - last solution vector tested
% x_a - answer to the last test from the algorithm
% x_g - ground truth answer by matlabs built in function

arguments
    numIter 
    maxSize 
    tolerance = 1e-5
end


end