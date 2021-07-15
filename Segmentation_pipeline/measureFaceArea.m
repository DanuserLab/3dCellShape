function area = measureFaceArea(f,mesh)

% measureFaceArea - measure the area of a single face

% find the three vertices that compose the face
vertices = mesh.faces(f,:);

% find two vectors that describe the face
vector1 = mesh.vertices(vertices(1),:) - mesh.vertices(vertices(2),:);
vector2 = mesh.vertices(vertices(1),:) - mesh.vertices(vertices(3),:);

% measure the area of each face
area = sqrt(sum(crossProduct(vector1,vector2).^2))/2;


% a faster cross product
function z = crossProduct(x,y)
z = x;
z(:,1) = x(:,2).*y(:,3) - x(:,3).*y(:,2);
z(:,2) = x(:,3).*y(:,1) - x(:,1).*y(:,3);
z(:,3) = x(:,1).*y(:,2) - x(:,2).*y(:,1);
