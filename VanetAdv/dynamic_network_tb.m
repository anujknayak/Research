
% test-bench related parameters
numIters = 100;
% block densities are uniform
% the best strategy is manually included in the strategy set
numSnapShots = 100; % total number of time slots
numSlotsPerBatch = 1; % number of time-slots per batch
numBatches = numSnapShots/numSlotsPerBatch; % number of batches

randSeed = 2;
rand('seed', randSeed);randn('seed', randSeed);

% initializing scenario
[Scenario] = dynamic_network_scenario_init();

% initializing parameters
[Params] = dynamic_network_params_init(Scenario);

% build strategy set - select (generate) "Params.strategySetSize" strategies uniformly at random
[strategySet] = build_strategy_set(Params.numBlk);

strategyIndexMat = zeros(numIters, numBatches*numSlotsPerBatch);

% evolution of block densities
[blkDenVec] = synthetic_dynamic_network_gen(Scenario);

for iterInd = 1:numIters
    % strategy-weight vector - initialized to uniform
    strategyWtVec = ones(2^Params.numBlk, 1);
    
    % reward matrix for one batch
    rewardMat = zeros(numSlotsPerBatch, Params.numBlk);
    strategyMat = zeros(numSlotsPerBatch, Params.numBlk);
    % loop for all batches
    for batchInd = 1:numBatches
        % calculate probability for each strategy
        strategyProb = (1-Params.gammaVal)* strategyWtVec/sum(strategyWtVec) + Params.gammaVal/2^Params.numBlk;
        
        % for all time slots in a batch
        for timeInd = 1:numSlotsPerBatch
            
            % choose strategy according to the probability distribution
            % uncomment if condition to force only one strategy per batch
            % since there are no switching costs, strategy is changed for every
            % slot and selected randomly as per the distribution
            strategyIndex = randsample(1:2^Params.numBlk, 1, true ,strategyProb);
            
            strategyCurrent = strategySet(strategyIndex, :);
            % compute reward for the chosen strategy for each time slot
            % reward is directly proportional to the block density and the investment
            paymentMat(:, timeInd) = Params.w.*exp(blkDenVec/Scenario.maxNumVehicles);
            strategyIndexMat(iterInd, (batchInd-1)*numSlotsPerBatch + timeInd) = strategyIndex;
        end

        blkDenVecActual = blkDenVec + Scenario.blkDenVecDelta;blkDenVecActual(blkDenVecActual <= 0) = 1;
        
        rewardMat = (((Params.budget-Params.w)./(log(Params.budget./Params.w))).*blkDenVecActual/Scenario.maxNumVehicles+Params.w)*ones(1, numSlotsPerBatch);
        utilityMat = rewardMat-paymentMat;
        
        % average channel reward - equation 9
        avgBlkUtility = sum(utilityMat, 2)/numSlotsPerBatch;
        
        % probability of choosing the channel - equation 10
        blkProbVec = sum((strategyProb*ones(1,Params.numBlk)).*strategySet, 1).';
        
        % Calculate the reward for the whole batch - equation 11
        virtualBlkUtility = avgBlkUtility./blkProbVec;
        
        % computing gPrime - equation 16
        gPrime = sum(strategySet.*(ones(2^Params.numBlk, 1)*virtualBlkUtility.'), 2);
        gPrime = (sigmoid_fun(gPrime/Params.maxGPrimeVal)-0.5)*Params.maxGPrimeVal;
        
        % updating strategy weights - equation 14
        strategyWtVec = strategyWtVec.*exp((1-Params.gammaVal)*gPrime/(2^Params.numBlk));
        strategyWtVec = strategyWtVec/sum(strategyWtVec);
    end
end


% selecting the highest frequency strategy as the ideal strategy
for indStrategy = 1:2^Params.numBlk
    strategyCntVec(indStrategy) = sum(sum(strategyIndexMat == indStrategy));
end
idealStrategyIndex = find(strategyCntVec == max(strategyCntVec));

strategySelMat = (strategyIndexMat == idealStrategyIndex);
cdfVec = sum(strategySelMat)/numIters;

% displaying result
disp('******** RESULTS ***********');
disp('1. Utility');
disp(utilityMat.');
disp('2. Strategy');
disp(strategySet(idealStrategyIndex, :));
disp('******** PARAMETERS ***********');
fprintf('1. Maximum number of vehicles = %d\n', Scenario.maxNumVehicles);
fprintf('2. Limit on gPrime (strategy update parameter) = + or - %0.2f\n', Params.maxGPrimeVal);
disp('3. Budget for each block');disp(Params.budget.');
disp('4. Weight w');
disp(Params.w.');

figure(1);plot([1:numBatches*numSlotsPerBatch], cdfVec, 'r-o', 'linewidth', 2);ylabel('Probability of best strategy selection');xlabel('time-slots');grid on;set(gca, 'fontsize', 15);
title([num2str(numIters) ' iters, ' num2str(2^Params.numBlk) ' strategies, ' num2str(Params.numBlkRow) 'x' num2str(Params.numBlkCol) ' block']);
legend(['\gamma = ' num2str(Params.gammaVal)]);
