function [blebStats, cellStats] = surface2blebStatistics(stats, cellStats, blebSegment, surfaceSegment)

% surface2blebStatistics - converts the patch statistics structure to a structure specific only to blebs

% find lists of the surface patches and blebs
patchIndices = unique(surfaceSegment);
patchIndices = patchIndices(patchIndices > 0);
blebIndices = unique(blebSegment);
blebIndices = blebIndices(blebIndices > 0);

% initialize a blebStats variable
blebStats = stats;

% update the bleb count
cellStats.blebCount = length(blebIndices);
blebStats.count = length(blebIndices);

% make a mask of patches to keep
keepMask = ismember(patchIndices, blebIndices);

% find a list of fields of stats
names = fieldnames(stats);

% update the fields one by one
for f = 1:size(names,1)
    
    % find the value of the field
    % (yes, evals are annoying)
    field = eval(['stats.' names{f,1}]);
    
    % if the field has the wrong size, keep going
    if size(field,1) ~= length(patchIndices)
        continue;
    end
    
    % set the value of the field in blebStats
    % (another eval)
    blebField = field;
    blebField(keepMask == 0,:) = [];
    eval(['blebStats.' names{f,1} ' = blebField;']);

end
