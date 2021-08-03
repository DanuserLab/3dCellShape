function pairStats = unpackStatisticsPairStats(statsOnePair, pairStats, p)

% unpackStatisticsPairStats - assigns statsOnePair to be the pth element of every statistic in pairStats (very specific to calculatePairStats.m)

pairStats.meanCurvature(p) = statsOnePair.meanCurvature;
pairStats.meanGaussCurvature(p) = statsOnePair.meanGaussCurvature;
pairStats.meanCurvatureNormal(p) = statsOnePair.meanCurvatureNormal;
pairStats.maxCurvature(p) = statsOnePair.maxCurvature;
pairStats.maxCurvatureNormal(p) = statsOnePair.maxCurvatureNormal;
pairStats.stdCurvature(p) = statsOnePair.stdCurvature;
pairStats.stdGaussCurvature(p) = statsOnePair.stdGaussCurvature;

pairStats.fractionHighCurvatureGlobal(p) = statsOnePair.fractionHighCurvatureGlobal;
pairStats.fractionLowCurvatureGlobal(p) = statsOnePair.fractionLowCurvatureGlobal;
pairStats.fractionHighCurvatureLocal(p) = statsOnePair.fractionHighCurvatureLocal;
pairStats.fractionLowCurvatureLocal(p) = statsOnePair.fractionLowCurvatureLocal;
pairStats.fractionHighGaussCurvatureGlobal(p) = statsOnePair.fractionHighGaussCurvatureGlobal;
pairStats.fractionLowGaussCurvatureGlobal(p) = statsOnePair.fractionLowGaussCurvatureGlobal;
pairStats.fractionHighGaussCurvatureLocal(p) = statsOnePair.fractionHighGaussCurvatureLocal;
pairStats.fractionLowGaussCurvatureLocal(p) = statsOnePair.fractionLowGaussCurvatureLocal;
pairStats.fractionVeryHighCurvatureGlobal(p) = statsOnePair.fractionVeryHighCurvatureGlobal;
pairStats.fractionVeryLowCurvatureGlobal(p) = statsOnePair.fractionVeryLowCurvatureGlobal;

pairStats.fractionTotalPerimeter(p) = statsOnePair.fractionTotalPerimeter;

pairStats.meanCurvatureDif(p) = statsOnePair.meanCurvatureDif;
pairStats.maxCurvatureDif(p) = statsOnePair.maxCurvatureDif;
pairStats.nonFlatCircularityDif(p) = statsOnePair.nonFlatCircularityDif;
pairStats.volumeOverSurfaceAreaDif(p) = statsOnePair.volumeOverSurfaceAreaDif;
pairStats.volumeOverClosureAreaDif(p) = statsOnePair.volumeOverClosureAreaDif;

pairStats.meanCurvatureMean(p) = statsOnePair.meanCurvatureMean;
pairStats.maxCurvatureMean(p) = statsOnePair.maxCurvatureMean;
pairStats.nonFlatCircularityMean(p) = statsOnePair.nonFlatCircularityMean;
pairStats.volumeOverSurfaceAreaMean(p) = statsOnePair.volumeOverSurfaceAreaMean;
pairStats.volumeOverClosureAreaMean(p) = statsOnePair.volumeOverClosureAreaMean;

pairStats.percentageRidgeLike(p) = statsOnePair.percentageRidgeLike;
pairStats.percentageVeryRidgeLike(p) = statsOnePair.percentageVeryRidgeLike;
pairStats.percentageValleyLike(p) = statsOnePair.percentageValleyLike;
pairStats.percentageVeryValleyLike(p) = statsOnePair.percentageVeryValleyLike;
pairStats.percentageDomed(p) = statsOnePair.percentageDomed;
pairStats.percentageCratered(p) = statsOnePair.percentageCratered;
pairStats.percentageFlat(p) = statsOnePair.percentageFlat;
pairStats.percentageSaddle(p) = statsOnePair.percentageSaddle;
