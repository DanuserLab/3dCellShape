function [label, score] = predictFromBlebClicks(clickedOnBlebs, clickedOnNotBlebs, patchList)

% predictFromBlebClicks generates a label and an SVM like score list from the list of clicked on patches

% convert clickedOnBlebs to patchList indices
blebsPatchIndex = nan(1,length(clickedOnBlebs));
for b = 1:length(clickedOnBlebs)
    blebsPatchIndex(b) = find(patchList == clickedOnBlebs(b));
end

% convert clickedOnNotBlebs to patchList indices
notBlebsPatchIndex = nan(1,length(clickedOnNotBlebs));
for b = 1:length(clickedOnNotBlebs)
    notBlebsPatchIndex(b) = find(patchList == clickedOnNotBlebs(b));
end

% generate outputs for the 'certain' clicking mode
if ~isempty(clickedOnBlebs) && ~isempty(clickedOnNotBlebs)
    score = zeros(1,length(patchList));
    score(blebsPatchIndex) = score(blebsPatchIndex) + 1;
    score(notBlebsPatchIndex) = score(notBlebsPatchIndex) - 1;
    label = ceil(score/2);
    
% generate outputs for the 'notBleb' clicking mode   
elseif ~isempty(clickedOnNotBlebs)
    score = ones(1,length(patchList));
    score(notBlebsPatchIndex) = score(notBlebsPatchIndex) - 1;
    label = score;

% generate outputs for the 'bleb' clicking mode   
else 
    score = zeros(1,length(patchList));
    score(blebsPatchIndex) = score(blebsPatchIndex) + 1;
    label = score;
end