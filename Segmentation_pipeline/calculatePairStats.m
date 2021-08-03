function pairStats = calculatePairStats(patchPairs, surface, surfaceSegment, neighbors, meanCurvature, meanCurvatureUnsmoothed, gaussCurvature)

% calculatePairStats - for the list of adjacent patch pairs provided, calculates various statistics

% find the boundary faces
onBoundary = findBoundaryFaces(surfaceSegment, neighbors, 'single');

% measure the area of each face
areas = measureAllFaceAreas(surface); 

% calculate the principal curvatures
kappa1 = real(-1*meanCurvatureUnsmoothed + sqrt(meanCurvatureUnsmoothed.^2-gaussCurvature));
kappa2 = real(-1*meanCurvatureUnsmoothed - sqrt(meanCurvatureUnsmoothed.^2-gaussCurvature));

% calculate curvature statistics
curvatureStats.meanCurvature = mean(meanCurvature);
curvatureStats.stdCurvature = std(meanCurvature);
curvatureStats.curvature20 = prctile(meanCurvature,20);
curvatureStats.curvature80 = prctile(meanCurvature,80);
curvatureStats.gaussCurvature20 = prctile(gaussCurvature,20);
curvatureStats.gaussCurvature80 = prctile(gaussCurvature,80);
curvatureStats.curvature10 = prctile(meanCurvature,10);
curvatureStats.curvature90 = prctile(meanCurvature,90);

% remove 0s from measures to prevent division by zero
%segmentStats.surfaceArea(segmentStats.surfaceArea == 0) = 1;
%segmentStats.closureSurfaceArea(segmentStats.closureSurfaceArea == 0) = 1;

% save the list of patch pairs
pairStats.patchPairs = patchPairs;

% iterate through the patch pairs
for p = 1:size(patchPairs,1)
    
    % calculate the stats for an indivdual pair
    statsOnePair = calculatePairStatsOnePair(patchPairs(p,1), patchPairs(p,2), surface, surfaceSegment, neighbors, onBoundary, areas, meanCurvature, gaussCurvature, kappa1, kappa2, curvatureStats);
    
    % unpack the statistics
    pairStats = unpackStatisticsPairStats(statsOnePair, pairStats, p);
    
end
