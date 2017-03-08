function [Params] = params_init(Scenario)

Params.numPlayers               = 50; % number of players
Params.numQntzLvls              = 100;

Params.blkDenGen.numBlkRow      = Scenario.numBlkRow; % number of rows in the grid
Params.blkDenGen.numBlkCol      = Scenario.numBlkCol; % number of columns in the grid
Params.blkDenGen.numBlk         = Params.blkDenGen.numBlkRow*Params.blkDenGen.numBlkCol; % number of blocks
Params.blkDenGen.randWalkVar    = Scenario.randWalkVar; % uncertainty in random walk of block densities

Params.auction.valuationUncert  = 0.02; % uncertainty in valuation compared to the block density
Params.auction.numPlayers       = Params.numPlayers; % number of players
Params.auction.entryFee         = .1;
Params.auction.cost             = 0.025;
Params.auction.tDecayMin        = 10;
Params.auction.tDecayMax        = 15;
Params.auction.tRecoveryMin     = 4;
Params.auction.tRecoveryMax     = 6;
Params.auction.numQntzLvls      = Params.numQntzLvls;
Params.auction.kReward          = 1e3;
Params.auction.kPayment         = 1e3;
Params.auction.pExplore         = 0.1;

Params.learning.numQntzLvls     = Params.numQntzLvls;
Params.learning.beliefCntMat    = zeros(Params.blkDenGen.numBlk, Params.learning.numQntzLvls);
Params.learning.concentrPrm     = 0;
Params.learning.forgetFactor    = 0.1;

Params.prediction.lpcOrder      = 20;
Params.prediction.mu            = 5e-3;

