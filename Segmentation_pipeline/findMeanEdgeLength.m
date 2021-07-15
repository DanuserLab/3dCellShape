function meanEdgeLength = findMeanEdgeLength(surface)

% meanEdgeLength finds the edge length, in pixels, of a mesh given a surface (the output of the patch command)


% find the mean length of each face's edges
edgeLengthFaces = nan(size(surface.faces,1),1);
for v = 1:size(surface.faces,1)
    
    lengthEdge1 = sqrt(sum((surface.vertices(surface.faces(v,1),:) - surface.vertices(surface.faces(v,2),:)).^2,2));
    lengthEdge2 = sqrt(sum((surface.vertices(surface.faces(v,2),:) - surface.vertices(surface.faces(v,3),:)).^2,2));
    lengthEdge3 = sqrt(sum((surface.vertices(surface.faces(v,3),:) - surface.vertices(surface.faces(v,1),:)).^2,2));
    
    edgeLengthFaces(v) = mean([lengthEdge1 lengthEdge2 lengthEdge3]);
    
end

% find the mean edge length
meanEdgeLength = mean(edgeLengthFaces);
