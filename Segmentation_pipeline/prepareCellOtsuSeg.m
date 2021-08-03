function [image3D, level] = prepareCellOtsuSeg(image3D)

% prepareCellOtsuSeg - calculates an Otsu threshold and prepares the image for thresholding

% normalize the image intensity
image3D = im2double(image3D);
image3D = image3D-min(image3D(:));
image3D = image3D./max(image3D(:));

% calculate the Otsu threshold
level = graythresh(image3D(:));

% fill holes in the grayscale image
image3D(isnan(image3D)) = 0;
image3D = imfill(image3D); 