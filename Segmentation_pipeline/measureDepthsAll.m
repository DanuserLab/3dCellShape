function [spillDepths, spillNeighbors, ridgeHeights] = measureDepthsAll(faceNeighbors, watersheds, watershedLabels, watershedGraph, measure)

% measureDepthsAll - measure the depth and spillover neighbor for each watershed region


% initialize matrices
numWatersheds = length(watershedLabels);
spillDepths = Inf(numWatersheds, 1);
spillNeighbors = zeros(numWatersheds, 1);
ridgeHeights = zeros(numWatersheds, 1);

% iterate through the regions
for w = 1:numWatersheds
    
    % measure the spill depth and spill neighbor for the region
    [spillDepths(w,1), spillNeighbors(w,1), ridgeHeights(w,1)] = measureDepthOneRegion(w, faceNeighbors, watersheds, watershedLabels, watershedGraph, measure);
 
end
