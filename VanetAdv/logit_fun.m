function [y] = logit_fun(x)

y = log(x)-log(1-x);