function medianFiltered = medianFilterKD(surface, measure, radius)

% medianFilterKD - Median filter the mesh in real 3-D space


% get the face center positions 
nFaces = size(surface.faces,1);
faceCenters = zeros(nFaces,3);
for f = 1:nFaces
    faceCenters(f,:) = mean(surface.vertices(surface.faces(f,:),:),1);
end

% find points within the averaging radius of each surface face
iClosest = KDTreeBallQuery(faceCenters,faceCenters,radius);

% median filter the data
medianFiltered = zeros(nFaces,1);
for j = 1:numel(iClosest)
    medianFiltered(j,1) = median(measure(iClosest{j}));
end