function [Params] = params_init(Scenario)

Params.numPlayers               = 10; % number of players
Params.numQntzLvls              = 10;

Params.blkDenGen.numBlkRow      = Scenario.numBlkRow; % number of rows in the grid
Params.blkDenGen.numBlkCol      = Scenario.numBlkCol; % number of columns in the grid
Params.blkDenGen.numBlk         = Params.blkDenGen.numBlkRow*Params.blkDenGen.numBlkCol; % number of blocks
Params.blkDenGen.randWalkVar    = Scenario.randWalkVar; % uncertainty in random walk of block densities

Params.auction.valuationUncert  = 0.1; % uncertainty in valuation compared to the block density
Params.auction.numPlayers       = Params.numPlayers; % number of players
Params.auction.entryFee         = 2;
Params.auction.cost             = 5;
Params.auction.tDecayMin        = 5;
Params.auction.tDecayMax        = 15;
Params.auction.tRecoveryMin     = 4;
Params.auction.tRecoveryMax     = 6;
Params.auction.numQntzLvls      = Params.numQntzLvls;

Params.learning.numQntzLvls     = Params.numQntzLvls;
Params.learning.beliefCntMat    = zeros(Params.blkDenGen.numBlk, Params.learning.numQntzLvls);
Params.learning.concentrPrm     = 10;

Params.prediction.lpcOrder      = 40;
Params.prediction.mu            = 5e-3;

