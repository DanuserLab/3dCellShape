function [meanVM, concVM] = estimateVonMisesFisherParametersWeighted(unitVectors, measure, dim)

% estimateVonMisesFisherParametersWeighted - for a set of unit vectors, estimate the the weighted von Mises Fisher parameters in the given dimensions

% This is a different function from estimateVonMisesFisherParameters since
% it's not clear how to properly weight the distribution. Note that only
% the mean is weighted!
%
% Note that this estimate is only good in a small dimensional space (2, 3, etc.)
% See "A short note on parameter approximation for von-Mises-Fisher distributions"

% calculate the maximum likelihood estimate of the mean direction
meanNonNormal = sum(repmat(measure,1,3).*unitVectors, 1);
normalization = sqrt(sum(meanNonNormal.^2));
meanVM = meanNonNormal./normalization;

% calculate an approximation of the maximum likelihood estimate of the concentration parameter
rHat = normalization./size(unitVectors,1);
kappa = (rHat*(dim-rHat^2))/(1-rHat^2); % an estimate
AofKappa = besseli(dim/2, kappa)/besseli(dim/2-1, kappa);
kappa_1 = kappa - (AofKappa - rHat)/(1-AofKappa^2-((dim-1)/kappa)*AofKappa); % a better estimate
AofKappa_1 = besseli(dim/2, kappa_1)/besseli(dim/2-1, kappa_1);
kappa_2 = kappa_1 - (AofKappa_1 - rHat)/(1-AofKappa_1^2-((dim-1)/kappa_1)*AofKappa_1); % a yet better estimate
concVM = kappa_2;
