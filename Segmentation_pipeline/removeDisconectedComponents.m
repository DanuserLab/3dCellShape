function image3D = removeDisconectedComponents(image3D, level)

% removeDisconnectedComponents - zeros all but the largest connected component in a 3D image that is above the provided threshold

% threshold the image
imageThreshold = (image3D > level);

% find the number of pixels in each of the connected components
CC = bwconncomp(imageThreshold);
numPixels = cellfun(@numel,CC.PixelIdxList);

% find the label of the largest connected component
[~,label] = max(numPixels);

% zero all of the other connected components
for c = 1:length(numPixels)
    if c ~= label
        image3D(CC.PixelIdxList{c}) = 0;
    end
end

