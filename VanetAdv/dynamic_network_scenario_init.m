% function for scenario generation
function [Scenario] = dynamic_network_scenario_init()

% number of blocks - row x column
Scenario.numBlkRow = 20; % number of rows
Scenario.numBlkCol = 20; % number of columns

Scenario.numBlk = Scenario.numBlkRow*Scenario.numBlkCol; % number of blocks - rowsxcolumns
Scenario.blkDenVecDelta = 5; % \hat(v(t)) - v(t)

Scenario.maxNumVehicles = 1000; % maximum number of vehicles

