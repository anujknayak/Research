clear all;clc;
tMax = 20;tStep = 1;
tVec = [0:tStep:tMax];
alpha = 1;
alphaVec = zeros(size(tVec));
tRecovery = 4;
tDecay = 10;
X = round(rand(size(tVec)));
%X = ones(size(tVec));%X(2:2:end) = 0;
%X(end-tRecovery+1:end) = 0;
k = 0;l = 0;
m = 0;
alphaTmp = 1;
alphaVec(1) = 1;

for tInd = 1:length(tVec)
    alphaTmp = exp(-1/tDecay)*X(tInd)*alphaTmp + (1-X(tInd))*(alphaTmp+m);
    alphaVec(tInd) = min(alphaTmp, 1);
    k = min([(1-X(tInd))*(k+1) (1-X(tInd))*(tRecovery-1)]);
    %l = X(tInd);
    m = (1-alphaVec(tInd))/(tRecovery-k);
    alphaTmp = alphaVec(tInd);
end

figure;stem(tVec, X, 'k', 'linewidth', 2);hold on;plot(tVec, alphaVec, 'r-o', 'linewidth', 2);grid on;
xlabel('time');ylabel('reward scaling');
set(gca, 'fontsize', 20);
legend('win(1)/lose(0))','reward scaling');
