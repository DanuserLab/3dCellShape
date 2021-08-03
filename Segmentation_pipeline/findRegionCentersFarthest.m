function regionCenters = findRegionCentersFarthest(neighbors, watersheds, measure)

% findWatershedCentersFarthest - finds the face within each watershed that is farthest from the patch edge


% for each face, find the distance to a region boundary
boundaryDist = findDistToRegionEdge(watersheds, neighbors);

% finds a list of the region labels
regions = unique(watersheds);
regions = regions(regions>0);

% iterate through the regions
regionCenters = zeros(length(regions),2);
for w = 1:length(regions)
    
    % find the watershed label
    label = regions(w);
    
    % append the global watershed label to the matrix
    regionCenters(w,2) = label;
    
    % find the maximum distance in the region
    maxDist = max(boundaryDist.*(watersheds==label));
    
    % if there is more than one face at a maximum distance from the edge, chose the face with the lowest value of the measure
    maxDistsInRegion = logical((boundaryDist==maxDist).*(watersheds==label));
    [~, regionCenters(w,1)] = min(measure.*maxDistsInRegion);
    
end
