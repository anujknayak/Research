% Parameter initialization function
function [Params] = dynamic_network_params_init(Scenario)

Params.numBlkRow = Scenario.numBlkRow; % number of rows in the grid
Params.numBlkCol= Scenario.numBlkCol; % number of columns in the grid
Params.numBlk = Scenario.numBlk; % number of blocks

Params.budget = 100*ones(Params.numBlk, 1); % total budget
Params.gammaVal = 0; % uncertainty in random walk of block densities
Params.maxGPrimeVal = 20; % strategy update parameter

Params.w = round(100*rand(Params.numBlk, 1)); % weight vector

% >>> for debug
%Params.w = ones(size(Params.w));
%Params.w = [5 5 5 80].';
%Params.budget = zeros(size(Params.budget));