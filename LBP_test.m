I = imread('cameraman.tif');

% Set parameters for LBP feature extraction
% -----------------------------------------
% Uniform Pattern usage
Uflag = 'true';
% Radius of Decsriptor
R = 8;
% Number of samples around each pixel
P = 8;
% Block size for row and column of image
BlkSize = [2 2];

% Call function to build index for each block of image.
ImSize = size(I);
BlkInfo = BlkIndex(ImSize(1:2),BlkSize,R);

% define length for LBP feature vector
LbpLength = (2^P);
LBP_data = CLBP(I,R,P,LbpLength,BlkInfo,Uflag);

% show result
subplot(2,2,1)
imshow(I)
title('input image')

subplot(2,2,2)
imshow(LBP_data.Image)
title('LBP image')

subplot(2,2,[3 4])
bar(LBP_data.Desc)
title('LBP descriptor')