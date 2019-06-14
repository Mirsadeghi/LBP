function BlkInfo = BlkIndex(ImSize,BlkSize,R)
% This function is written to build index image which contains value from 1
% to BlkSize(1)*BlkSize(2). Each number in this range define a block for
% image.
%
% Syntax :
%           BlkInfo = BlkIndex(ImSize,BlkSize,R)
% Inputs :
%           ImSize   - Size of image we want to split. Imsize(1) define
%           rows of image and ImSize(2) define columns of image.
%           BlkSize  - number of block in each dimension of image. BlkSize
%           must be real integer.
%           R        - Border of image which contains invalid information.
% Output :
%           BlkInfo  - Output arguments in the structured form.
%                      Contains index matrix and block size;
%
% -------------------------------
% Written by : S.Ehsan Mirsadeghi
% Company    : Green Science
% Date       : March 2015

row = ImSize(1);
col = ImSize(2);

% Build image blocks according to defined block size
RowBlk = round(row/BlkSize(1));
ColBlk = round(col/BlkSize(2));
BlkImg = kron(reshape(1:BlkSize(1)*BlkSize(2),BlkSize(1),BlkSize(2)),ones(RowBlk,ColBlk));

if size(BlkImg,1) > row
    % Reduce size of index matrix if it's greater than image
    BlkImg = BlkImg(1:row,:);
end
if size(BlkImg,2) > col
    % Reduce size of index matrix if it's greater than image
    BlkImg = BlkImg(:,1:col);
end
if size(BlkImg,1) < row
    % Increase size of index matrix if it's smaller than image
    BlkImg = [BlkImg;BlkImg(end - rem(row,BlkSize):end,:)];
end
if size(BlkImg,2) < col
    % Increase size of index matrix if it's smaller than image
    BlkImg = [BlkImg BlkImg(:,end - rem(col,BlkSize):end)];
end

% Crop index matrix
BlkImg = BlkImg(1:row,1:col);

% Discard invalid information in the border of image.
BlkImg = BlkImg(R+1:end-R,R+1:end-R);
BlkInfo.Image = BlkImg;
BlkInfo.Size = BlkSize;