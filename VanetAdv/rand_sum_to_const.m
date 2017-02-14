% function to generate random vectors that sum to a constant
%
% Inputs: n - length of the vector
%         m - number of vectors
%         s - constant
% Output: x - n x m matrix whos columns sum to "s"

function [x] = rand_sum_to_const(n,m,s)

xRand = rand(n, m);
xTemp = xRand./(ones(n,1)*sum(xRand, 1));
xTemp = round(xTemp*s);
%xDiffVec = s*ones(1,m)-sum(xTemp, 1);
%randIndicesForDelta = ceil(rand(1,m)*n) + [0:1:m-1]*n;
%deltaMat = zeros(n, m);
%deltaMat(randIndicesForDelta) = xDiffVec;
%x = xTemp + deltaMat;
x = xTemp;
