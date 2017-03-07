function [valuationMat] = get_valuation(blkDenVec, valuationDevMat, Params)

if size(blkDenVec, 1) == 1
    blkDenVec = blkDenVec';
end

% valuation is modeled as a Gaussian with mean as the block densities
valuationVecLogit = logit_fun(blkDenVec*ones(1, size(valuationDevMat, 2))) + valuationDevMat;
valuationMat = sigmoid_fun(valuationVecLogit);

