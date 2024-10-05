function dss = dss_index(img1, img2, sigma, C)
%DSS DCT Subband Similarity index for measuring image quality
%   DSS = DSS_INDEX(IMG1, IMG2) calculates the DCT Subband Similarity (DSS)
%   score for image IMG1, with the image IMG2 as the reference. IMG1 and
%   IMG2 should be 2D grayscale images, and must be of the same size.
%
%   DSS = DSS_INDEX(IMG1, IMG2, SIGMA, C) calculates the DSS score
%   with control over parameters of the computation. Parameters include:
%      sigma - Specifies the standard deviation of the Gaussian that
%              determines the proportion between the weight given to low
%              spatial frequencies and to high spatial frequencies.
%              Default value: sigma = 1.55
%      C     - Specifies constants in the DSS subband similarity equations
%              (see the reference paper below). C should be a vector of
%              size [1 2] where the first element in C is for the DC
%              equation and the second element in C is for the AC equation.
%              Defualt value: C = [1000 300]
%
%
%   This function is an implementation of the algorithm described in the
%   following paper:
%       Amnon Balanov, Arik Schwartz, Yair Moshe, and Nimrod Peleg,
%       "Image Quality Assessment based on DCT Subband Similarity," 22nd
%       IEEE International Conference on Image PRocessing (ICIP 2015).
%
%
%   Example
%   ---------
%   This example shows how to compute DSS score for a noisy image given
%   the original reference image.
%
%   img2 = imread('cameraman.tif');
%   img1 = imnoise(img2, 'gaussian', 0, 0.001);
%
%   subplot(1,2,1); imshow(img2); title('Reference Image');
%   subplot(1,2,2); imshow(img1); title('Noisy Image');
%
%   dss = dss_index(img1,img2);
%
%   fprintf('The DSS score is %0.4f\n',dss);
%

%   Version 1.00
%   Copyright(c) 2015, Yair Moshe
%   Signal and Image Processing Laboratory (SIPL)
%   Department of Electrical Engineering
%   Technion - Israel Institute of Technology
%   Technion City, Haifa 32000, Israel
%   Tel: +(972)4-8294746
%   e-mail: yair@ee.technion.ac.il
%   WWW: sipl.technion.ac.il

%% Parse inputs
narginchk(2,4);

if isempty(img1)
    error('Input image cannot be empty.')
end

if (~ismatrix(img1))
    error('img1 must be a grayscale image.')
end

if (size(img1) ~= size(img2))
    error('img1 and img2 must be of the same size.')
end

if (nargin == 3 || nargin == 4)
    if (~isscalar(sigma))
        error('sigma must be scalar.');
    end
else
    sigma = 1.55;
end

if (nargin == 4)
    if ((size(C,1) ~= 1) || (size(C,2) ~= 2))
        error('C must be of size [1 2].');
    end
else
    C = [1000 300];
end


%% Compute DSS

% Crop images size to the closest multiplication of 8
[nRows, nCols] = size(img1);
nRows = 8*floor(nRows/8);
nCols = 8*floor(nCols/8);
img1 = img1(1:nRows, 1:nCols);
img2 = img2(1:nRows, 1:nCols);

% Channel decomposition for both images by 8x8 2D DCT
img1Decomp = dct_decomp(img1);
img2Decomp = dct_decomp(img2);

% Create a Gauusian window that will be used to weight subbands scores
[X,Y] = meshgrid(1:8);
distance = sqrt((X-0.5).^2 + (Y-0.5).^2);
w = real(exp(-((distance.^2)/(2*sigma^2))));

% Compute similarity between each subband in img1 and img2
subbandSimilarity = zeros(8,8);
smallWeightThresh = 1e-2;
for m = 1:8
    for n = 1:8
        % Skip subbands with very small weight
        if(w(m,n) < smallWeightThresh)
            w(m,n) = 0;
            continue;
        end
        
        subbandSimilarity(m,n) = subband_similarity( ...
            img1Decomp(m:8:end, n:8:end), ...
            img2Decomp(m:8:end, n:8:end), ...
            m, n, C);
    end
end

% Weight subbands similarity scores
dss =  sum(sum(subbandSimilarity .* (w/sum(w(:)))));

end


%% Channel decomposition for an image by 8x8 2D DCT
function decomp = dct_decomp(img)

[nRows, nCols] = size(img);
D = dctmtx(8);
doubleImg = double(img);
decomp = zeros(nRows,nCols);

for blockNumInRow=1:1:(nRows/8)
    for blockNumInColumn=1:1:(nCols/8)
        curBlock = doubleImg( ...
            (1:8) + 8*(blockNumInRow-1),(1:8) + 8*(blockNumInColumn-1));
        decomp( ...
            (1:8) + 8*(blockNumInRow-1), ...
            (1:8) + 8*(blockNumInColumn-1)) = D*curBlock*D';
    end
end

end


%% Compute similarity between a subband in img1Subband and img2Subband
function similarity = subband_similarity(img1Subband, img2Subband, m, n, Cs)

if((m == 1) && (n == 1))
    C = Cs(1);  % DC
else
    C = Cs(2);  % AC
end

% Compute local variance
window = fspecial('gaussian', 3, 1.5);
mu1 = imfilter(img1Subband, window);
mu2 = imfilter(img2Subband, window);
sigma1_sq = imfilter(img1Subband.*img1Subband, window) - mu1.*mu1;
sigma2_sq = imfilter(img2Subband.*img2Subband, window) - mu2.*mu2;
sigma12 = imfilter(img1Subband.*img2Subband, window) - mu1.*mu2;
sigma1_sq(sigma1_sq < 0) = 0;
sigma2_sq(sigma2_sq < 0) = 0;

varLeftTerm = ...
    (2*sqrt(sigma1_sq .* sigma2_sq) + C) ./ (sigma1_sq + sigma2_sq + C);

% Spatial pooling of worst scores
percentile = 0.05;
percentileIndex = round(percentile * numel(varLeftTerm));
sortedVarLeftTerm = sort(varLeftTerm(:));
similarity = mean(sortedVarLeftTerm(1:percentileIndex));

% For DC, multiply by a right term
if ((m == 1) && (n == 1))
    varRightTerm = ((sigma12 + C) ./ (sqrt(sigma1_sq .* sigma2_sq) + C));
    sortedVarRightTerm = sort(varRightTerm(:));
    simRightTerm = mean(sortedVarRightTerm(1:percentileIndex));
    similarity = similarity * simRightTerm;
end

end






