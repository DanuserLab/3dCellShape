function areas = measureAllFaceAreas(mesh)

% measureAllFaceAreas - finds the area of all faces

% iterate through the faces
numFaces = size(mesh.faces,1);
areas = zeros(1,numFaces);
for f = 1:numFaces
    areas(f) = measureFaceArea(f,mesh); 
end
