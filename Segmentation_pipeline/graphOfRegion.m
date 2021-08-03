function [sparseRegion, nodeLabels] = graphOfRegion(neighbors,watersheds,regionLabel,varargin)

% graphOfRegion - constructs a sparse graph of a region (optionally weighted by distance)

% the last optional input should be edge weights
if nargin == 4
    distances = varargin{1};
end

% find a list of the faces in the region
faceIndex = 1:length(watersheds);
facesInRegion = faceIndex'.*(regionLabel==watersheds);
facesInRegion = facesInRegion(facesInRegion>0);

% make a list of edges associated with the region
fromNode = repmat(facesInRegion,3,1);
neighborsRegion = neighbors.*repmat(regionLabel==watersheds,1,3);
toNode = [neighborsRegion(neighborsRegion(:,1)>0,1); neighborsRegion(neighborsRegion(:,2)>0,2); neighborsRegion(neighborsRegion(:,3)>0,3)];

% relabel the nodes so that they have the lowest label possible 
nodeLabels = unique([facesInRegion; toNode]);
fromNodeRelabeled = zeros(length(fromNode),1);
toNodeRelabeled = zeros(length(toNode),1);
for n=1:length(nodeLabels)
    fromNodeRelabeled = fromNodeRelabeled + n.*(nodeLabels(n)==fromNode);
    toNodeRelabeled = toNodeRelabeled + n.*(nodeLabels(n)==toNode);
end

% assign edge weights
if nargin == 4
    distancesRegion = distances.*repmat(regionLabel==watersheds,1,3);
    edgeWeights = [distancesRegion(distancesRegion(:,1)>0,1); distancesRegion(distancesRegion(:,2)>0,2); distancesRegion(distancesRegion(:,3)>0,3)];
else
    edgeWeights = ones(size(toNode,1),1);
end

% make a sparse matrix of adjacent faces in the region
sparseRegion = sparse(fromNodeRelabeled, toNodeRelabeled, edgeWeights, length(nodeLabels), length(nodeLabels));
