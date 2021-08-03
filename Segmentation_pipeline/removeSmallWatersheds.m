function watersheds = removeSmallWatersheds(minSize, watersheds)

% removeSmallWatersheds - remove small watersheds (minSize is measured in faces)

% find a list of watersheds regions
regions = unique(watersheds);
regions = regions(regions>0);

% remove small regions
for r = regions'
    
    % find the number of faces in the region
    numFacesRegion = sum(watersheds==r);
    
    % if the number of faces is below minSize, remove it
    if numFacesRegion < minSize
        watersheds(watersheds==r) = 0;
    end
    
end