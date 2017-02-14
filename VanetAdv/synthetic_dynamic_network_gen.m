% function to generate synthetic dynamic network
% block densities evolve as a Gaussian random walk
function [blkDenMat] = synthetic_dynamic_network_gen(blkDenMatPrev, Scenario)

blkDenMatLogistic = logit_fun(blkDenMatPrev) + randn(size(blkDenMatPrev))*sqrt(Scenario.randWalkVar); % Gaussian random walk
blkDenMat = sigmoid_fun(blkDenMatLogistic);







