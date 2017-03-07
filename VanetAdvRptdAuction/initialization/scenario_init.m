% function for scenario generation
function [Scenario] = scenario_init()

Scenario.randWalkVar = 40; % variance of random walk of block densities

% number of blocks - row x column
Scenario.numBlkRow = 1;
Scenario.numBlkCol = 100;
Scenario.numBlk = Scenario.numBlkRow*Scenario.numBlkCol;

% initialize block densities
% Shouldn't this be Binomial? [TODO]
%Scenario.blkDenInitVal = reshape(rand(1,Scenario.numBlkRow*Scenario.numBlkCol), Scenario.numBlkRow, Scenario.numBlkCol);
Scenario.blkDenInitVal = rand(Scenario.numBlk, 1);