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
%       stopAtFirst - boolean flag describing whether the function should stop at the first failed matrix; if true, the function falls back to the sequential implementation
%       numWorkers - number of parallel workers; defaults to the local cluster limit
%       profile - parallel profile name, defaults to Processes
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
    opts.numWorkers = 16
    opts.profile = "Processes"
end

if opts.stopAtFirst
    [allPassed, passCount, failCount, failReason, A_fail, b_fail, x_alg, x_true, successBySize, medianErrorBySize, sizes] = ...
        bulkTest(minSize, maxSize, maxVal=opts.maxVal, numPerSize=opts.numPerSize, ...
        tolerance=opts.tolerance, maxIter=opts.maxIter, generator=opts.generator, ...
        stopAtFirst=opts.stopAtFirst);
    return;
end

cluster = parcluster(opts.profile);
if isempty(opts.numWorkers)
    workerCount = cluster.NumWorkers;
else
    workerCount = opts.numWorkers;
end

if workerCount > cluster.NumWorkers
    try
        cluster.NumWorkers = workerCount;
        saveProfile(cluster);
    catch exc
        warning("Requested %d workers, but the %s parallel profile allows only %d. Using %d workers instead. Reason: %s", ...
            workerCount, string(opts.profile), cluster.NumWorkers, cluster.NumWorkers, exc.message);
        workerCount = cluster.NumWorkers;
    end
end

pool = gcp("nocreate");
if isempty(pool)
    parpool(opts.profile, workerCount);
elseif pool.NumWorkers == 1 && workerCount > 1
    delete(pool);
    parpool(opts.profile, workerCount);
elseif ~isempty(opts.numWorkers) && pool.NumWorkers ~= workerCount
    delete(pool);
    parpool(opts.profile, workerCount);
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

numTasks = numel(sizes) * opts.numPerSize;
if numTasks == 0
    return;
end

chunkSize = max(1, min(opts.numPerSize, max(10, ceil(opts.numPerSize / max(1, 4 * workerCount)))));
numChunks = ceil(numTasks / chunkSize);

taskIdxByChunk = cell(numChunks, 1);
errorsByChunk = cell(numChunks, 1);
successByChunk = cell(numChunks, 1);
failTaskByChunk = zeros(numChunks, 1);
failAByChunk = cell(numChunks, 1);
failBByChunk = cell(numChunks, 1);
failReasonByChunk = strings(numChunks, 1);
lastTaskByChunk = zeros(numChunks, 1);
lastXAlgByChunk = cell(numChunks, 1);
lastXTrueByChunk = cell(numChunks, 1);

parfor chunkIdx = 1:numChunks
    chunkStart = (chunkIdx - 1) * chunkSize + 1;
    chunkEnd = min(numTasks, chunkIdx * chunkSize);
    localCount = chunkEnd - chunkStart + 1;

    localTaskIdx = zeros(localCount, 1);
    localErrors = NaN(localCount, 1);
    localSuccess = false(localCount, 1);
    localFailTask = 0;
    localFailA = [];
    localFailB = [];
    localFailReason = "ok";
    localLastTask = 0;
    localLastXAlg = [];
    localLastXTrue = [];

    for localIdx = 1:localCount
        taskIdx = chunkStart + localIdx - 1;
        sizeIdx = ceil(taskIdx / opts.numPerSize);
        s = sizes(sizeIdx);

        [A_i, x_i] = opts.generator(s, maxVal=opts.maxVal);
        [localErrors(localIdx), localSuccess(localIdx), failureReason, x_alg_i, x_true_i] = ...
            validateSolver(A_i, x_i, tolerance=opts.tolerance, maxIter=opts.maxIter);

        localTaskIdx(localIdx) = taskIdx;
        localLastTask = taskIdx;
        localLastXAlg = x_alg_i;
        localLastXTrue = x_true_i;

        if localSuccess(localIdx) ~= true
            localFailTask = taskIdx;
            localFailA = A_i;
            localFailB = A_i * x_i;
            localFailReason = failureReason;
        end
    end

    taskIdxByChunk{chunkIdx} = localTaskIdx;
    errorsByChunk{chunkIdx} = localErrors;
    successByChunk{chunkIdx} = localSuccess;
    failTaskByChunk(chunkIdx) = localFailTask;
    failAByChunk{chunkIdx} = localFailA;
    failBByChunk{chunkIdx} = localFailB;
    failReasonByChunk(chunkIdx) = localFailReason;
    lastTaskByChunk(chunkIdx) = localLastTask;
    lastXAlgByChunk{chunkIdx} = localLastXAlg;
    lastXTrueByChunk{chunkIdx} = localLastXTrue;
end

errorsByTask = NaN(numTasks, 1);
successByTask = false(numTasks, 1);
for chunkIdx = 1:numChunks
    taskIdx = taskIdxByChunk{chunkIdx};
    errorsByTask(taskIdx) = errorsByChunk{chunkIdx};
    successByTask(taskIdx) = successByChunk{chunkIdx};
end

for sizeIdx = 1:numel(sizes)
    taskRange = ((sizeIdx - 1) * opts.numPerSize + 1):(sizeIdx * opts.numPerSize);
    successBySize(sizeIdx) = sum(successByTask(taskRange));

    valid_errors = abs(errorsByTask(taskRange));
    medianErrorBySize(sizeIdx) = median(valid_errors, "omitnan");
    if all(isnan(valid_errors))
        medianErrorBySize(sizeIdx) = NaN;
    end
end

passCount = sum(successByTask);
failCount = numTasks - passCount;
allPassed = failCount == 0;

[lastTask, lastTaskChunk] = max(lastTaskByChunk);
if lastTask > 0
    x_alg = lastXAlgByChunk{lastTaskChunk};
    x_true = lastXTrueByChunk{lastTaskChunk};
end

[lastFailTask, lastFailChunk] = max(failTaskByChunk);
if lastFailTask > 0
    A_fail = failAByChunk{lastFailChunk};
    b_fail = failBByChunk{lastFailChunk};
    failReason = failReasonByChunk(lastFailChunk);
end

end
