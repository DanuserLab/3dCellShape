function vertices2faces = makeVertices2Faces(surface)

% makeVertices2Faces - Construct a list of vertices with the indices of the faces that intersect at each vertex


vertices2faces = cell(length(surface.vertices), 1);
for f = 1:size(surface.faces,1)
    vertices2faces{surface.faces(f,1)} = [vertices2faces{surface.faces(f,1)},f];
    vertices2faces{surface.faces(f,2)} = [vertices2faces{surface.faces(f,2)},f];
    vertices2faces{surface.faces(f,3)} = [vertices2faces{surface.faces(f,3)},f];
end
