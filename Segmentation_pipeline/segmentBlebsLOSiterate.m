function [mergeList, joinedWatersheds, joinedWatershedsSpill, rawWatersheds, joinedWatershedsIntermediate] = segmentBlebsLOSiterate(surface, curvature, neighbors, otsuRatio, triangleRatio, losRatio, raysPerCompare)

% segment blebs from curvature using a watershed algorithm and then iteratively merging watersheds in two different ways

% perform a watershed segmentation of curvature on the mesh
rawWatersheds = labelWatersheds(neighbors, curvature); 

% caclulate an Otsu threshold level for positive curvature
curvatureThreshold = -1*graythresh(-1*curvature(curvature<0));

% merge watershed regions using a spill depth criterion
joinedWatershedsSpill = joinWatershedSpillDepth(-1*otsuRatio*curvatureThreshold, neighbors, rawWatersheds, curvature, 0, 0);

% merge watershed regions using a triangle ratio criterion   
if nargout > 4
    [joinedWatersheds, mergeList, joinedWatershedsIntermediate] = joinWatershedTriangleLOS(surface, triangleRatio, losRatio, raysPerCompare, neighbors, joinedWatershedsSpill); 
else
    [joinedWatersheds, mergeList] = joinWatershedTriangleLOS(surface, triangleRatio, losRatio, raysPerCompare, neighbors, joinedWatershedsSpill); 
end

