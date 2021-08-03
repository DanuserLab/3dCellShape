function curvatureImage = makeCurvatureImage(imageSize, surface, curvature, neighbors)

% makeCurvatureImage - generates an image where each pixel is the average curvature of the faces at that location

% initialize variables for the curvature image and number of faces in each frame
curvatureImage = nan(imageSize);
curvatureCount = zeros(imageSize);

% calculate the positions of the faces
facePositions = measureFacePositions(surface, neighbors);

% iterate through the faces
for f = 1:length(facePositions)
    
    % find what pixel the face occupies
    pixelLocation = floor(facePositions(f,:));
    
    % update the number of faces at that position
    curvatureCount(pixelLocation(2), pixelLocation(1), pixelLocation(3)) = curvatureCount(pixelLocation(2), pixelLocation(1), pixelLocation(3)) + 1;
    count = curvatureCount(pixelLocation(2), pixelLocation(1), pixelLocation(3));
    
    % find the mean curvature so far
    if count == 1
        curvatureImage(pixelLocation(2), pixelLocation(1), pixelLocation(3)) = curvature(f);
    else
        curvatureImage(pixelLocation(2), pixelLocation(1), pixelLocation(3)) = ((count-1)*curvatureImage(pixelLocation(2), pixelLocation(1), pixelLocation(3)) + curvature(f))/count;
    end
    
end