% second price auction
function [bidResX, secondPriceList] = second_price(bidValuationMat)

[~,bidResXIndex] = max(bidValuationMat, [], 2);
bidResX = zeros(size(bidValuationMat));
bidResXIndexMat = (bidResXIndex-1)*size(bidValuationMat, 1)+[1:1:size(bidValuationMat, 1)].';
bidResX(bidResXIndexMat) = 1;

for indBlk = 1:size(bidValuationMat, 1)
    % if nobody has bid for this block, then allocate the block to some player at random
    if sum(bidValuationMat(indBlk, :)) == 0
        bidResX(indBlk, 1) = 0;
        bidResX(indBlk, floor(rand(1)*(size(bidValuationMat, 2)-1))+1) = 1;
    end
end

% second price
bidValuationMat(find(bidResX)) = 0;
[~,secondPriceIndexRow] = max(bidValuationMat, [], 2);
secondPriceIndex = (secondPriceIndexRow-1)*size(bidValuationMat, 1)+[1:1:size(bidValuationMat, 1)].';
secondPriceList = bidValuationMat(secondPriceIndex);



