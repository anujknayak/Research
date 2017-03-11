% function to build set of strategies given the budget
%
% Inputs: numBlk - number of blocks
% Output: strategySet - strategy set of dim:numBlk x sampleSize, where sampleSize = 2^number of blocks

function [strategySet, bestStrategyIndex] = build_strategy_set(numBlk, strategySetSize, bestStrategy)

% [strategySetChar] = dec2bin([0:2^numBlk-1]);
% strategySet = zeros(2^numBlk-1, numBlk);
% for indStrategy = 1:2^numBlk
%     for indBlk = 1:numBlk
%         strategySet(indStrategy, indBlk) = str2num(strategySetChar(indStrategy, indBlk));
%     end
% end

strategySetTmp = round(rand(strategySetSize*100, numBlk));
strategySetTmp = unique(strategySetTmp, 'rows');
strategySet = strategySetTmp(1:strategySetSize, :);
ismemBestStrategyVec = ismember(strategySet, bestStrategy.', 'rows');
bestStrategyIndex = find(ismemBestStrategyVec);
if sum(ismemBestStrategyVec) == 0
    strategySet(1,:) = bestStrategy;
    bestStrategyIndex = 1;
end



