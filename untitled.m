tolerance = 1e-4;
maxVal=1e3;
minSize=3;
maxSize=100;
numPerSizes = 10;
[~, pass_num, fail_num,fail_reason, A_fail, b_fail, x_alg, x_true, succ_rand, med_rand, sizes] = bulkTest(minSize, maxSize, maxVal=maxVal, numPerSize=numPerSizes, tolerance=tolerance, generator=@GenerateRandomHessenberg);
[~,~,~,~,~,~,~,~,succ_hard, med_hard,~]= bulkTest(minSize, maxSize, maxVal=maxVal, numPerSize=numPerSizes, tolerance=tolerance, generator=@GenerateNotFriendlyHessenberg);
[~,~,~,~,~,~,~,~,succ_easy, med_eas,~]= bulkTest(minSize, maxSize, maxVal=maxVal, numPerSize=numPerSizes, tolerance=tolerance, generator=@GenerateFriendlyHessenberg);

any(isnan(med_rand))
any(isinf(med_rand))
find(isnan(med_rand) | isinf(med_rand))
max(med_rand(isfinite(med_rand)))

figure;
plot(sizes, med_rand, '-o', 'LineWidth', 1.5);
hold on;
plot(sizes, med_hard, '-s', 'LineWidth', 1.5);
plot(sizes, med_eas, '-^', 'LineWidth', 1.5);
hold off;

grid on;
xlabel('Matrix size');
ylabel('Median error');
title('Jacobi success rate for different Hessenberg generators');

legend('Random Hessenberg', 'Not friendly Hessenberg', 'Friendly Hessenberg', ...
       'Location', 'best');


allValsNoOut = rmoutliers([med_eas(:); med_hard(:); med_rand(:)]);
ymax = max(allValsNoOut) + tolerance;
ylim([0, ymax]);