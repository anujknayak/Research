function [valuationMat] = get_valuation(blkDenVec, varVal,  numPlayers)

if size(blkDenVec, 1) == 1
    blkDenVec = blkDenVec';
end

% valuation is modeled as a Gaussian with mean as the block densities
valuationVecLogit = logit_fun(blkDenVec*ones(1, numPlayers)) + randn([length(blkDenVec) numPlayers])*sqrt(varVal);
valuationMat = sigmoid_fun(valuationVecLogit);
