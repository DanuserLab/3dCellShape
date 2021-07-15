function parsave(fileName,varargin)

% parsave - saves workspace variables even inside a parfor loop
% (modified from a Mathworks blog)

% INPUTS:
%
% filename - the path and name of the file to be saved
%
% (variables) - include the variables to be saved as subsequent inputs


% check that the first input is a string
assert(ischar(fileName), 'fileName must be a string');

% put all the variables that will be saved in one structure
for n = 2:nargin
    savevar.(inputname(n)) = varargin{n-1};
end

% save the variables
save(fileName, '-struct', 'savevar','-v7.3')