function patchPairs = findAdjacentPatchPairs(surfaceSegment, neighbors)

% findAdjacentPatchPairs - given a mesh segmentation into patches, makes a list of adjacent patches


% make a graph of adjacent local patches (the last input controls if flat regions are included)
[watershedLabels, watershedGraph] = makeGraphFromLabel(neighbors, surfaceSegment, 1); 

% construct an initial list of adjacent patches to consider merging
patchPairs = [];
for w = randperm(length(watershedGraph))
   
    % find the label of the region
    wLabel = watershedLabels(w);

    % 0 indicates an unsuccessful segmentation and a negative label indicates a flat region
    if wLabel < 1
        continue
    end 

    % find the labels of its neighbors
    nLabels = watershedGraph{w};

    % return if there are no neighbors (because perhaps it is disjoint from the rest of the structure)
    if isempty(nLabels)
        continue
    end

    % remove 0 labels from the list of neighbors
    nLabels = nLabels(nLabels~=0);
    
    % add edges to the list of edges to check
    toAdd = [wLabel.*ones(length(nLabels),1), nLabels'];
    patchPairs = [patchPairs; toAdd]; 
end
