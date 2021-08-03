function imageSphere = makeSphere3D(radius)

% makeSphere3D - makes a 3D image of a sphere with the image sized to just fit the sphere

[x,y,z] = ndgrid(-radius:radius,-radius:radius,-radius:radius);
imageSphere = ((x.*x+y.*y+z.*z)./radius^2) < 1; clear x y z;