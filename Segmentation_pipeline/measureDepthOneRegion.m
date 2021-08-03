function [spillDepth, spillNeighbor, ridgeHeight] = measureDepthOneRegion(w, faceNeighbors, watersheds, watershedLabels, watershedGraph, measure)
 
% measureDepthOneRegion - find the watershed depth and spill neighbor of a single region (here w is the label of the watershedRegion being measured)


% find the label of the region
wLabel = watershedLabels(w);

% 0 indicates an unsuccessful segmentation and a negative label indicates a flat region
if wLabel < 1
    spillDepth = Inf; 
    spillNeighbor = 0;
    ridgeHeight = 0;
    return
end 

% find the label of its neighbors
nLabels = watershedGraph{w};

% return if there are no neighbors (because perhaps it is disjoint from the rest of the structure)
if isempty(nLabels)
    spillDepth = Inf; 
    spillNeighbor = 0;
    ridgeHeight = 0;
    return
end

% remove the flat regions from the list of neighbors
nLabels = nLabels(nLabels>0);

% if only the flat region is a neighbor set the spillDepth to Inf and return
if isempty(nLabels)
    spillDepth = Inf; 
    spillNeighbor = 0;
    ridgeHeight = 0;
    return
end

% find the lowest value of the measure in the region
lowestValue = min(measure(wLabel==watersheds));

% find the labels of the faces in the region
faceIndex = 1:length(watersheds);
facesInRegion = faceIndex'.*(wLabel==watersheds);
facesInRegion = facesInRegion(facesInRegion>0);

% make an edge list of edges associated with the region
neighborsRegion = faceNeighbors.*repmat(wLabel==watersheds,1,3);
edgeList = [facesInRegion, neighborsRegion(neighborsRegion(:,1)>0,1); facesInRegion, neighborsRegion(neighborsRegion(:,2)>0,2); facesInRegion, neighborsRegion(neighborsRegion(:,3)>0,3)];

% find the spillover depth for each neighbor
depthsNeighbors = zeros(length(nLabels),1);
heightNeighbors = zeros(length(nLabels),1);
for n=1:length(nLabels)
    
    % find the labels of the faces in this neighboring region
    facesInNeighbor = faceIndex'.*(nLabels(n)==watersheds);
    facesInNeighbor = facesInNeighbor(facesInNeighbor>0);

    % find the edges that connect the watershed to the neighor
    boundaryEdgesMask = ismembc(edgeList(:,2),facesInNeighbor);
    boundaryEdges = [edgeList(boundaryEdgesMask>0,1), edgeList(boundaryEdgesMask>0,2)];

    % find the depth of each edge
    depthsEdges = zeros(size(boundaryEdges,1),1);
    for b=1:size(boundaryEdges,1)
        depthsEdges(b) = max(measure(boundaryEdges(b,1)), measure(boundaryEdges(b,2)));
    end
    
    % if something goes wrong, make the depth infinite
    if isempty(depthsEdges)
        depthsNeighbors(n,1) = Inf;
        heightNeighbors(n,1) = Inf;
    else % find the minimum depth of the neighbor
        depthsNeighbors(n,1) = min(depthsEdges)-lowestValue;
        heightNeighbors(n,1) = max(depthsEdges)-lowestValue;
    end

end

% find the spill neighbor of the watershed region
[spillDepth, spillNeighborIndex] = min(depthsNeighbors);
spillNeighbor = nLabels(spillNeighborIndex(1));
ridgeHeight = heightNeighbors(spillNeighborIndex,1);