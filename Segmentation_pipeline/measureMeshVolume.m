function volume = measureMeshVolume(mesh)

% measureMeshVolume - measure the volume of a closed mesh (where the mesh is assumed to be represented by an fv struct)
%
% The volume formula is partially from 
% Cha Zhang and Tsuhan Chen. "Efficient Feature Extraction for 2D/3D
% Objects in Mesh Representation" (2001).

% find the signed volume of each face in the mesh
volumeTetras = zeros(size(mesh.faces,1),1);
for f = 1:size(mesh.faces,1)
    
    % find the vertices that form the face
    vertex1 = mesh.vertices(mesh.faces(f,1),:);
    vertex2 = mesh.vertices(mesh.faces(f,2),:);
    vertex3 = mesh.vertices(mesh.faces(f,3),:);
    
    volumeTetras(f) = dot(vertex1, crossProduct(vertex2,vertex3))/6;
end

volume = abs(sum(volumeTetras));


% a faster cross product
function z = crossProduct(x,y)
z = x;
z(:,1) = x(:,2).*y(:,3) - x(:,3).*y(:,2);
z(:,2) = x(:,3).*y(:,1) - x(:,1).*y(:,3);
z(:,3) = x(:,1).*y(:,2) - x(:,2).*y(:,1);