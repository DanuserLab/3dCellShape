function triangleMeasure = calculateTriangleMeasurePair(mesh, watersheds, watershedLabels, neighbors, closureSurfaceArea, firstRegionIndex, secondRegionIndex, patchLength, meshLength)

% check to make sure that the patchLength isn't too large
if patchLength > 0.25*meshLength
    triangleMeasure = 0;
    return
end

% find the graph labels of the first two watersheds on the list
labelIndex = 1:length(watershedLabels);
gLabel1 = labelIndex(watershedLabels == firstRegionIndex);
gLabel2 = labelIndex(watershedLabels == secondRegionIndex);  

% make a list of watershed regions in which the two regions are merged 
watershedsCombined = watersheds;
mergeLabel = min([firstRegionIndex secondRegionIndex]);
if mergeLabel < 0, mergeLabel = max([firstRegionIndex secondRegionIndex]); end 
if mergeLabel == firstRegionIndex
    watershedsCombined(watersheds == secondRegionIndex) = mergeLabel;
else
    watershedsCombined(watersheds == firstRegionIndex) = mergeLabel;
end

% find the closure surface area of the combined region
[~, closureSurfaceAreaCombinedRegion, ~] = closeMesh(mergeLabel, mesh, watershedsCombined, neighbors);

% calculate the value of the triangle measure (inspired by the law of cosines)
triangleMeasure = (closureSurfaceArea(gLabel1)+closureSurfaceArea(gLabel2)-closureSurfaceAreaCombinedRegion)/(sqrt(closureSurfaceArea(gLabel1)*closureSurfaceArea(gLabel2)));
