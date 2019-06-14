function LBP_data = CLBP(I,R,P,n,BlkInfo,Uflag)
% This function is written to extract basic LBP image descriptor.
% All steps are according to paper "Face Recognition with Local Binary
% Patterns" by T. Ahonen, A. Hadid and M. Pietik¨ainen (ECCV 2004, LNCS
% 3021, pp. 469–481)
%
% Syntax :
%           LBP_data = CLBP(I,n,Uflag)
% Inputs :
%           I        - Input image (doubled format grayscale image)
%           R        - Radius of descriptor (R > 1 and R < (min(size(I))/2 )
%           n        - length of feature vector (default 256)
%           BlkInfo  - Information of block size (Index image and block
%                      size in each dimension)
%           Ufalg    - control flag to detect Uniform patterns
% Output :
%           LBP_data - Structured output which contains :
%                      LBP Descriptor, LBP Image and Index of Uniform
%                      patterns
%
% -------------------------------
% Written by : S.Ehsan Mirsadeghi
% Date       : March 2015

% Check whether 'P' is multiplier of 4 or not.
if rem(P,4) ~=0
    error(' Improper value for "P" is defined. "P" should satisfy "P = 4K" ');
end
% Max number of samples around each pixel is limitted by the radius of
% descriptor.
if P > (4*R+4)
    error('P should less than or equal to (4*R) + 4')
end
% Maximum number of bins is limited by number of sample points.
if n > 2^P
    error('Number of bins should be less than 2^P')
end

BlkImg = BlkInfo.Image;
BlkSize = BlkInfo.Size;

% Rotation angle is defined according to number of samples needed.
Theta = 360/P;
[row,col] = size(I);

% Idx variable store result of comparison for each neighbourhood.
Idx = zeros(row*col,P);

% Form sample patch and compute number of shifted needed
NumP = 0:P-1;

% Define direction and number of needed shifted for images
% fisrt row contain Colloum shift and second row contans row shift.
PixelShift = round([R*cosd(NumP.*Theta);R*sind(NumP.*Theta)]);

% Use timer to compute elapsed time
t1 = tic;

%% Main Part - computing LBP using Shifted Images

% Build Shifted Images and compare local neighbourhood
for i = 1 : P
    % Step 1 : Build Shifted Images
    % --------------------------------------------------------------------
    % To avoid loop over each pixel of entire image, we can simply shift
    % images with proper number of pixels according to predefiend value.
    ShiftedImg  = circshift(I,[PixelShift(2,i)  PixelShift(1,i)]);
    
    % Step 2 : pixel-wise comparison
    % --------------------------------------------------------------------
    % In order to compute LBP, we should compare neighbourhood of a local
    % center pixel and constrcut a binary code. The LBP descriptor of each
    % pixel is decimal value of the binary code.
    temp1 = ShiftedImg >= I; Idx(:,i) = temp1(:);
end

% Step 3 : Combine binary bits to form binary code and find Uniform
% Patterns
% ------------------------------------------------------------------------

% Build Decimal Coefficient for binary Codes;
Coef = 2.^((P-1):-1:0);
BinCoef = repmat(Coef,size(Idx,1),1);

% Calculate equivalent decimal value for each pixel and obtain LBP code
LbpData = sum(Idx.*BinCoef,2);
LbpData = reshape(LbpData,size(I,1),size(I,2));

if strcmpi(Uflag,'true')
    % Detect Uniform Patterns
    % Unifrom pattern are those pattern whos contained more than 2
    % transition from '0' to '1' or vice versa. to detect such transition
    % we can use 'XOR' operator between two consecutive bit. 'XOR' result
    % '1' for transition and result '0' for no-change.
    TransBit = 0;
    
    for i = 1 : P-1
        TransBit = TransBit + xor(Idx(:,i),Idx(:,i+1));
    end
    TransBit = TransBit + xor(Idx(:,P),Idx(:,1));
    
    % Uniform Pattern Threshold
    U_th = 2;
    U_Pattren = TransBit >= U_th;
    U_Pattren = reshape(U_Pattren,size(I,1),size(I,2));
    LBP_data.Unif_Pattern = U_Pattren;
    
    % Discard border of LBP image which contains invalid information.
    tempLBP = LbpData(R+1:end-R,R+1:end-R);
    tempUP = U_Pattren(R+1:end-R,R+1:end-R);
    
    % Merge histogram of image blocks and constrcut descriptor.
    for k = 1 : BlkSize(1)*BlkSize(2)
        Indx = ( (k-1)*n ) + 1 : (k*n);
        temp1 = tempLBP(BlkImg==k);
        temp2 = tempUP(BlkImg==k);
        LBP_data.Desc(Indx) = hist(temp1(temp2),n);
    end
    
else % Reject Unifrom Pattern caculation and % Discard border of LBP image
    % which contains invalid information.
    tempLBP = LbpData(R+1:end-R,R+1:end-R);
    
    % Merge histogram of image blocks and constrcut descriptor.
    for k = 1 : BlkSize(1)*BlkSize(2)
        LBP_data.Desc = hist(tempLBP(:),n);
        Indx = ( (k-1)*n ) + 1 : (k*n);
        temp1 = tempLBP(BlkImg==k);
        LBP_data.Desc(Indx) = hist(temp1,n);
    end
end

% Sclae value of LBP for each pixel to range [0 255]
LbpImage = uint8(mat2gray(LbpData)*255);
LBP_data.Image = LbpImage;

% Read runtime
LBP_data.Etime = toc(t1);