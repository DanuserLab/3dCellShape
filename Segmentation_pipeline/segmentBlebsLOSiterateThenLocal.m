function [mergeList, joinedWatersheds, joinedWatershedsPreLocal, joinedWatershedsSpill, rawWatersheds, joinedWatershedsIntermediate] = segmentBlebsLOSiterateThenLocal(surface, curvature, neighbors, otsuRatio, triangleRatio, losRatio, raysPerCompare)

% segment blebs from curvature using a watershed algorithm and then iteratively merging watersheds in two different ways

% perform a watershed segmentation of curvature on the mesh
rawWatersheds = labelWatersheds(neighbors, curvature); 

% caclulate an Otsu threshold level for positive curvature
curvatureThreshold = -1*graythresh(-1*curvature(curvature<0));

% merge watershed regions using a spill depth criterion
joinedWatershedsSpill = joinWatershedSpillDepth(-1*otsuRatio*curvatureThreshold, neighbors, rawWatersheds, curvature, 0, 0);

% merge watershed regions using a triangle ratio criterion and an LOS merge
if nargout > 4
    [joinedWatershedsPreLocal, mergeList, joinedWatershedsIntermediate] = joinWatershedTriangleLOS(surface, triangleRatio, losRatio, raysPerCompare, neighbors, joinedWatershedsSpill); 
else
    [joinedWatershedsPreLocal, mergeList] = joinWatershedTriangleLOS(surface, triangleRatio, losRatio, raysPerCompare, neighbors, joinedWatershedsSpill); 
end

% perform a local LOS merge
disp('Locally merging')
joinedWatersheds = joinWatershedLOS(surface, losRatio, raysPerCompare, neighbors, joinedWatershedsPreLocal, 1);

