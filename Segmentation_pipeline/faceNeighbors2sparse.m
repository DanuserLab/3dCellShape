function sparseMatrix = faceNeighbors2sparse(surface, neighbors)

% faceNeighbors2sparse - Converts an edge list of faces to a sparse matrix weighted by 1/distance

% measure the distance between adjacent faces
[~, distances] = measureEdgeLengths(surface, neighbors);

fromNode = 1:size(neighbors,1); % the edges go from these nodes
fromNode = repmat(fromNode',3,1); 
toNode = [neighbors(:,1); neighbors(:,2); neighbors(:,3)]; % the edges go to these nodes
edgeWeights = 1./[distances(:,1); distances(:,2); distances(:,3)];
%edgeWeights = ones(size(toNode,1),1);

% create the sparse matrix
sparseMatrix = sparse(fromNode, toNode, edgeWeights);
