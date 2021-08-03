function faceIntensities = measureIntensity(image3D, surface, radius)

% measureIntensity - measures the image intensity near each face of a mesh


% find the positions of each face
numFaces = size(surface.faces,1);
facePositions = zeros(numFaces,3);
for f = 1:numFaces
    verticesFace = surface.faces(f,:);
    facePositions(f,:) = (surface.vertices(verticesFace(1),:) + surface.vertices(verticesFace(2),:) + surface.vertices(verticesFace(3),:))/3;
end

% convert the pixels to a list of coordinates with associated intensities
pixelsIndices = find(image3D > 0);
[pixelsXYZ(:,2),pixelsXYZ(:,1),pixelsXYZ(:,3)] = ind2sub(size(image3D),pixelsIndices);

% call KD-tree on each face
faceIntensities.mean = zeros(numFaces,1);
tree = kdtree_build(pixelsXYZ);
for f = 1:numFaces
    indicesRange = kdtree_ball_query(tree, facePositions(f,:), radius);
    faceIntensities.mean(f) = mean(image3D(pixelsIndices(indicesRange)));
end

%% normalize the intensities by the mean face intensity
%faceIntensities.mean = faceIntensities.mean./(mean(faceIntensities.mean));
 

% %% debug plot
% figure
% cmap = flipud(makeColormap('div_spectral', 1024));
% cmap = flipud(makeColormap('div_pwg', 1024));
% climits = [prctile(faceIntensities.mean,1), prctile(faceIntensities.mean,99)];
% %climits = [0.5, 2];
% plotMeshFigure(image3D, surface, faceIntensities.mean, cmap, climits);

