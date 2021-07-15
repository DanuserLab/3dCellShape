function motion = measureMeshMotionNearest(surfaceA, surfaceB, numNearestNeighbors)

% measureMeshMotionNearest - measure the distance from each point in surfaceA to the closest point in surfaceB, takes the median across numNearestNeighbors

% find the positions of the faces in the surface A
numFaces = size(surfaceA.faces,1);
positionsOld = zeros(numFaces,3);
for f = 1:numFaces
    
    % find the position of each face
    verticesFace = surfaceA.faces(f,:);
    positionsOld(f,:) = (surfaceA.vertices(verticesFace(1),:) + surfaceA.vertices(verticesFace(2),:) + surfaceA.vertices(verticesFace(3),:))/3;
    
end

% find the positions of the faces in the surface B
numFaces = size(surfaceB.faces,1);
positionsNew = zeros(numFaces,3);
for f = 1:numFaces
    
    % find the position of each face
    verticesFace = surfaceB.faces(f,:);
    positionsNew(f,:) = (surfaceB.vertices(verticesFace(1),:) + surfaceB.vertices(verticesFace(2),:) + surfaceB.vertices(verticesFace(3),:))/3;
    
end

% find the face normals to surface A
[faceNormals,~] = surfaceNormalsFast(surfaceA);

% construct a kd tree of the new surface
toTest = positionsNew;
tree = KDTreeSearcher(toTest);

% for each face in the old frame, find the median distance to the next frame
positionInNew = NaN(size(positionsOld, 1), 3);
motion = NaN(size(positionsOld, 1), 1);
nearestInNew = knnsearch(tree, positionsOld, 'K', numNearestNeighbors);
for p = 1:size(positionsOld,1) % do we really need a for-loop?
    
    % find the positions of the nearest points
    nearestPositionsInNew = toTest(nearestInNew(p,:), :);
    positionInNew(p,:) = nearestPositionsInNew(1,:);
    
    % find the magnitude of the motion 
    directionVectors = repmat(positionsOld(p,:),numNearestNeighbors,1)-nearestPositionsInNew;
    motion(p,1) = median(sqrt(sum(directionVectors.^2, 2)));
    
    % find the direction of the motion
    dirVec = directionVectors(1,:);
    direction = sign(dirVec*faceNormals(p,:)');
    motion(p,1) = motion(p,1)*direction;
end
% 
% 
% % debug code (plot the two meshes)
% figure
% % plot the old mesh
% meshHandle1 = patch(surfaceA,'FaceColor','b','EdgeColor','none','FaceAlpha',0.5);
% hold on 
% meshHandle2 = patch(surfaceB,'FaceColor','r','EdgeColor','none','FaceAlpha',0.5);
% daspect([1 1 1]); axis off; 
% camlookat(meshHandle1); 
% light_handle = camlight(0,0); camlight(120,-60); camlight(240,60);
% lighting phong;
% 
