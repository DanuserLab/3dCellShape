function [joinedWatersheds, joinedWatershedsSpill, rawWatersheds] = segmentBlebsLOS(surface, curvature, neighbors, otsuRatio, triangleRatio, losRatio, raysPerCompare)

% segment blebs from curvature using a watershed algorithm and then LOS merging

% perform a watershed segmentation of curvature on the mesh
rawWatersheds = labelWatersheds(neighbors, curvature); 

% caclulate an Otsu threshold level for positive curvature
curvatureThreshold = -1*graythresh(-1*curvature(curvature<0));

% merge watershed regions using a spill depth criterion
joinedWatershedsSpill = joinWatershedSpillDepth(-1*otsuRatio*curvatureThreshold, neighbors, rawWatersheds, curvature, 0, 0);

% merge watershed regions using a line-of-sight algorithm
joinedWatersheds = joinWatershedLOS(surface, losRatio, raysPerCompare, neighbors, joinedWatershedsSpill, 0);
