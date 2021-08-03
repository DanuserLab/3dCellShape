function startProcess(MD, packageName, processName, parametersNew, reset)

% startProcess - initiates a process if needed and overrides default parameters
%
% INPUTS:
%
% MD - a MovieData object
% 
% packageName - the name of the MovieData package to which the process belongs
%
% processName - the name of the process to be run
%
% parametersNew - parameters that will override the default parameters.
%                 Should be either empty or a structure of the form 
%                 paramatersNew.(parameterName)
%
% reset - if 1 resets the process even if it is otherwise up to date


%% Check inputs
% check that MD is a MovieData object
assert(isa(MD,'MovieObject'),'Input is type %s, not a MovieObject.', class(MD));

% check that MD has the specified package
assert(ischar(packageName), 'Input should be the name of a package and hence a string not a %s', class(packageName)); 
assert(~isempty(MD.getPackageIndex(packageName)), '%s is not a package of this MovieData object.', packageName);

% check that parametersNew is a struct or is empty
assert(isempty(parametersNew) | isstruct(parametersNew), 'parametersNew should be either empty or a structure.')

% check the reset parameter
assert((reset==0 || reset==1), 'The reset parameter must be set to either 0 or 1.');


%% Initiate the process
% get the package index
iPack = MD.getPackageIndex(packageName);

% get the process index
iProc = MD.getPackage(iPack).getProcessIndexByName(processName);

% if the  process doesn't exist, create it
if ~MD.getPackage(iPack).hasProcessByName(processName)
    % add the process
    MD.getPackage(iPack).createDefaultProcess(iProc);
end
process = MD.getPackage(iPack).getProcess(iProc);


%% Set parameters
% find the default parameters for the Deconvolution process
parametersDefault = process.getDefaultParams(MD);

% replace old parameter values with any new parameter values
parameters = combineStructures(parametersDefault, parametersNew);

% check that the parameters are valid
% process.checkParameters(MD,parameters);

% set the parameters
process.setParameters(parameters);
% process.checkParameters(MD,parameters);

% interpret the channels parameter
% if isfield(parameters,'channels') && ischar(parameters.channels) && strcmp(parameters.channels, 'all')
%     parameters.chanList = 1:length(MD.channels_);
% elseif isfield(parameters,'channels')
%     parameters.chanList = parameters.channels;
% end
% if isfield(parameters,'channels')
%     parameters = rmfield(parameters, 'channels');
% end

% make an output directory for the process
if ~isfolder(parameters.OutputDirectory)
    mkdirRobust(parameters.OutputDirectory);
end


%% Run the process if needed
if process.success_ == 0 
    disp(' This process has not been successfully run')
    process.run(parameters);  
elseif process.procChanged_ == 1 
    disp(' This process has been changed since it was last run')
    process.run(parameters);
elseif process.updated_ == 0 
    disp(' This process has antecedent processes that have been changed')
    process.run(parameters);
elseif reset == 1
    disp(' This process is being reset')
    process.run(parameters);
else
    disp(' This process is up-to-date')
end
