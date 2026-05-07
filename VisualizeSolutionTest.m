% File checking and visualizing how the method works for different matrix types.

% Testing values
tolerance = 1e-4;
maxVal = 1e3;
minSize = 3;
maxSize = 10;
numPerSize = 100;

% Tests
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
