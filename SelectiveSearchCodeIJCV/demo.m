% This demo shows how to use the software described in our IJCV paper: 
%   Selective Search for Object Recognition,
%   J.R.R. Uijlings, K.E.A. van de Sande, T. Gevers, A.W.M. Smeulders, IJCV 2013
%%
addpath('Dependencies');

fprintf('Demo of how to run the code for:\n');
fprintf('   J. Uijlings, K. van de Sande, T. Gevers, A. Smeulders\n');
fprintf('   Segmentation as Selective Search for Object Recognition\n');
fprintf('   IJCV 2013\n\n');

% Compile anisotropic gaussian filter
if(~exist('anigauss'))
    fprintf('Compiling the anisotropic gauss filtering of:\n');
    fprintf('   J. Geusebroek, A. Smeulders, and J. van de Weijer\n');
    fprintf('   Fast anisotropic gauss filtering\n');
    fprintf('   IEEE Transactions on Image Processing, 2003\n');
    fprintf('Source code/Project page:\n');
    fprintf('   http://staff.science.uva.nl/~mark/downloads.html#anigauss\n\n');
    mex Dependencies/anigaussm/anigauss_mex.c Dependencies/anigaussm/anigauss.c -output anigauss
end

if(~exist('mexCountWordsIndex'))
    mex Dependencies/mexCountWordsIndex.cpp
end

% Compile the code of Felzenszwalb and Huttenlocher, IJCV 2004.
if(~exist('mexFelzenSegmentIndex'))
    fprintf('Compiling the segmentation algorithm of:\n');
    fprintf('   P. Felzenszwalb and D. Huttenlocher\n');
    fprintf('   Efficient Graph-Based Image Segmentation\n');
    fprintf('   International Journal of Computer Vision, 2004\n');
    fprintf('Source code/Project page:\n');
    fprintf('   http://www.cs.brown.edu/~pff/segment/\n');
    fprintf('Note: A small Matlab wrapper was made.\n');
%     fprintf('   
    mex Dependencies/FelzenSegment/mexFelzenSegmentIndex.cpp -output mexFelzenSegmentIndex;
end

%%
% Parameters. Note that this controls the number of hierarchical
% segmentations which are combined.
colorTypes = {'Hsv', 'Lab', 'RGI', 'H', 'Intensity'};
colorType = colorTypes{1}; % Single color space for demo

% Here you specify which similarity functions to use in merging
simFunctionHandles = {@SSSimColourTextureSizeFillOrig, @SSSimTextureSizeFill, @SSSimBoxFillOrig, @SSSimSize};
simFunctionHandles = simFunctionHandles(1:2); % Two different merging strategies

% Thresholds for the Felzenszwalb and Huttenlocher segmentation algorithm.
% Note that by default, we set minSize = k, and sigma = 0.8.
k = 200; % controls size of segments of initial segmentation. 
minSize = k;
sigma = 0.8;

% As an example, use a single image
images = {'corywindowfull.jpg'};
im = imread(images{1});

% Perform Selective Search
[boxes blobIndIm blobBoxes hierarchy] = Image2HierarchicalGrouping(im, sigma, k, minSize, colorType, simFunctionHandles);
boxes = BoxRemoveDuplicates(boxes);

% Show boxes
%ShowRectsWithinImage(boxes, 5, 5, im);

% Show blobs which result from first similarity function
hBlobs = RecreateBlobHierarchyIndIm(blobIndIm, blobBoxes, hierarchy{1});
%ShowBlobs(hBlobs, 5, 5, im);

%windBlobs = [7,10,12,18,19,20,32,45,59,62,63,70,83,96,134,163,164,182,186,187,191,194,195,205,207,209,221,227,248,250,262,269,270,278,282];
%%
im = imread(images{1});
baseIm = rgb2gray(im2double(im));
redOver = double(zeros(size(baseIm)));
for i=1:length(windBlobs)%[1430,1431,1432]
    g = windBlobs(i)
    b = hBlobs{i};
    %imshow( baseIm(b.rect(1):b.rect(3), b.rect(2):b.rect(4)).*double(b.mask));
    masked = baseIm(b.rect(1):b.rect(3), b.rect(2):b.rect(4)).*-(1-double(b.mask));
    redOver(b.rect(1):b.rect(3), b.rect(2):b.rect(4)) = redOver(b.rect(1):b.rect(3), b.rect(2):b.rect(4)) + 1.0/length(windBlobs) * (1-double(b.mask));
    baseIm(b.rect(1):b.rect(3), b.rect(2):b.rect(4)) = baseIm(b.rect(1):b.rect(3), b.rect(2):b.rect(4)) - .5*masked;
end
im(redOver > prctile(redOver(:),60)) = 255;
imshow(im)

