function [paymentPredictVec, stateStruct] = prediction_top(paymentVec, timeStamp, Params, stateStruct)

paymentHistoryMat = stateStruct.paymentHistoryMat;
paymentPredictVec = zeros(size(paymentVec));

% linear prediction
if timeStamp > 2*Params.lpcOrder
        % for debug
%     paymentHistoryMat = zeros(size(paymentHistoryMat)+[0 1]);
%     for ind = 1:size(paymentHistoryMat, 1)
%         paymentHistoryMat(ind, :) = real(exp(1j*(2*pi*0.05*([0:1:size(paymentHistoryMat, 2)-1]+timeStamp)+(ind-1)*pi/size(paymentHistoryMat, 1))));
%     end
%     paymentHistoryMat = paymentHistoryMat + randn(size(paymentHistoryMat))*0;
%     paymentHistoryMat = paymentHistoryMat + abs(max(max(paymentHistoryMat))) + 0.1;
%     paymentHistoryMat = paymentHistoryMat/(max(max(paymentHistoryMat))+0.1);
%     paymentVec = paymentHistoryMat(:,end);paymentHistoryMat(:,end) = [];    
    filterCoeffMat = stateStruct.filterCoeffMat;
    for indBlk = 1:length(paymentVec)
        % replace the following with LMS        
        filterCoeffMat(indBlk, :) = adaptive_lms_lin_pred(logit_fun([paymentHistoryMat(indBlk, end-Params.lpcOrder+1:end) paymentVec(indBlk)]), Params.lpcOrder, filterCoeffMat(indBlk, :), Params.mu);
        paymentPredictVec(indBlk) = sigmoid_fun(sum(fliplr(filterCoeffMat(indBlk, :)).*logit_fun([paymentHistoryMat(indBlk, end-Params.lpcOrder+2:end) paymentVec(indBlk)])));
    end
    stateStruct.paymentHistoryMat(:, 1:end-1) = paymentHistoryMat(:, 2:end);
    stateStruct.paymentHistoryMat(:, end) = paymentVec;
    stateStruct.filterCoeffMat = filterCoeffMat;
    
elseif timeStamp == 2*Params.lpcOrder
    % for debug
%     paymentHistoryMat = zeros(size(paymentHistoryMat)+[0 1]);
%     for ind = 1:size(paymentHistoryMat, 1)
%         paymentHistoryMat(ind, :) = real(exp(1j*(2*pi*0.05*[0:1:size(paymentHistoryMat, 2)-1]+(ind-1)*pi/size(paymentHistoryMat, 1))));
%     end
%     paymentHistoryMat = paymentHistoryMat + randn(size(paymentHistoryMat))*0;
%     paymentHistoryMat = paymentHistoryMat + abs(max(max(paymentHistoryMat))) + 0.1;
%     paymentHistoryMat = paymentHistoryMat/(max(max(paymentHistoryMat))+0.1);
%     paymentVec = paymentHistoryMat(:,end);paymentHistoryMat(:,end) = [];
    for indBlk = 1:length(paymentVec)
        filterCoeffVecTmp = lpc(logit_fun([paymentHistoryMat(indBlk, :) paymentVec(indBlk)]), Params.lpcOrder);
        filterCoeffMat(indBlk, :) = -filterCoeffVecTmp(2:end);
        paymentPredictVec(indBlk) = sigmoid_fun(sum(fliplr(filterCoeffMat(indBlk, :)).*logit_fun([paymentHistoryMat(indBlk, end-Params.lpcOrder+2:end) paymentVec(indBlk)])));
        
        %filterCoeffVec = wiener_lpc(logit_fun([paymentHistoryMat(indBlk, :) paymentVec(indBlk)]), Params.lpcOrder);
        %paymentPredictVec(indBlk) = sigmoid_fun(sum(fliplr(filterCoeffVec.').*logit_fun([paymentHistoryMat(indBlk, end-Params.lpcOrder+2:end) paymentVec(indBlk)])));
    end
    stateStruct.paymentHistoryMat(:, 1:end-1) = paymentHistoryMat(:, 2:end);
    stateStruct.paymentHistoryMat(:, end) = paymentVec;
    stateStruct.filterCoeffMat = filterCoeffMat;

%elseif timeStamp == Params.lpcOrder
%     for indBlk = 1:length(paymentVec)
%         filterCoeffVecTmp = lpc([paymentHistoryMat(indBlk, :) paymentVec(indBlk)], Params.lpcOrder);
%         filterCoeffVec(indBlk, :) = -filterCoeffVecTmp(2:end);
%     end
else
    paymentPredictVec = paymentVec;
    stateStruct.paymentHistoryMat(:, timeStamp) = paymentVec;
end

