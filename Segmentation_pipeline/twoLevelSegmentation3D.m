function [surface, combinedImage, level] = twoLevelSegmentation3D(image3D, insideGamma, insideBlur, insideDilateRadius, insideErodeRadius)

% twoLevelSegmentation3D combines an Otsu filter and an "inside" filter


% add a black border to the image in case the cell touches the border
image3D = addBlackBorder(image3D, 1);

% create an "inside" image
image3Dblurred = image3D.^insideGamma;
image3Dblurred = filterGauss3D(image3Dblurred, insideBlur);
image3DthreshValue = thresholdOtsu(image3Dblurred(:));
image3Dthresh = image3Dblurred > image3DthreshValue;
image3Dthresh = imdilate(image3Dthresh, makeSphere3D(insideDilateRadius));
for h = 1:size(image3Dthresh, 3)
    image3Dthresh(:,:,h) = imfill(image3Dthresh(:,:,h), 'holes');
end
image3Dthresh = double(imerode(image3Dthresh, makeSphere3D(insideErodeRadius)));
image3Dthresh = filterGauss3D(image3Dthresh, 1);

% create a normalized "cell" image
foreThresh = thresholdOtsu(image3D(:));
image3D = image3D - foreThresh;
image3D = image3D/std(image3D(:));

% combine both images
combinedImage = max(image3Dthresh, image3D);
combinedImage = imfill(combinedImage);
combinedImage(combinedImage<0) = 0;
level = 0.999;

% remove disconnected components that might make the mesh irregular
combinedImage = removeDisconectedComponents(combinedImage, level);

% generate a surface
surface = isosurface(combinedImage, level);

