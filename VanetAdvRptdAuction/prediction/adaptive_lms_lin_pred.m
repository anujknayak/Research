function [a] = adaptive_lms_lin_pred(x, N, aPrev, mu)

a = aPrev+mu*fliplr(x(1:N))*(x(N+1)-fliplr(aPrev)*x(1:N).');

