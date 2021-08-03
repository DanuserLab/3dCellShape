function [faceIsFlat, faceIsMin, flowOut, flowIn] = assignGradientAtNodes(neighbors, measure)

% assignGradientAtNodes - Find the the gradient direction of the measure at every node


% initialize outputs
faceIsFlat = zeros(length(neighbors), 1);
faceIsMin = zeros(length(neighbors), 1);
flowOut = NaN(length(neighbors), 1);
flowIn = cell(length(neighbors), 1);
% maxFlowDif = zeros(length(neighbors), 1);

for f = 1:size(neighbors,1) % iterate through the faces
    
    % find the difference in the measure between neighbors (this is unnecessarily calculated twice for each pair of neighbors)
    measureDif(1) = measure(neighbors(f,1))-measure(f);
    measureDif(2) = measure(neighbors(f,2))-measure(f);
    measureDif(3) = measure(neighbors(f,3))-measure(f);
    
    % check if the region is flat
    if ~measureDif
        faceIsFlat(f) = true;
    
    % check if the region is a minimum (this isn't really correct)
    elseif (measureDif > 0) 
        faceIsMin(f) = true;
    
    % the region is sloped so assign gradient directions    
    else
        [~, minNeighbor] = min(measureDif);
        flowOut(f) = neighbors(f,minNeighbor);
        flowIn{flowOut(f)} = [flowIn{flowOut(f)}, f];
    end
    
    % % find the largest difference in measures
    % maxFlowDif(f) = max(measureDif)-min(measureDif);

end