function [stateStruct] = state_init(Params)

stateStruct.alphaState      = ones(Params.blkDenGen.numBlk, Params.numPlayers);

%stateStruct.bidResXPrev     = zeros(Params.blkDenGen.numBlk, Params.numPlayers);
stateStruct.slopeVal        = zeros(Params.blkDenGen.numBlk, Params.numPlayers);
stateStruct.kMat            = zeros(Params.blkDenGen.numBlk, Params.numPlayers);

stateStruct.prediction.paymentHistoryMat = [];
