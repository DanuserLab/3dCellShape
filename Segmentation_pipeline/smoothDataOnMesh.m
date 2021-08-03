function dataOnMesh = smoothDataOnMesh(surface, neighbors, dataOnMesh, numIter)

% smoothDataOnMesh - Perform a simple iterative smoothing of data defined on the mesh


% construct a sparse matrix of the faces graph
sparseMesh = faceNeighbors2sparse(surface, neighbors);

% connect each node on the mesh to itself
numNodes = size(sparseMesh,1);
sparseMesh = sparseMesh + speye(numNodes);
normalization = spdiags(full(sum(sparseMesh,2).^(-1)), 0, numNodes, numNodes);
sparseMesh = normalization*sparseMesh;

% repeatedly smooth
for k=1:numIter
    dataOnMesh = sparseMesh*dataOnMesh;
end