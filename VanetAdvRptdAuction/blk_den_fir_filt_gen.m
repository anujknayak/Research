% function to generate synthetic dynamic block density evolution
% block densities evolve as a Gaussian random walk
function [blkDenMat] = blk_den_fir_filt_gen(numSnapShots, Scenario)

% % >>>> for debug
%  Scenario.numBlk = 1;
%  Scenario.randWalkVar = 40;
%  numSnapShots = 1000;

f = [0 1/12 1.5/12 1];
%f = [0 1/24 1.5/24 1];
a = [1 1 0 0];
w = [4 4 10 1];
b = firpm(77,f,a);
noiseMat = randn(numSnapShots, Scenario.numBlk)*sqrt(Scenario.randWalkVar);
blkDenMatLogistic = filter(b.', 1, noiseMat); % Gaussian random walk
blkDenMat = sigmoid_fun(blkDenMatLogistic.');

% figure(1);plot(blkDenMat.', '-o','linewidth', 2);ylim([0 1]);set(gca, 'fontsize', 20);grid on;xlabel('time step');ylabel('block density');
% figure(2);[h,w] = freqz(b);plot(w/pi, 20*log10(h), '-o', 'linewidth', 2);ylabel('Power (dB)');xlabel('frequency (\omega/\pi)');set(gca, 'fontsize', 20);xlim([0 1]);ylim([-60 5]);grid on;