function image3DLarge = addBlackBorder(image3D, width)

% addBlackBorder - adds a black border of specified width to a 3D image
 
% find the image size
imageSize = size(image3D);

% initialize a slightly larger black image
image3DLarge = median(image3D(:))+zeros(imageSize(1)+2*width, imageSize(2)+2*width, imageSize(3)+2*width);

% set image3D to be the center of the black image
image3DLarge(width+1:end-width, width+1:end-width, width+1:end-width) = image3D;
