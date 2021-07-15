function [surface, combinedImage, level] = threeLevelSteerableSegmentation3D(image3D, image3DnotApodized, steerableType, scales, insideGamma, insideBlur, insideDilateRadius, insideErodeRadius)

% threeLevelSteerableSegmentation3D - combines a steerable filter of a non_Apodized image with an Otsu filter and an "inside" filter of apodized images


%figure; imagesc(max(image3D(:,:,300:350), [], 3)); axis equal; axis off; colormap(gray); title('raw'); colorbar;

% create an "inside" image from the apodized image
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
%figure; imagesc(max(image3Dthresh(:,:,300:350), [], 3)); axis equal; axis off; colormap(gray); title('inside'); colorbar;

% create a steerable filtered image from the non-apodized image
[steerableResponse, ~, ~, ~] = multiscaleSteerableFilter3D(image3DnotApodized.^insideGamma, steerableType, scales);
levelSteer = mean(steerableResponse(:)) + 3*std(steerableResponse(:)); % 6
%figure; imagesc(max(steerableResponse(:,:,300:350), [], 3)); axis equal; axis off; colormap(gray); title('steer'); colorbar;

% combine the three images
[surface, combinedImage, level] = combineThreeImagesMeshOtsu(image3D, 'Otsu', image3Dthresh, 'Otsu', steerableResponse, levelSteer, 1);
%figure; imagesc(max(combinedImage(:,:,300:350), [], 3)); axis equal; axis off; colormap(gray); title('combine'); colorbar;
%1;
