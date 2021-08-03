function [surface, image3D, level] = meshOtsu(image3D, scaleOtsu)

% meshOtsu - creates an isosurface by Otsu thresholding

% prepareCellOtsuSeg - calculates an Otsu threshold and prepares the image for thresholding
[image3D, level] = prepareCellOtsuSeg(image3D);

% scale the Otsu threshold
level = scaleOtsu*level;

% remove disconnected components that might make the mesh irregular 
image3D = removeDisconectedComponents(image3D, level);
%image3D = removeSmallDisconectedComponents(image3D, 150, level);

% add a black border to the image in case the cell touches the border
image3D = addBlackBorder(image3D, 1);

% create a mesh
surface = isosurface(image3D, level);