function [dbg] = debug_init(Params, Scenario)

dbg.rewardEstAccMat = zeros(Params.blkDenGen.numBlk, Params.numPlayers); 
dbg.paymentAccMat   = zeros(Params.blkDenGen.numBlk, Params.numPlayers); 
dbg.costAccMat      = zeros(Params.blkDenGen.numBlk, Params.numPlayers); 
dbg.utilityAccMat   = zeros(Params.blkDenGen.numBlk, Params.numPlayers);
dbg.utilityCumulMat = zeros(Params.blkDenGen.numBlk, Params.numPlayers);

dbg.bidIndicAccMat = zeros(Params.blkDenGen.numBlk, Params.numPlayers);

