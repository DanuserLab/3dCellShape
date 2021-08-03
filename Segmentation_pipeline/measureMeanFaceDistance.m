function meanFacesDistance = measureMeanFaceDistance(facePositions, neighbors)

% meanFacesDistance - find the mean distance between adjacent faces

distances = zeros(size(neighbors));
for f = 1:length(facePositions)
    
    % calculate the distance between each face and its three neighbors
    for x = 1:3
        distances(f,x) = sqrt(sum((facePositions(f,:) - facePositions(neighbors(f,x),:)).^2,2));
    end

end

% find the mean distance
meanFacesDistance = mean(distances(:));