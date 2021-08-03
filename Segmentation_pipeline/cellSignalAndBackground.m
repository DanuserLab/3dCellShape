function [signalMean, signalMax, signalSTD, backgroundMean, backgroundSTD] = cellSignalAndBackground(image3D, imageBlurSize, sphereErodeSE, sphereDilateSE)

% cellSignalAndBackground - estimates the mean and standard deviation of both the signal and background by assuming an image of uniformly lit objects
%
% Blurs and then Otsu thresholds the image. Erodes the image and then sets
% the mean intensity of the eroded image to be the magnitude of the signal. 
% Dilates the thresholded image and then sets the standard deviation 
% outside the dilated region to be the noise.

% INPUTS:
%
% imageBlur      - the standard deviation in pixels of the gaussian that 
%                the image is blurred with prior to segmentation
%
% sphereErodeSE  - the structuring element for the erosion operation
%
% sphereDilateSE - the strcturing element for the dilation operation


% blur the image
imageBlured = filterGauss3D(image3D,imageBlurSize);
imageBlured = imageBlured-min(imageBlured(:));
imageBlured = imageBlured./max(imageBlured(:));

% threshold the image
imageThresh = imageBlured>graythresh(imageBlured(:)); %clear imageBlured; 

% fill in holes
imageThresh = imfill(imageThresh, 'holes');

% measure the mean and max signal intensity
imageErodeMask = imerode(imageThresh, sphereErodeSE); % erode the images
imageSignal = imageErodeMask.*image3D;
signalSTD = mean(imageSignal(imageErodeMask));
signalMax = max(imageSignal(imageErodeMask));
signalMean = mean(imageSignal(imageErodeMask)); %clear imageSignal imageErodeMask sphereErodeSE;

% measure the standard deviation of the background
imageDilateMask = imdilate(imageThresh, sphereDilateSE); %clear imageThresh;
imageBackground = (~imageDilateMask).*image3D; 
backgroundSTD = std(imageBackground(~imageDilateMask));
backgroundMean = mean(imageBackground(~imageDilateMask));
