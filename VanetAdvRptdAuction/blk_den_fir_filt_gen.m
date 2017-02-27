% function to generate synthetic dynamic block density evolution
% block densities evolve as a Gaussian random walk
function [blkDenMat] = blk_den_fir_filt_gen(numSnapShots, Scenario)

% % >>>> for debug
% Scenario.numBlk = 4;
% Scenario.randWalkVar = 10;
% numSnapShots = 1000;

f = [0 1/6 1.5/6 1];
a = [1 1 0 0];
w = [4 4 10 1];
b = firpm(77,f,a);
noiseMat = randn(numSnapShots, Scenario.numBlk)*sqrt(Scenario.randWalkVar);
blkDenMatLogistic = filter(b.', 1, noiseMat); % Gaussian random walk
blkDenMat = sigmoid_fun(blkDenMatLogistic.');

% figure(1);plot(blkDenMat.');ylim([0 1]);xlim([100 300]);
% brkpnt1 = 1;