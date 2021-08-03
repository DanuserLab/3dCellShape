function measures = makeMeasuresMatrixForPatchMerging(pairStats, inModel, pixelSize)

% makeMeasuresMatrixForPatchMerging - outputs a matrix of measures for machine learning of patch merging

% calculate conversion factors
curvatureConvert = -1000/pixelSize;

% make the measures matrix
measures = NaN(length(pairStats.meanCurvature), 36);
measures(:,1) = pairStats.meanCurvature*curvatureConvert; %
measures(:,2) = pairStats.meanGaussCurvature*curvatureConvert^2;
measures(:,3) = pairStats.meanCurvatureNormal*curvatureConvert;
measures(:,4) = pairStats.maxCurvature*curvatureConvert; %
measures(:,5) = pairStats.maxCurvatureNormal*curvatureConvert;
measures(:,6) = pairStats.stdCurvature*curvatureConvert;
measures(:,7) = pairStats.stdGaussCurvature*curvatureConvert^2;
measures(:,8) = pairStats.fractionHighCurvatureGlobal; %
measures(:,9) = pairStats.fractionLowCurvatureGlobal; %
measures(:,10) = pairStats.fractionHighCurvatureLocal;
measures(:,11) = pairStats.fractionLowCurvatureLocal;
measures(:,12) = pairStats.fractionHighGaussCurvatureGlobal; %
measures(:,13) = pairStats.fractionLowGaussCurvatureGlobal;%
measures(:,14) = pairStats.fractionHighGaussCurvatureLocal;
measures(:,15) = pairStats.fractionLowGaussCurvatureLocal; %
measures(:,16) = pairStats.fractionVeryHighCurvatureGlobal;
measures(:,17) = pairStats.fractionVeryLowCurvatureGlobal; %
measures(:,18) = pairStats.fractionTotalPerimeter; %
measures(:,19) = pairStats.meanCurvatureDif*curvatureConvert; %
measures(:,20) = pairStats.maxCurvatureDif*curvatureConvert;
measures(:,21) = pairStats.nonFlatCircularityDif; %
measures(:,22) = pairStats.volumeOverSurfaceAreaDif; %
measures(:,23) = pairStats.volumeOverClosureAreaDif; %
measures(:,24) = pairStats.meanCurvatureMean*curvatureConvert; %
measures(:,25) = pairStats.maxCurvatureMean*curvatureConvert; %
measures(:,26) = pairStats.nonFlatCircularityMean; %
measures(:,27) = pairStats.volumeOverSurfaceAreaMean; %
measures(:,28) = pairStats.volumeOverClosureAreaMean; %
measures(:,29) = pairStats.percentageRidgeLike; %
measures(:,30) = pairStats.percentageVeryRidgeLike; %
measures(:,31) = pairStats.percentageValleyLike; %
measures(:,32) = pairStats.percentageVeryValleyLike; %
measures(:,33) = pairStats.percentageDomed; 
measures(:,34) = pairStats.percentageCratered; %
measures(:,35) = pairStats.percentageFlat; 
measures(:,36) = pairStats.percentageSaddle; %

% find the measures to include
if ischar(inModel) && (strcmp(inModel, 'all') || strcmp(inModel, 'All'))
    inModel = ones(1,size(measures,2));
end

% select the picked features
selectedMeasures = [];
for m = 1:min([length(inModel), size(measures, 2)])
    if inModel(m) == 1
        selectedMeasures = [selectedMeasures, measures(:,m)];
    end
end
measures = selectedMeasures;
