function [cdfMat, pmfMat] = dirichlet_mean(alphaMat, priorVec, concentrPrm)

cdfMat = zeros(size(alphaMat));
pmfMat = zeros(size(alphaMat));

for indAlpha = 1:size(alphaMat, 1)
    pmfMat(indAlpha, :) = (alphaMat(indAlpha, :) + concentrPrm*priorVec(indAlpha, :))/sum(alphaMat(indAlpha, :) + concentrPrm*priorVec(indAlpha, :));
    cdfMat(indAlpha, :) = cumsum(pmfMat(indAlpha, :));
end
