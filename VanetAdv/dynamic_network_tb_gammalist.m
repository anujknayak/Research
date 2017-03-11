
% test-bench related parameters
numIters = 100;
% block densities are uniform
% the best strategy is manually included in the strategy set
numSnapShots = 1000; % total number of time slots
numSlotsPerBatch = 1; % number of time-slots per batch
gammaList = [0 0.2 0.5 0.7 1];
numBatches = numSnapShots/numSlotsPerBatch; % number of batches

randSeed = 0;
rand('seed', randSeed);randn('seed', randSeed);

% initializing scenario
[Scenario] = dynamic_network_scenario_init();

% initializing parameters
[Params] = dynamic_network_params_init(Scenario);

% evolution of block densities
[blkDenVec] = synthetic_dynamic_network_gen(Scenario);
blkDenVecActual = blkDenVec + Scenario.blkDenVecDelta;blkDenVecActual(blkDenVecActual <= 0) = 1;

% build strategy set - select (generate) "Params.strategySetSize" strategies uniformly at random
bestPayment = Params.w.*exp(blkDenVec/Scenario.maxNumVehicles);
bestReward = (((Params.budget-Params.w)./(log(Params.budget./Params.w))).*blkDenVecActual/Scenario.maxNumVehicles+Params.w)*ones(1, numSlotsPerBatch);
bestUtility = bestReward - bestPayment;
bestStrategy = double(bestUtility>0);

[strategySet, idealStrategyIndex] = build_strategy_set(Params.numBlk, Params.strategySetSize, bestStrategy);

strategyIndexMat = zeros(numIters, numBatches*numSlotsPerBatch);

% initialization
avgUtilityAll = zeros(numIters, numBatches);

cc = hsv(length(gammaList));
%markerList = {'-x','-o','-^', '-s'};markerLen = length(markerList);
markerList = {'x','o','^', 's'};markerLen = length(markerList);


for gammaInd = 1:length(gammaList)
    Params.gammaVal = gammaList(gammaInd);
    
    for iterInd = 1:numIters
        % strategy-weight vector - initialized to uniform
        strategyWtVec = ones(Params.strategySetSize, 1);
        
        % reward matrix for one batch
        rewardMat = zeros(numSlotsPerBatch, Params.numBlk);
        strategyMat = zeros(numSlotsPerBatch, Params.numBlk);
        % loop for all batches
        for batchInd = 1:numBatches
            % calculate probability for each strategy
            strategyProb = (1-Params.gammaVal)* strategyWtVec/sum(strategyWtVec) + Params.gammaVal/Params.strategySetSize;
            %strategyIndexVec = zeros(numSlotsPerBatch, 1);
            % for all time slots in a batch
            for timeInd = 1:numSlotsPerBatch
                
                % choose strategy according to the probability distribution
                % uncomment if condition to force only one strategy per batch
                % since there are no switching costs, strategy is changed for every
                % slot and selected randomly as per the distribution
                strategyIndex = randsample(1:Params.strategySetSize, 1, true ,strategyProb);
                
                strategyCurrent = strategySet(strategyIndex, :);
                % compute reward for the chosen strategy for each time slot
                % reward is directly proportional to the block density and the investment
                paymentMat(:, timeInd) = Params.w.*exp(blkDenVec/Scenario.maxNumVehicles);
                strategyIndexMat(iterInd, (batchInd-1)*numSlotsPerBatch + timeInd) = strategyIndex;
                %strategyIndexVec(timeInd) = strategyIndex;
            end
            
            rewardMat = (((Params.budget-Params.w)./(log(Params.budget./Params.w))).*blkDenVecActual/Scenario.maxNumVehicles+Params.w)*ones(1, numSlotsPerBatch);
            utilityMat = rewardMat-paymentMat;
            utilityMultFact = (strategySet(strategyIndexMat(iterInd, (batchInd-1)*numSlotsPerBatch+[1:numSlotsPerBatch]), :)).';
            utilityMat = utilityMat.*utilityMultFact;
            
            % average channel reward - equation 9
            avgBlkUtility = sum(utilityMat, 2)/numSlotsPerBatch;
            avgUtilityAll(iterInd, batchInd) = sum(avgBlkUtility);
            
            % probability of choosing the channel - equation 10
            blkProbVec = sum((strategyProb*ones(1,Params.numBlk)).*strategySet, 1).';
            
            % Calculate the reward for the whole batch - equation 11
            virtualBlkUtility = avgBlkUtility./blkProbVec;virtualBlkUtility(isnan(virtualBlkUtility)) = 0;
            
            % computing gPrime - equation 16
            gPrime = sum(strategySet.*(ones(Params.strategySetSize, 1)*virtualBlkUtility.'), 2);gPrime(isnan(gPrime)) = 0;
            gPrime = (sigmoid_fun(gPrime/Params.maxGPrimeVal)-0.5)*Params.maxGPrimeVal;
            
            % updating strategy weights - equation 14
            strategyWtVec = strategyWtVec.*exp((1-Params.gammaVal)*gPrime/(Params.strategySetSize));
            %strategyWtVec = strategyWtVec.*exp(Params.gammaVal*gPrime/(Params.strategySetSize));
            strategyWtVec = strategyWtVec/sum(strategyWtVec);
        end
    end
    
    % selecting the highest frequency strategy as the ideal strategy
    for indStrategy = 1:Params.strategySetSize
        strategyCntVec(indStrategy) = sum(sum(strategyIndexMat == indStrategy));
    end
    %idealStrategyIndex = find(strategyCntVec == max(strategyCntVec));
    
    strategySelMat = (strategyIndexMat == idealStrategyIndex(1));
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
    
    figure(1);plot([1:numBatches*numSlotsPerBatch], cdfVec, 'color',cc(gammaInd, :),'marker',markerList{mod(gammaInd-1, markerLen)+1}, 'linewidth', 2);ylabel('Probability of best strategy selection');xlabel('time-slot');grid on;set(gca, 'fontsize', 15);
    title([num2str(numIters) ' iters, ' num2str(Params.strategySetSize) ' strategies, ' num2str(Params.numBlkRow) 'x' num2str(Params.numBlkCol) ' block']);hold on;
    legendStr1{gammaInd} = ['\gamma = ' num2str(Params.gammaVal)];
    drawnow();
    
    figure(2);plot([1:numBatches], sum(avgUtilityAll, 1)/numIters, 'color',cc(gammaInd, :),'marker',markerList{mod(2*(gammaInd-1), markerLen)+1});hold on;
    plot([1:numBatches], max(max(avgUtilityAll))*ones(1,numBatches), 'color',cc(gammaInd, :), 'linewidth', 2);grid on;set(gca, 'fontsize', 20);xlabel('batch Index');ylabel('Utility');
    legendStr2{2*(gammaInd-1)+1} = ['averge utility, \gamma = ' num2str(Params.gammaVal)];
    legendStr2{2*gammaInd} = ['maximum utility, \gamma = ' num2str(Params.gammaVal)];
    drawnow();
end

figure(1);legend(legendStr1);hold off;
figure(2);legend(legendStr2);hold off;

