function [y] = qfun(x)

y = 0.5*erfc(x/sqrt(2));