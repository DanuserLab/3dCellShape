function dnImage = depthNormalize(image3D, image3DMask)

% depthNormalize - normalizes each pixel by the mean intensity at that distance from the mesh

% (this is adapted from Hunter Elliott's code)

% calculate the distance from the mask edge
distImage = bwdist(~image3DMask);

% get all distance values
distVals = unique(distImage);
distVals(distVals==0) = [];

% initialize a depth normalized image
dnImage = zeros(size(image3D));

% normalize each possible distance from the edge by the average value at that distance
for d = 1:numel(distVals)
   
    % find all the pixels at the distance d
    pixelsAtDist = (distImage==distVals(d));
    
    % normalize those pixels
    dnImage(pixelsAtDist) = image3D(pixelsAtDist)./mean(image3D(pixelsAtDist(:)));
    %dnImage = dnImage + pixelsAtDist.*image3D./mean(image3D(pixelsAtDist));
end
