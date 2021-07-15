function distanceOnMesh = distanceTransformPatches(watersheds, neighbors)

% distanceTransformPatches - given a segmented mesh, for each face finds the distance to the edge of the nearest segmented patch 

% initialize a distance matrix for the mesh
distanceOnMesh = inf(length(watersheds),1);

% iterate through the distances from the edge of the watershed until none remain
curDist = 0;
onBoundary = 1;
while max(onBoundary) == 1
    
    % find the faces on the edge of the watersheds
    onBoundary = logical(findBoundaryFaces(watersheds, neighbors, 'single'));
    
    % update the distance matrix
    distanceOnMesh(onBoundary) = curDist;
    curDist = curDist + 1;
    
    % shrink the watersheds
    watersheds(onBoundary) = 0;

end