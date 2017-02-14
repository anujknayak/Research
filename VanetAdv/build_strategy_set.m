% function to build set of strategies given the budget
%
% Inputs: numBlk - number of blocks
%         budget - total budget
%         sampleSetSize - subset of all samples
% Output: strategySet - strategy set of dim:numBlk x sampleSize

function [strategySet] = build_strategy_set(numBlk, budget, sampleSetSize)

[strategySet] = rand_sum_to_const(numBlk, sampleSetSize, budget);

