function [positions, distances] = measureEdgeLengths(smoothedSurface, neighbors)

% measureEdgeLengths - measure the position of faces and the Euclidean distance between adjacent faces


% initialize variables
numFaces = size(neighbors,1);
%positions = zeros(numFaces,3);
distances = zeros(numFaces,3);

% measure the positions of mesh faces
positions = measureFacePositions(smoothedSurface, neighbors);
 
% % iterate through the faces twice
% for f = 1:numFaces
%     
%     % find the position of each face
%     verticesFace = smoothedSurface.faces(f,:);
%     positions(f,:) = (smoothedSurface.vertices(verticesFace(1),:) + smoothedSurface.vertices(verticesFace(2),:) + smoothedSurface.vertices(verticesFace(3),:))/3;
%     
% end

% find the distances between each face and each of its three neighbors
for f = 1:numFaces %iterate through the faces
    
    for n=1:3 % iterate thhrough the neighbors
        distances(f,n) = sum((positions(f,:) - positions(neighbors(f,n),:)).^2);
    end

end
