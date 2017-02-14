% Parameter initialization function
function [Params] = dynamic_network_params_init(Scenario)

Params.numBlkRow = Scenario.numBlkRow; % number of rows in the grid
Params.numBlkCol= Scenario.numBlkCol; % number of columns in the grid
Params.numBlk = Params.numBlkRow*Params.numBlkCol; % number of blocks

Params.budget = 100; % total budget

Params.strategySetSize = 100; % since the full strategy size is huge, we can consider a random subset of 1000 samples from the strategy set.

Params.gammaVal = 0; % uncertainty in random walk of block densities