function [joinedWatersheds, joinedWatershedsSpill, watersheds] = segmentBlebsTriangle(surface, curvature, neighbors, otsuRatio, triangleRatio)

% segment blebs from curvature using a watershed algorithm and then merging watersheds in two ways

% caclulate an Otsu threshold level for positive curvature
curvatureThreshold = -1*graythresh(-1*curvature(curvature<0));

% perform a watershed segmentation of curvature on the mesh
watersheds = labelWatersheds(neighbors, curvature); 
% 
% % label flat regions (regions without a face above the curvature threshold)
% watersheds = joinFlatRegions(curvatureThreshold, rawWatersheds, curvature); 

% merge watershed regions using a spill depth criterion
joinedWatershedsSpill = joinWatershedSpillDepth(-1*otsuRatio*curvatureThreshold, neighbors, watersheds, curvature, 0, 0);
     
% merge watershed regions using a triangle ratio criterion   
joinedWatersheds = joinWatershedTriangle(surface, triangleRatio, neighbors, joinedWatershedsSpill); 
