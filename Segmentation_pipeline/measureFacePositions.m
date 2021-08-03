function positions = measureFacePositions(smoothedSurface, neighbors)

% measureFacePositions - measure the positions of mesh faces


% initialize variables
numFaces = size(neighbors,1);
positions = zeros(numFaces,3);

% iterate through the faces
for f = 1:numFaces
    
    % find the position of each face
    verticesFace = smoothedSurface.faces(f,:);
    positions(f,:) = (smoothedSurface.vertices(verticesFace(1),:) + smoothedSurface.vertices(verticesFace(2),:) + smoothedSurface.vertices(verticesFace(3),:))/3;
    
end