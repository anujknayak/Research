%clear all;clc;
numSnapShots = 10000;
linPredEnable = 1;  % 1 -> Enable linear prediction, 0 -> disable linear prediction
                    % run with 1 followed by 0 to get plot of MSE in payment prediction

Plot.paymentMSE = 0;
Plot.fairness = 0;
Plot.cumulativeUtility = 1;
Plot.cumulativeReward = 0;

[Scenario] = scenario_init();

[Params] = params_init(Scenario);

[stateStruct] = state_init(Params);

[dbg] = debug_init(Params, Scenario);
dbg.performance = 1;

rand('seed',0);
randn('seed',0);

% Initializations
blkDenVecPrev = Scenario.blkDenInitVal;
beliefCntMat = Params.learning.beliefCntMat;
cdfMat = 1*ones(size(beliefCntMat)); % all bid in the first iteration
priorVec = ones(size(cdfMat))/size(cdfMat, 2);
paymentPredictVec = zeros(Params.blkDenGen.numBlk, 1);

% >>>> FOR DEBUG BEGIN
% Initialization
xx = [];
blkDenMat = [];paymentMat = [];
payMat = [];payPMat = [];
% >>>> FOR DEBUG END

% noise filtering (analogous to Jakes model) based block density evolution
[blkDenMat] = blk_den_fir_filt_gen(numSnapShots, Scenario);

for indSnapShot = 1:numSnapShots
    % Random walk based block density evolution
    % [blkDenVec] = blk_den_rand_walk_gen(blkDenVecPrev, Scenario);
    % blkDenVecPrev = blkDenVec;
    
    % noise filtering based block density evolution
    blkDenVec = blkDenMat(:, indSnapShot);
    
    % get valuation of each block for each player - scenario generation
    valuationMat = get_valuation(blkDenVec, Params.auction.valuationUncert, Params.numPlayers);
    
    % Let's auction!
    [bidResX, paymentVec, stateStruct, dbg] = repeated_auction_top(valuationMat, paymentPredictVec, cdfMat, stateStruct, Params.auction, dbg);
    paymentVec = max(paymentVec, blkDenVec);
    
    % For plotting MSE in payment prediction
    if Plot.paymentMSE == 1
        if indSnapShot > 100
            payPMat = [payPMat paymentPredictVec];
            payMat = [payMat paymentVec];
            xx = [xx blkDenVec(1)];
        end
    end
    
    % Learning
    [beliefCntMat] = learning(beliefCntMat, paymentVec, Params.learning);
    
    % Prediction
    if linPredEnable == 1
        [paymentPredictVec, stateStruct.prediction] = prediction_top(paymentVec, indSnapShot, Params.prediction, stateStruct.prediction);
        % Belief predict
        [beliefCntPredictMat] = learning(beliefCntMat, paymentPredictVec, Params.learning);
    else
        paymentPredictVec = paymentVec;
    end
    
    [cdfMat, pmfMat] = dirichlet_mean(beliefCntMat, priorVec, Params.learning.concentrPrm);
    
    %     % >>>> FOR DEBUG
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
end

sum(sum(dbg.costAccMat))/prod(size(dbg.costAccMat))

%sum(sum(dbg.utilityAccMat))/prod(size(dbg.utilityAccMat))

%sum(sum(dbg.bidIndicAccMat))

% Plotting MS prediction error (of payment)
if Plot.paymentMSE == 1
    figure(100);
    if linPredEnable == 1
        predErrWithPred = [payMat(1,:)-payPMat(1,:)].';
        mseWithPred = (sum(abs(predErrWithPred).^2))/length(predErrWithPred);
        
        subplot(211);plot(predErrWithPred, '-o', 'linewidth', 2);ylim([-1 1]);hold on;
        subplot(212);plot([payMat(1,:);payPMat(1,:)].', '-o', 'linewidth', 2);ylim([0 1]);hold on;%xlim([500 700]);
    else
        predErrWithoutPred = [payMat(1,:)-payPMat(1,:)].';
        mseWithoutPred = (sum(abs(predErrWithoutPred).^2))/length(predErrWithoutPred);
        
        subplot(211);plot(predErrWithoutPred, '-^', 'linewidth', 2);ylim([-1 1]);hold on;
        legend(['with prediction (MSE=' num2str(mseWithPred) ')'],['without prediction (MSE=' num2str(mseWithoutPred) ')']);grid on;
        xlabel('time index');ylabel('Prediction Error');xlim([500 700]);set(gca, 'fontsize', 20);
        
        subplot(212);plot([payMat(1,:);payPMat(1,:)].', '-^', 'linewidth', 2);ylim([0 1]);hold on;xlim([500 700]);
        legend('actual payment','predicted payment','actual payment','repeated payment');
        xlabel('time index');ylabel('payment (actual/predited)');set(gca, 'fontsize', 20);
    end
end

if Plot.cumulativeUtility == 1
    figure(101);
    if linPredEnable == 1
        cumulUtility = cumsum(dbg.utilityCumulMat, 3);
        plot(permute(cumulUtility(1,1,:),[1 3 2] ),'b');hold on
    else
        cumulUtility = cumsum(dbg.utilityCumulMat, 3);
        plot(permute(cumulUtility(1,1,:),[1 3 2] ),'r');hold off;

    end
end

if Plot.cumulativeReward == 1
    figure(101);
    if linPredEnable == 1
        cumulUtility = cumsum(dbg.utilityCumulMat, 3);
        plot(permute(cumulUtility(1,1,:),[1 3 2] ),'b');hold on
    else
        cumulUtility = cumsum(dbg.utilityCumulMat, 3);
        plot(permute(cumulUtility(1,1,:),[1 3 2] ),'r');hold off
    end
end

%plot(xx);
%figure;plot(xx);