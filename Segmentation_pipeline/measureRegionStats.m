function regionStats = measureRegionStats(surface, positions, watersheds, neighbors, meanCurvature, gaussCurvature, faceNormals, areas)

% measureRegionStats - measure simple statistics about blebs such as bleb count, bleb surface area, and min curvature

% find a list of watershed regions
regions = unique(watersheds);
regions = regions(regions>0);

% save the watershed indices
regionStats.index = regions;

% find the number of blebs
regionStats.count = length(regions);
    
% determine which faces are on the boundary between segments
onBoundary = findBoundaryFaces(watersheds, neighbors, 'single');

% initialize variables
regionStats.numFaces = zeros(regionStats.count,1);
regionStats.surfaceArea = zeros(regionStats.count,1);
regionStats.closureSurfaceArea = zeros(regionStats.count,1);
regionStats.minCurvature = zeros(regionStats.count,1);
regionStats.minCurvatureFaceIndex = zeros(regionStats.count,1);
regionStats.meanCurvature = zeros(regionStats.count,1);
regionStats.stdCurvature = zeros(regionStats.count,1);
regionStats.meanGaussCurvature = zeros(regionStats.count,1);
regionStats.closeCenter = zeros(regionStats.count,3);
regionStats.volume = zeros(regionStats.count,1);
regionStats.perimeter = zeros(regionStats.count,1);
regionStats.radius = zeros(regionStats.count,1);
regionStats.nonFlatCircularity = zeros(regionStats.count,1);
regionStats.variationFromSphere = zeros(regionStats.count,1);
regionStats.weightedMeanPosition = zeros(regionStats.count,3);
regionStats.unWeightedMeanPosition = zeros(regionStats.count,3);
regionStats.meanCurvatureOnEdge = zeros(regionStats.count,1);
regionStats.closureRadius = zeros(regionStats.count,1);
regionStats.sdf = zeros(regionStats.count,1);

% iterate through the blebs and calculate statistics
for r = 1:length(regions)
    
    % find the number of faces in each bleb
    regionStats.numFaces(r,1) = sum(watersheds==regions(r));
    
    % find the surface area of each bleb
    regionStats.surfaceArea(r,1) = sum(areas(watersheds==regions(r)));
    
    % find the distribution of the various measure statistics
    curvatureValues = meanCurvature(watersheds==regions(r));
    gaussCurvatureValues = gaussCurvature(watersheds==regions(r));
    [regionStats.minCurvature(r,1), minIndex] = min(curvatureValues);
    regionStats.meanCurvature(r,1) = mean(curvatureValues);
    regionStats.stdCurvature(r,1) = std(curvatureValues);
    regionStats.meanGaussCurvature(r,1) = std(gaussCurvatureValues);
    
    % find the position of the minimum value
    faceIndex = 1:length(watersheds);
    facesInRegion = faceIndex(watersheds==regions(r));
    regionStats.minCurvatureFaceIndex(r,1) = facesInRegion(minIndex);
    
    % close the mesh representing the region to measure its volume
    [regionStats.closeCenter(r,:), regionStats.closureSurfaceArea(r), closedMesh, regionStats.closureRadius(r)] = closeMesh(regions(r), surface, watersheds, neighbors);
    
    % measure the region's volume
    regionStats.volume(r,1) = measureMeshVolume(closedMesh);
    
    % measure the region's perimeter
    regionStats.perimeter(r,1) = measureRegionPerimeter(surface, watersheds, neighbors, onBoundary, regions(r));
    
    % measure the bleb radius
    positionsRegion = [positions(watersheds==regions(r),1), positions(watersheds==regions(r),2), positions(watersheds==regions(r),3)];
    regionStats.radius(r,1) = mean(sqrt(sum((positionsRegion - repmat(regionStats.closeCenter(r,:), size(positionsRegion,1), 1)).^2, 2)));
    
    % find the average value of the measure along the edge
    regionStats.meanCurvatureOnEdge(r,1) = nanmean(meanCurvature((watersheds==regions(r)) & onBoundary));
    
    % measure the bleb circularity
    regionStats.nonFlatCircularity(r,1) = regionStats.surfaceArea(r,1)/(regionStats.perimeter(r,1)^2);
    
    % measure the bleb position (weighted by measure, and only including faces whose measure is above zero)
    curvatureValues(curvatureValues>0) = 0; % set measure values less than 0 to 0
    regionStats.weightedMeanPosition(r,:) = sum(positionsRegion.*repmat(curvatureValues, [1,3]),1)./sum(curvatureValues);
    regionStats.unWeightedMeanPosition(r,:) = mean(positionsRegion, 1);
    if sum(curvatureValues) == 0 % if there are no curvatureValues to weight by, don't weight the position
       regionStats.weightedMeanPosition(r,:) = regionStats.unWeightedMeanPosition(r,:);
    end
    
    % measure the shape diameter function
    raysPerCompare = 20;
    regionStats.sdf(r) = calculateShapeDiameterFunctionRegion(surface, positions, faceNormals, watersheds, regions(r), raysPerCompare);
    
end

% measure the bleb sphericity (this function is a bit redundant)
[regionStats.variationFromSphere, ~] = measureSpherelike(positions, watersheds, regions, meanCurvature);
regionStats.variationFromSphere = regionStats.variationFromSphere';
