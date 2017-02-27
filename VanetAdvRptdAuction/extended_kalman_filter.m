% Module to perform Extended Kalman Filtering - Non-linear sub-optimal
% coounterpart of Kalman Filter
% Inputs: yVec - vector of block densities for a single snapshot - observation vector
%         psiEst - vector estimated block densities in logit form
%         FMat - Process vector - in this case it is identity matrix
%         REst - Predicted covariance estimate
%         GammaMat - process noise covariance matrix
%         SigMat - observation noise covariance matrix
% Outputs: psiEst - vector estimated block densities in logit form (corrected using the current observation)
%          REst -  Predicted covariance estimate (updated using the current observation)
%          psiEst_tMinus1 - psiEst (estimated using previous observation)
%          REst_Minus1 - covariance estimate (estimated using the current observation)
%
function [psiEst, REst, psiEst_tMinus1, REst_tMinus1] = extended_kalman_filter(yVec, psiEst, FMat, REst, GammaMat, n_abVec)

psiEst = FMat*psiEst; % predicting the next state
psiEst_tMinus1 = psiEst;
SigMat = diag(sigmoid_fun(psiEst).*(1-sigmoid_fun(psiEst))./n_abVec);
REst = FMat*REst*FMat.'+ GammaMat; % estimating the covariance matrix
REst_tMinus1 = REst;
HMat = diag((sigmoid_fun(psiEst).^2).*exp(-psiEst));
invMat = (HMat*REst*HMat.'+SigMat);
if rcond(invMat) < 1e-4 || isnan(rcond(invMat))
    invMat = eye(size(invMat));
end
KalmanGainMat = (REst*HMat.')/invMat; % computing the Kalman Gain
psiEst = psiEst + KalmanGainMat*(yVec-sigmoid_fun(psiEst)); % updating the state estimate
REst = (eye(size(KalmanGainMat)) - KalmanGainMat*HMat)*REst; % updating the covariance matrix estimate
