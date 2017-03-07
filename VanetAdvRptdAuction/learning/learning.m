function [beliefCntMat] = learning(beliefCntMat, paymentVec, Params)

numQntzLvls = Params.numQntzLvls;

% quantize
paymentVecQntz = floor(paymentVec*numQntzLvls)/numQntzLvls;
paymentVecQntz(find(paymentVecQntz == 1)) = 1-1/numQntzLvls;

% 
for indQ = 1:numQntzLvls
    beliefCntMat(:, indQ) = (1-Params.forgetFactor)*beliefCntMat(:, indQ) + (paymentVecQntz == ((indQ-1)/numQntzLvls));
end

