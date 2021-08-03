function [watersheds, watershedGraph, edgesToCheck, closureSurfaceArea] = mergeRegionPairTriangleLOS(mesh, positions, watersheds, watershedGraph, watershedLabels, neighbors, edgesToCheck, closureSurfaceArea, meshLength, raysPerCompare)

% mergeRegionPairTriangleLOS - merges a pair of regions and updates structures needed for merging according to the triangle and LOS rules (specific to Morphology3D)


% label the combined region with the lower of the two labels as long as it is positive
mergeLabel = min(edgesToCheck(1,1:2));
if mergeLabel < 0, mergeLabel = max(edgesToCheck(1,1:2)); end
mergeDestroy = setdiff(edgesToCheck(1,1:2), mergeLabel);

% update the list of watersheds
watersheds(watersheds == mergeDestroy) = mergeLabel;

% find the indices of the labels in watershedGraphs
labelIndex = 1:length(watershedLabels);
mergeLabelIndex = labelIndex(watershedLabels==mergeLabel);
mergeDestroyIndex = labelIndex(watershedLabels==mergeDestroy);

% update watershedGraph, which lists the neighbors of each region (this is as in joinWatershedSpillDepth and should perhaps be merged)
neighborsOfDestroyed = watershedGraph{mergeDestroyIndex}; % find the neighbors of the desroyed label
neighborsOfDestroyed = setdiff(neighborsOfDestroyed, mergeLabel);
watershedGraph{mergeLabelIndex} = setdiff([watershedGraph{mergeLabelIndex}, neighborsOfDestroyed], [mergeLabel, mergeDestroy]); % update mergeLabel
watershedGraph{mergeDestroyIndex} = []; % update the destroyed label
for n = 1:length(neighborsOfDestroyed) % replace the destoyed label with the merged label in each of the destroyed neighbors lists of neighbors
    neighborIndex = labelIndex'.*(watershedLabels==neighborsOfDestroyed(n));
    neighborIndex = neighborIndex(neighborIndex~=0);
    watershedGraph{neighborIndex} = setdiff([watershedGraph{neighborIndex}, mergeLabel], mergeDestroy);
end

% update the list of closure surface areas
[~, closureSurfaceAreaCombinedRegion, ~] = closeMesh(mergeLabel, mesh, watersheds, neighbors);
closureSurfaceArea(mergeLabelIndex) = closureSurfaceAreaCombinedRegion;
closureSurfaceArea(mergeDestroyIndex) = NaN;

% remove all instances of both watersheds in the list of edges to check
toRemove = logical( (edgesToCheck(:,1)==mergeLabel) + (edgesToCheck(:,2)==mergeLabel) + ...
    (edgesToCheck(:,1)==mergeDestroy) + (edgesToCheck(:,2)==mergeDestroy) );
edgesToCheckNew = [];
for p = 1:size(edgesToCheck,1)
    if toRemove(p) == 0
        edgesToCheckNew = [edgesToCheckNew; edgesToCheck(p,:)];
    end
end
edgesToCheck = edgesToCheckNew;

% calculate the triangle measure and mutual visibility for the pairs to be added and append the new pairs to the list
nLabels = watershedGraph{mergeLabelIndex};
pairsToAdd = [mergeLabel.*ones(length(nLabels),1), nLabels'];
faceIndex = 1:length(watersheds);
for p = 1:size(pairsToAdd, 1)
    [patchLengthSmall, patchLengthBig] = calculatePatchLength(positions, watersheds, faceIndex, pairsToAdd(p,1), pairsToAdd(p,2), meshLength);
    mutVis = calculateMutualVisibilityPair(mesh, positions, watersheds, pairsToAdd(p,1), pairsToAdd(p,2), patchLengthSmall, raysPerCompare, 1);
    triMeas = calculateTriangleMeasurePair(mesh, watersheds, watershedLabels, neighbors, closureSurfaceArea, pairsToAdd(p,1), pairsToAdd(p,2), patchLengthBig, meshLength);
    edgesToCheck = [edgesToCheck; pairsToAdd(p,1:2), mutVis, triMeas, patchLengthSmall, patchLengthBig];
end