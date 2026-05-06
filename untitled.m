tolerance = 1e-4;
maxVal=1e3;
minSize=3;
maxSize=10;
numPerSizes = 100;
[~, pass_num, fail_num,fail_reason, A_fail, b_fail, x_alg, x_true, succ_rand, med_rand, sizes] = bulkTest(minSize, maxSize, maxVal=maxVal, numPerSize=numPerSizes, tolerance=tolerance, generator=@GenerateRandomHessenberg);
[~,~,~,~,~,~,~,~,succ_hard, med_hard,~]= bulkTest(minSize, maxSize, maxVal=maxVal, numPerSize=numPerSizes, tolerance=tolerance, generator=@GenerateNotFriendlyHessenberg);
[~,~,~,~,~,~,~,~,succ_easy, med_eas,~]= bulkTest(minSize, maxSize, maxVal=maxVal, numPerSize=numPerSizes, tolerance=tolerance, generator=@GenerateFriendlyHessenberg);



figure;
randPlot = plot(sizes, med_rand, '-o', 'LineWidth', 1.5);
hold on;
hardPlot = plot(sizes, med_hard, '-s', 'LineWidth', 1.5);
easyPlot = plot(sizes, med_eas, '-^', 'LineWidth', 1.5);

grid on;
xlabel('Matrix size');
ylabel('Median error');
title('Jacobi success rate for different Hessenberg generators');

legend('Random Hessenberg', 'Not friendly Hessenberg', 'Friendly Hessenberg', ...
       'Location', 'best');


allVals = [med_eas(:); med_hard(:); med_rand(:)];
allVals = allVals(isfinite(allVals));
allValsNoOut = rmoutliers(allVals);
if isempty(allValsNoOut)
    allValsNoOut = 1;
end
ymax = max(allValsNoOut) + tolerance;
ymin = -0.30 * ymax;
ylim([ymin, ymax]);
xlim([min(sizes) - 1, max(sizes)]);

dnfRows = linspace(-0.24 * ymax, -0.08 * ymax, 3);
dnfTickVals = [];
dnfTickLabels = {};
overflowRows = linspace(0.92 * ymax, 0.76 * ymax, 3);
overflowTickVals = [];
overflowTickLabels = {};

if any(isnan(med_rand))
    markDnfRow(sizes, med_rand, dnfRows(3), randPlot.Color, 'o');
    dnfTickVals(end + 1) = dnfRows(3);
    dnfTickLabels{end + 1} = 'Random DNF';
end
if any(med_rand > ymax)
    markOverflowRow(sizes, med_rand, overflowRows(3), ymax, randPlot.Color, 'o');
    overflowTickVals(end + 1) = overflowRows(3);
    overflowTickLabels{end + 1} = 'Random > limit';
end

if any(isnan(med_hard))
    markDnfRow(sizes, med_hard, dnfRows(2), hardPlot.Color, 's');
    dnfTickVals(end + 1) = dnfRows(2);
    dnfTickLabels{end + 1} = 'Not friendly DNF';
end
if any(med_hard > ymax)
    markOverflowRow(sizes, med_hard, overflowRows(2), ymax, hardPlot.Color, 's');
    overflowTickVals(end + 1) = overflowRows(2);
    overflowTickLabels{end + 1} = 'Not friendly > limit';
end

if any(isnan(med_eas))
    markDnfRow(sizes, med_eas, dnfRows(1), easyPlot.Color, '^');
    dnfTickVals(end + 1) = dnfRows(1);
    dnfTickLabels{end + 1} = 'Friendly DNF';
end
if any(med_eas > ymax)
    markOverflowRow(sizes, med_eas, overflowRows(1), ymax, easyPlot.Color, '^');
    overflowTickVals(end + 1) = overflowRows(1);
    overflowTickLabels{end + 1} = 'Friendly > limit';
end

applyExtraTicks(dnfTickVals, dnfTickLabels);
applyExtraTicks(overflowTickVals, overflowTickLabels);

hold off;


function markDnfRow(xVals, yVals, rowY, seriesColor, markerSymbol)
dnfMask = isnan(yVals);
if ~any(dnfMask)
    return;
end

line([min(xVals) - 0.7, max(xVals)], [rowY, rowY], ...
    'Color', [0.85 0.85 0.85], ...
    'LineStyle', ':', ...
    'HandleVisibility', 'off');

scatter(xVals(dnfMask), repmat(rowY, sum(dnfMask), 1), 50, markerSymbol, ...
    'MarkerEdgeColor', seriesColor, ...
    'MarkerFaceColor', seriesColor, ...
    'LineWidth', 1.5, ...
    'HandleVisibility', 'off');
end

function markOverflowRow(xVals, yVals, rowY, ymax, seriesColor, markerSymbol)
overflowMask = isfinite(yVals) & yVals > ymax;
if ~any(overflowMask)
    return;
end

line([min(xVals) - 0.7, max(xVals)], [rowY, rowY], ...
    'Color', [0.85 0.85 0.85], ...
    'LineStyle', ':', ...
    'HandleVisibility', 'off');

scatter(xVals(overflowMask), repmat(rowY, sum(overflowMask), 1), 50, markerSymbol, ...
    'MarkerEdgeColor', seriesColor, ...
    'MarkerFaceColor', 'none', ...
    'LineWidth', 1.5, ...
    'HandleVisibility', 'off');
end

function applyExtraTicks(extraTickVals, extraTickLabels)
if isempty(extraTickVals)
    return;
end

ax = gca;
drawnow;

numericTickVals = ax.YTick;
numericTickLabels = cellstr(ax.YTickLabel);

allTickVals = [numericTickVals(:); extraTickVals(:)];
allTickLabels = [numericTickLabels(:); extraTickLabels(:)];
[allTickVals, sortIdx] = sort(allTickVals);
allTickLabels = allTickLabels(sortIdx);

ax.YTick = allTickVals;
ax.YTickLabel = allTickLabels;
end
