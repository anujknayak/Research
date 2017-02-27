% function to generate synthetic dynamic block density evolution
% block densities evolve as a Gaussian random walk
function [blkDenVec] = blk_den_rand_walk_gen(blkDenVecPrev, Scenario)

blkDenVecLogistic = logit_fun(blkDenVecPrev) + randn(size(blkDenVecPrev))*sqrt(Scenario.randWalkVar); % Gaussian random walk
blkDenVec = sigmoid_fun(blkDenVecLogistic);
