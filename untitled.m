tolerance = 1e-4;
maxVal=1e3;
minSize=3;
maxSize=10;
numPerSizes = 100;
[~, pass_num, fail_num,fail_reason, A_fail, b_fail, x_alg, x_true, succ_rand, med_rand, sizes] = bulkTest(minSize, maxSize, maxVal=maxVal, numPerSize=numPerSizes, tolerance=tolerance, generator=@GenerateRandomHessenberg);
[~,~,~,~,~,~,~,~,succ_hard, med_hard,~]= bulkTest(minSize, maxSize, maxVal=maxVal, numPerSize=numPerSizes, tolerance=tolerance, generator=@GenerateNotFriendlyHessenberg);
[~,~,~,~,~,~,~,~,succ_easy, med_eas,~]= bulkTest(minSize, maxSize, maxVal=maxVal, numPerSize=numPerSizes, tolerance=tolerance, generator=@GenerateFriendlyHessenberg);



figure;
plot(sizes, succ_rand/numPerSizes, '-o', 'LineWidth', 1.5);
hold on;
plot(sizes, succ_hard/numPerSizes, '-s', 'LineWidth', 1.5);
plot(sizes, succ_easy/numPerSizes, '-^', 'LineWidth', 1.5);
grid on;
xlabel("Matrix size");
ylabel("Success rate");
title("Jacobi success rate for different Hessenberg generators");
legend("Random Hessenberg Matrix", "Not friendly Hessenberg", "Friendly Hesssenberg", "Location", 'Best');

