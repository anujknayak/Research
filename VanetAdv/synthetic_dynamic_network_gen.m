% function to generate random vehicle densities
function [blkDenMat] = synthetic_dynamic_network_gen(Scenario)

% number of vehicles are uniformly distributed in the range [1 maxNumVehicles]
blkDenMat = rand(Scenario.numBlk, 1)*Scenario.maxNumVehicles;
blkDenMat(blkDenMat == 0) = 1;

% evolution [TODO]

% >>>> for debug
%blkDenMat = 500*ones(size(blkDenMat));







