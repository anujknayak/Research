function [bidResX, paymentVec, stateStruct, dbg]  = repeated_auction_top(valuationMat, blkDenVec, paymentPredict, cdfMat, indSnapShot, stateStruct, Params, dbg)

slopeVal    = stateStruct.slopeVal;
alphaState  = stateStruct.alphaState;
kMat        = stateStruct.kMat;

% determine tDecay - as a function of Kalman filter output
% >>>> update tDecay computation later - [TODO]
tDecay = (Params.tDecayMin*blkDenVec + Params.tDecayMax*(1-blkDenVec))*ones(1, size(alphaState, 2));
tRecovery = (Params.tRecoveryMax*blkDenVec + Params.tRecoveryMin*(1-blkDenVec))*ones(1, size(alphaState, 2));

rewardEstMat = valuationMat.*alphaState;

% % >>>> FOR DEBUG BEGIN
% %paymentPredict = dbg.blkDenVec;
% cumulMatLogit = 1-qfun((logit_fun(rewardEstMat) - logit_fun(dbg.blkDenVec*ones(1, size(rewardEstMat, 2))))*0.001);
% cumulMat = sigmoid_fun(cumulMatLogit);
% % >>>> FOR DEBUG END

% compute cumulMat
cdfBins = [0:1/Params.numQntzLvls:1-1/Params.numQntzLvls]+0.5/Params.numQntzLvls;
cdfMat2 = cdfMat; %.^(Params.numPlayers-1);
cumulMat = zeros(size(rewardEstMat));
if dbg.sampleDirichletEn == 1
    for indBlk = 1:size(rewardEstMat, 1)
        for indPlayer = 1:size(rewardEstMat, 2)
            cumulMat(indBlk, indPlayer) = interp1(cdfBins, permute(cdfMat2(indBlk, indPlayer, :), [1 3 2]), rewardEstMat(indBlk, indPlayer));
        end
    end
%    figure(1);surf(squeeze(cdfMat(5, :, :)));
%     figure(1);plot(squeeze(cdfMat(1, 1, :)));ylim([0 1]);
%     figure(2);plot(squeeze(pdfMat(1, 1, :)));ylim([0 1]);
%     drawnow();
else
    for indBlk = 1:size(rewardEstMat, 1)
        cumulMat(indBlk, :) = interp1(cdfBins, cdfMat2(indBlk, :), rewardEstMat(indBlk, :));
    end
%     figure(1);plot(cdfMat(1,:));ylim([0 1]);
%     drawnow();
end

% computing expected reward
gammaMat = (1-cumulMat)*(1/(Params.cost+Params.entryFee))+ (Params.kReward*rewardEstMat./((Params.entryFee+Params.cost+Params.kPayment*paymentPredict)*ones(1,size(rewardEstMat, 2)))).*cumulMat;



% bidding decision
if dbg.sampleDirichletEn == 1
    bidIndicMat = gammaMat>(1/Params.entryFee) |  (rand(size(gammaMat))<=Params.pExplore);
else
    bidIndicMat = (gammaMat>(1/Params.entryFee)) |  (rand(size(gammaMat))<=Params.pExplore);
end

%figure(200);imagesc(bidIndicMat);drawnow();

% dim: numBlocks x numPlayers

% % >>>> for debug begin
% if (indSnapShot < 40 && Params.linPredEnable == 1)
%     bidIndicMat = ones(size(bidIndicMat));
% elseif mod(indSnapShot, 5) == 0
% %     for indBlk = 1:size(paymentPredict, 1)
% %         if blkDenVec(indBlk)<0.25
% %             bidIndicMat(indBlk, :) = 1;
% %         end
% %     end
% end
% >>>> for debug end

% auction result
[bidResX, paymentVec] = second_price(rewardEstMat.*bidIndicMat);

% >>>> FOR DEBUG BEGIN
% for ind = 1:size(bidResX,1)
%     figure(1);plot([bidResX(ind, :);rewardEstMat(ind,:)].');hold on;stem(rewardEstMat(ind,:) == max(rewardEstMat(ind, :)), 'k-o');hold off;
%     brkpnt1 = 1;
% end
% >>>> FOR DEBUG END

% reward scaling factor after auction
alphaVal = exp(-1./tDecay).*bidResX.*alphaState + (1-bidResX).*(alphaState + slopeVal);
alphaVal = min(alphaVal,1);
kMat = min((1-bidResX).*(kMat+1),(1-bidResX).*(tRecovery-1));
slopeVal = (1-alphaVal)./(tRecovery-kMat);

% >>>> FOR DEBUG BEGIN
% figure(1);plot(alphaState(1:2,:).');ylim([0.5 1.5]);
% pause(0.5);
% >>>> FOR DEBUG END

stateStruct.alphaState  = alphaVal;
stateStruct.slopeVal    = slopeVal;
stateStruct.kMat        = kMat;

if dbg.performance == 1
    rewardResMat = Params.kReward*bidResX.*rewardEstMat;
    paymentPlayerMat = zeros(size(bidResX, 1), size(bidResX, 2));
    %paymentPlayerTmp(find(bidResX.')) = Params.kPayment*paymentVec;paymentPlayerTmp = paymentPlayerTmp.';
    for indBlk = 1:size(bidResX, 1)
        bidderIdx = find(bidResX(indBlk, :));
        if ~isempty(bidderIdx)
            paymentPlayerMat(indBlk, bidderIdx) = paymentVec(indBlk)*Params.kPayment;
        end
    end
    costBidMat = bidIndicMat*Params.cost;
    %utilityResMat = (rewardResMat./(Params.entryFee+costBidMat+paymentPlayerMat)); utilityResMat(find(isnan(utilityResMat))) = 1;
    utilityResMat = rewardResMat-(Params.entryFee+costBidMat+paymentPlayerMat); %utilityResMat(find(isnan(utilityResMat))) = 1;
    dbg.utilityAllMat(:,:,end+1) = utilityResMat;
    dbg.rewardAllMat(:,:,end+1) = rewardResMat;
    dbg.costAllMat(:, :, end+1) = costBidMat + paymentPlayerMat;
    dbg.bidResAllMat(:, :, end+1) = bidResX;
end


