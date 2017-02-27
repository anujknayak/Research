function [bidResX, paymentVec, stateStruct, dbg]  = repeated_auction_top(valuationMat, paymentPredict, cdfMat, stateStruct, Params, dbg)

slopeVal    = stateStruct.slopeVal;
alphaState  = stateStruct.alphaState;
kMat        = stateStruct.kMat;

% determine tDecay - as a function of Kalman filter output
% >>>> update tDecay computation later - [TODO]
tDecay = Params.tDecayMin*ones(size(alphaState));
tRecovery = Params.tRecoveryMin*ones(size(alphaState));

rewardEstMat = valuationMat.*alphaState;

% % >>>> FOR DEBUG BEGIN
% %paymentPredict = dbg.blkDenVec;
% cumulMatLogit = 1-qfun((logit_fun(rewardEstMat) - logit_fun(dbg.blkDenVec*ones(1, size(rewardEstMat, 2))))*0.001);
% cumulMat = sigmoid_fun(cumulMatLogit);
% % >>>> FOR DEBUG END

% compute cumulMat
cdfBins = [0:1/Params.numQntzLvls:1-1/Params.numQntzLvls]+0.5/Params.numQntzLvls;
cdfMat2 = cdfMat.^(Params.numPlayers-1);
cumulMat = zeros(size(rewardEstMat));
for indBlk = 1:size(rewardEstMat, 1)
    cumulMat(indBlk, :) = interp1(cdfBins, cdfMat2(indBlk, :), rewardEstMat(indBlk, :));
end

% computing expected reward
gammaMat = (1-cumulMat)*(1/(Params.cost+Params.entryFee))+ (100*rewardEstMat./((Params.entryFee+Params.cost+100*paymentPredict)*ones(1,size(rewardEstMat, 2)))).*cumulMat;

% bidding decision
bidIndicMat = gammaMat>(1/Params.entryFee);
% dim: numBlocks x numPlayers

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
    rewardResMat = bidResX.*rewardEstMat; dbg.rewardEstAccMat = dbg.rewardEstAccMat + rewardResMat;rewardResMat(rewardResMat == 0) = Params.entryFee;
    paymentPlayerTmp = zeros(size(bidResX, 2), size(bidResX, 1));paymentPlayerTmp(find(bidResX.')) = paymentVec;paymentPlayerTmp = paymentPlayerTmp.';
    dbg.paymentAccMat = dbg.paymentAccMat + paymentPlayerTmp;
    costBidMat = bidIndicMat*Params.cost; dbg.costAccMat = dbg.costAccMat + costBidMat;
    utilityResMat = (rewardResMat./(Params.entryFee+costBidMat+paymentPlayerTmp)); utilityResMat(find(isnan(utilityResMat))) = 1;
    dbg.utilityAccMat = dbg.utilityAccMat + utilityResMat;
    dbg.bidIndicAccMat = dbg.bidIndicAccMat + bidIndicMat;
end


