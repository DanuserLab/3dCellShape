function [meanDiscreteVM, concDiscreteVM] = measureVonMisesDiscrete(allFaceVectors, downSample, sampleOffset, measure, discreteLevel)

% measureVonMisesDiscrete - calculate the von Mises-Fisher parameters, discretized, for a measure

% discretize the measure
measure = measure - min(measure(:));
measure = discreteLevel*measure./max(measure(:));
measure = ceil(measure);
measure(measure<1) = 1;

% for each measure value, append data to the list of unit vectors
unitVectors = [];
for n = sampleOffset:downSample:length(measure) 
    unitVectors = [unitVectors; repmat([allFaceVectors(n,:)], [measure(n), 1])]; 
end

% find the von Mises-Fisher parameters
[meanDiscreteVM, concDiscreteVM] = estimateVonMisesFisherParameters(unitVectors, 3);