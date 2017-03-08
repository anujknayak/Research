%clear all;clc;
numSnapShots = 1000;
linPredEnableVec = [0];  % 1 -> Enable linear prediction, 0 -> disable linear prediction
sampleDirichletEn = 1; % does not perform well - consider deletion [TODO]
% run with 1 followed by 0 to get plot of MSE in payment prediction

Plot.paymentMSE = 1;
Plot.fairness = 0;
Plot.cumulativeUtility = 1;
Plot.cumulativeReward = 1;
Plot.cumulativeCost = 1;
Plot.cumulativeBidRes = 1;

for linPredEnableInd = 1:length(linPredEnableVec)
    
    Flags.linPredEnable = linPredEnableVec(linPredEnableInd);
    
    [Scenario] = scenario_init();
    
    [Params] = params_init(Scenario);
    Params.auction.linPredEnable = Flags.linPredEnable; % for debug
    
    [stateStruct] = state_init(Params);
    
    [dbg] = debug_init(Params, Scenario);
    dbg.performance = 1;
    dbg.sampleDirichletEn = sampleDirichletEn;
    
    rand('seed',0);
    randn('seed',0);
    
    % Initializations
    blkDenVecPrev = Scenario.blkDenInitVal;
    beliefCntMat = Params.learning.beliefCntMat;
    if dbg.sampleDirichletEn == 1
        cdfMat = 1*ones(Params.blkDenGen.numBlk, Params.numPlayers, Params.numQntzLvls);
    else
        cdfMat = 1*ones(size(beliefCntMat)); % all bid in the first iteration
    end
    priorVec = ones(size(cdfMat))/size(cdfMat, 2);
    paymentPredictVec = zeros(Params.blkDenGen.numBlk, 1);
    
    % >>>> FOR DEBUG BEGIN
    % Initialization
    xx = [];
    dbg.blkDenMat = [];dbg.paymentMat = [];
    dbg.payMat = [];dbg.payPMat = [];
    % >>>> FOR DEBUG END
    
    % noise filtering (analogous to Jakes model) based block density evolution
    [blkDenMat] = blk_den_fir_filt_gen(numSnapShots, Scenario);  
    % >>>> for debug
    %blkDenMat = 0.45*ones(size(blkDenMat));
    
    for indSnapShot = 1:numSnapShots
        % Random walk based block density evolution
        % [blkDenVec] = blk_den_rand_walk_gen(blkDenVecPrev, Scenario);
        % blkDenVecPrev = blkDenVec;
        
        % noise filtering based block density evolution
        blkDenVec = blkDenMat(:, indSnapShot);
        
        % get valuation of each block for each player - scenario generation
        if indSnapShot == 1
            valuationDevMat = randn([Params.blkDenGen.numBlk Params.auction.numPlayers])*sqrt(Params.auction.valuationUncert);
        end
        valuationMat = get_valuation(blkDenVec, valuationDevMat, Params);
        
        % >>>> for debug
        %figure(3);hist(valuationMat(1, :), [0:0.005:1]);
        %pause(0.1);
        
        % Let's auction!
        [bidResX, paymentVec, stateStruct, dbg] = repeated_auction_top(valuationMat, blkDenVec, paymentPredictVec, cdfMat, indSnapShot, stateStruct, Params.auction, dbg);
        %paymentVec = max(paymentVec, blkDenVec);
        
        % For plotting MSE in payment prediction
        if Plot.paymentMSE == 1
            if indSnapShot > 1  
                dbg.payPMat = [dbg.payPMat paymentPredictVec];
                dbg.payMat = [dbg.payMat paymentVec];
                %xx = [xx blkDenVec(1)];
            end
        end
        
        % Learning
        [beliefCntMat] = learning(beliefCntMat, paymentVec, Params.learning);
        
        % Prediction
        if Flags.linPredEnable == 1
            paymentVec(paymentVec == 0) = paymentPredictVec(paymentVec == 0); % check this [TODO]
            [paymentPredictVec, stateStruct.prediction] = prediction_top(paymentVec, indSnapShot, Params.prediction, stateStruct.prediction);
            % Belief predict
            [beliefCntPredictMat] = learning(beliefCntMat, paymentPredictVec, Params.learning);
        else
            paymentPredictVec = paymentVec;
        end
        
        if dbg.sampleDirichletEn == 1
            [cdfMat, pmfMat] = dirichlet_sample(beliefCntMat, priorVec, Params.learning.concentrPrm, Params.numPlayers);
        else
            [cdfMat, pmfMat] = dirichlet_mean(beliefCntMat, priorVec, Params.learning.concentrPrm);
        end
        
        %     % >>>> FOR DEBUG
        %figure(4);plot(cdfMat(4, :));
        
        %     blkDenMat = [blkDenMat blkDenVec];
        %     paymentMat = [paymentMat paymentVec];
        %     if indSnapShot >=2
        %         figure(2);plot(payPMat.', 'k-o');hold on;plot(paymentMat.', 'r-o');hold off;
        %         ylim([0 1]);
        %         brkpnt1 = 1;
        %     end
        
        % xx = [xx blkDenVec(1)];
        %     figure(1);imagesc(blkDenVec);
        %     brkpnt1 = 1;
        % figure(2);plot(pmfMat(1,:).');ylim([0 0.3]);drawnow();pause(0.001);
    end
    
    plot_results(dbg, Flags, Plot);
    
end
%plot(xx);
%figure;plot(xx);