mu = 5e-2;
N = 10;
K = 10*N;
x = sin(2*pi*0.05*[0:K-1])+randn(1,K)*0.05;
a = randn(1, N);

for ind = 1:K-N
    a = adaptive_lms_lin_pred(x(ind+[0:N]), N, a, mu);
    aMat(ind, :) = a(:);
end

for ind = 1:K-N
    y(ind) = sum(fliplr(aMat(ind, :)).*x([0:N-1]+ind));
end

figure;plot([y;x(N+1:end)].');legend('x','adap_lms_lp');