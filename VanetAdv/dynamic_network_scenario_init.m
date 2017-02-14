% function for scenario generation
function [Scenario] = dynamic_network_scenario_init()

Scenario.randWalkVar = 0; % variance of random walk of block densities

% number of blocks - row x column
Scenario.numBlkRow = 10;
Scenario.numBlkCol = 10;

% initialize block densities
% Shouldn't this be Binomial? [TODO]
Scenario.blkDenInitVal = reshape(randn(1,Scenario.numBlkRow*Scenario.numBlkCol), Scenario.numBlkRow, Scenario.numBlkCol);
