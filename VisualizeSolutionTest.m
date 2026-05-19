% File checking and visualizing how the method works for different matrix types.
%
% Author:
%   Mateusz Leśniczak

% Testing values for method testing
tolerance = 1e-4;
maxVal = 1e3;
minSize = 3;
maxSize = 100;
numPerSize = 10;

% Program tests - matrices of size 6-10.
programTestSizes = 6:10;


%For convergent matrices
programTestsForConvergentMatrices = struct([]);

for testIdx = 1:numel(programTestSizes)
    matrixSize = programTestSizes(testIdx);
    [A, X] = GenerateFriendlyHessenberg(matrixSize, maxVal=maxVal);
    B = A * X;
    [X_solution, solverSuccess, reason, steps] = SolveHessenberg(A, B, tolerance=tolerance);
    solutionError = norm(X_solution - X, inf);

    programTestsForConvergentMatrices(testIdx).matrixSize = matrixSize;
    programTestsForConvergentMatrices(testIdx).A = A;
    programTestsForConvergentMatrices(testIdx).X = X;
    programTestsForConvergentMatrices(testIdx).B = B;
    programTestsForConvergentMatrices(testIdx).X_solution = X_solution;
    programTestsForConvergentMatrices(testIdx).solutionError = solutionError;
    programTestsForConvergentMatrices(testIdx).solverSuccess = solverSuccess;
    programTestsForConvergentMatrices(testIdx).reason = reason;
    programTestsForConvergentMatrices(testIdx).steps = steps;
    testIdx
    A
    X
    X_solution
    solverSuccess
    reason
    
end

%For barely convergent Matrices(with spectral radius very close to 1)
programTestsForBarelyConvergentMatrices= struct([]);

for testIdx = 1:numel(programTestSizes)
    matrixSize = programTestSizes(testIdx);
    [A, X] = GenerateNotFriendlyHessenberg(matrixSize, maxVal=maxVal, difficulty=0.98);
    B = A * X;
    [X_solution, solverSuccess, reason, steps] = SolveHessenberg(A, B, tolerance=tolerance);
    solutionError = norm(X_solution - X, inf);

    programTestsForBarelyConvergentMatrices(testIdx).matrixSize = matrixSize;
    programTestsForBarelyConvergentMatrices(testIdx).A = A;
    programTestsForBarelyConvergentMatrices(testIdx).X = X;
    programTestsForBarelyConvergentMatrices(testIdx).B = B;
    programTestsForBarelyConvergentMatrices(testIdx).X_solution = X_solution;
    programTestsForBarelyConvergentMatrices(testIdx).solutionError = solutionError;
    programTestsForBarelyConvergentMatrices(testIdx).solverSuccess = solverSuccess;
    programTestsForBarelyConvergentMatrices(testIdx).reason = reason;
    programTestsForBarelyConvergentMatrices(testIdx).steps = steps;
    testIdx
    A
    X
    X_solution
    solverSuccess
    reason
    
end

%For random Matrices
programTestsForRandomMatrices= struct([]);

for testIdx = 1:numel(programTestSizes)
    matrixSize = programTestSizes(testIdx);
    [A, X] = GenerateRandomHessenberg(matrixSize, maxVal=maxVal);
    B = A * X;
    [X_solution, solverSuccess, reason, steps] = SolveHessenberg(A, B, tolerance=tolerance);
    solutionError = norm(X_solution - X, inf);

    programTestsForRandomMatrices(testIdx).matrixSize = matrixSize;
    programTestsForRandomMatrices(testIdx).A = A;
    programTestsForRandomMatrices(testIdx).X = X;
    programTestsForRandomMatrices(testIdx).B = B;
    programTestsForRandomMatrices(testIdx).X_solution = X_solution;
    programTestsForRandomMatrices(testIdx).solutionError = solutionError;
    programTestsForRandomMatrices(testIdx).solverSuccess = solverSuccess;
    programTestsForRandomMatrices(testIdx).reason = reason;
    programTestsForRandomMatrices(testIdx).steps = steps;
    testIdx
    A
    X
    X_solution
    solverSuccess
    reason
    
end




programTestSummary = struct();
programTestSummary.convergentMatrices = struct2table(rmfield(programTestsForConvergentMatrices, ["A", "X", "B", "X_solution"]));
programTestSummary.barelyConvergentMatrices = struct2table(rmfield(programTestsForBarelyConvergentMatrices, ["A", "X", "B", "X_solution"]));
programTestSummary.randomMatrices = struct2table(rmfield(programTestsForRandomMatrices, ["A", "X", "B", "X_solution"]));


% Method tests

[~, passCount, failCount, failReason, A_fail, b_fail, x_alg, x_true, successRandom, medianRandom, sizes] = bulkTest(minSize, maxSize, maxVal=maxVal, numPerSize=numPerSize, tolerance=tolerance, generator=@GenerateRandomHessenberg);
[~, ~, ~, ~, ~, ~, ~, ~, successHard, medianHard, ~] = bulkTest(minSize, maxSize, maxVal=maxVal, numPerSize=numPerSize, tolerance=tolerance, generator=@GenerateNotFriendlyHessenberg);
[~, ~, ~, ~, ~, ~, ~, ~, successEasy, medianEasy, ~] = bulkTest(minSize, maxSize, maxVal=maxVal, numPerSize=numPerSize, tolerance=tolerance, generator=@GenerateFriendlyHessenberg);


% Plotting the data
figure;
plot(sizes, successRandom / numPerSize, '-o', 'LineWidth', 1.5);
hold on;
plot(sizes, successHard / numPerSize, '-s', 'LineWidth', 1.5);
plot(sizes, successEasy / numPerSize, '-^', 'LineWidth', 1.5);
grid on;
xlabel("Matrix size");
ylabel("Success rate");
title("Jacobi success rate for different Hessenberg generators");
legend("Random Hessenberg Matrix", "Not Friendly Hessenberg", "Friendly Hessenberg", "Location", "Best");
