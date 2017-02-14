
% test-bench related parameters
numIters = 1000;
simConvergenceEnable = 1; % flag to check convergence time
% block densities are uniform
% the best strategy is manually included in the strategy set
numSnapShots = 50; % total number of time slots
numSlotsPerBatch = 1; % number of time-slots per batch
numBatches = numSnapShots/numSlotsPerBatch; % number of batches

% initializing scenario
[Scenario] = dynamic_network_scenario_init();

% initializing parameters
[Params] = dynamic_network_params_init(Scenario);

% Matrix of block densities
blkDenMat = Scenario.blkDenInitVal;

% build strategy set - select (generate) "Params.strategySetSize" strategies uniformly at random
[strategySet] = build_strategy_set(Params.numBlk, Params.budget, Params.strategySetSize);

if simConvergenceEnable == 1
    % manually insert the best strategy - uniform
    idealStrategyIndex = round(rand(1)*(Params.strategySetSize-1))+1;
    idealStrategyVec = linspace(0, 1, Params.numBlk);idealStrategyVec = idealStrategyVec/sum(idealStrategyVec);
    strategySet(:, idealStrategyIndex) = 100*idealStrategyVec.'; % best strategy - this should peak
end
% >>>> FOR DEBUG BEGIN <<<<
% strategySet = [ones(Params.numBlk/2, 1);zeros(Params.numBlk/2, 1)]*ones(1, Params.strategySetSize/2);
% strategySet = [strategySet ~strategySet]; %
% strategySet(:, end) = 100*linspace(0, 1, Params.numBlk).'; % best strategy - this should peak
% >>>> FOR DEBUG END

strategyIndexMat = zeros(numIters, numBatches*numSlotsPerBatch);

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
        % >>>> FOR DEBUG BEGIN <<<<
        % uncomment the following line to check the updation of strategy probability
        %figure(1);plot(strategyProb);hold on;
        % >>>> FOR DEBUG END <<<<
        
        % for all time slots in a batch
        for timeInd = 1:numSlotsPerBatch
            
            % evolution of block densities
            [blkDenMat] = synthetic_dynamic_network_gen(blkDenMat, Scenario);
            if simConvergenceEnable == 1
                blkDenVec = linspace(0, 1, Params.numBlk);blkDenVec = (blkDenVec/sum(blkDenVec)).';
            else
                % matrix to vector
                blkDenVec = blkDenMat(:);
            end
            
            % >>>> FOR DEBUG BEGIN
            %blkDenVec = linspace(0, 1, Params.numBlk);blkDenVec = (blkDenVec/sum(blkDenVec)).';
            % >>>> FOR DEBUG END
            
            % choose strategy according to the probability distribution
            % uncomment if condition to force only one strategy per batch
            % since there are no switching costs, strategy is changed for every
            % slot and selected randomly as per the distribution
            %if timeInd == 1 %
            strategyIndex = randsample(1:Params.strategySetSize, 1, true ,strategyProb);
            %end
            strategyCurrent = strategySet(:, strategyIndex);
            % compute reward for the chosen strategy for each time slot
            % reward is directly proportional to the block density and the investment
            % convergence is faster for large magnitudes of reward - so *100 - inspect [TODO]
            rewardMat(timeInd, :) = blkDenVec.*strategyCurrent*100;
            strategyIndexMat(iterInd, (batchInd-1)*numSlotsPerBatch + timeInd) = strategyIndex;
        end
        
        % average channel reward - equation 9
        avgBlkReward = sum(rewardMat, 1)/numSlotsPerBatch;
        
        % probability of choosing the channel - equation 10
        chanProbVec = sum((strategyProb*ones(1,Params.numBlk)).*double(strategySet.'~=0), 1);
        
        % Calculate the reward for the whole batch - equation 11
        virtualBlkReward = avgBlkReward./chanProbVec;
        
        % computing gPrime - equation 15
        strategyChannelIndicVec = double(strategySet.'~=0);
        gPrime = sum(strategyChannelIndicVec.*(ones(Params.strategySetSize, 1)*virtualBlkReward), 2);
        
        % updating strategy weights - equation 14
        strategyWtVec = strategyWtVec.*exp((1-Params.gammaVal)*gPrime/Params.strategySetSize);
    end
end

strategySelMat = (strategyIndexMat == idealStrategyIndex);
cdfVec = sum(strategySelMat)/numIters;

figure(1);plot([1:numBatches*numSlotsPerBatch], cdfVec, 'r-o', 'linewidth', 2);ylabel('Probability of best strategy selection');xlabel('time-slots');grid on;set(gca, 'fontsize', 15);
title([num2str(numIters) ' iters, ' num2str(Params.strategySetSize) ' strategies, ' num2str(Params.numBlkRow) 'x' num2str(Params.numBlkCol) ' block']);
legend(['\gamma = ' num2str(Params.gammaVal)]);
