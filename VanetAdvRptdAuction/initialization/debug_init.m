function [dbg] = debug_init(Params, Scenario)

dbg.rewardEstAllMat = zeros(Params.blkDenGen.numBlk, Params.numPlayers); 
dbg.paymentAllMat   = zeros(Params.blkDenGen.numBlk, Params.numPlayers); 
dbg.costAllMat      = zeros(Params.blkDenGen.numBlk, Params.numPlayers); 
dbg.utilityAllMat   = zeros(Params.blkDenGen.numBlk, Params.numPlayers);
dbg.rewardAllMat    = zeros(Params.blkDenGen.numBlk, Params.numPlayers);
dbg.bidIndicAllMat  = zeros(Params.blkDenGen.numBlk, Params.numPlayers);
dbg.bidResAllMat    = zeros(Params.blkDenGen.numBlk, Params.numPlayers);


