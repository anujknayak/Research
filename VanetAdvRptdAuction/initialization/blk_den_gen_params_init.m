function [Params] = blk_den_gen_params_init(Scenario)

Params.blkDenGen.numBlkRow   = Scenario.numBlkRow; % number of rows in the grid
Params.blkDenGen.numBlkCol   = Scenario.numBlkCol; % number of columns in the grid
Params.blkDenGen.numBlk      = Params.blkDenGen.numBlkRow*Params.blkDenGen.numBlkCol; % number of blocks
Params.blkDenGen.randWalkVar = 0.2; % uncertainty in random walk of block densities
