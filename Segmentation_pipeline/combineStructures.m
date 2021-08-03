function structCombined = combineStructures(oldStruct, newStruct)

% combineStructures - combines the fields of two structures, using newStruct to define any overlapping fields

% check inputs
assert(isempty(oldStruct) || isstruct(oldStruct), 'the oldStruct parameter must be empty or a structure')
assert(isempty(newStruct) || isstruct(newStruct), 'the newStruct parameter must be empty or a structure')

% combine the structure
if isempty(newStruct) % if the new structure is empty provide the old structure
    structCombined = oldStruct;
elseif isempty(oldStruct) % if the old structure is empty provide the new structure
    structCombined = newStruct;
else % combine fields
    oldStruct = rmfield(oldStruct, intersect(fieldnames(oldStruct), fieldnames(newStruct)));
    names = [fieldnames(oldStruct); fieldnames(newStruct)];
    structCombined = cell2struct([struct2cell(oldStruct); struct2cell(newStruct)], names, 1);
end
