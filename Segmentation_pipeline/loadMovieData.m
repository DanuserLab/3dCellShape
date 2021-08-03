function MD = loadMovieData(imagePath, outputDirectory, varargin)

% load MovieData - initiates a movieData object if there is not one associated with the imagePath at the outputDirectory

% INPUTS:
%
% imagePath - the path and name of a movie, or for multi-tiff movies the
%           path and name of one of those tiffs
%
% outputDirectory - the directory where all output data will be saved
%
% reset - (optional) 1 to reset MovieData, 0 to not reset it


% check inputs
ip = inputParser;
addRequired(ip, 'imagePath', @ischar);
addRequired(ip, 'outputDirectory', @ischar);
addParameter(ip, 'reset', 0, @(x) (x==0 || x==1));
ip.parse(imagePath, outputDirectory, varargin{:});
p = ip.Results;

% look for a MovieData object with the same name as the provided image name or with the name movieData
[~,nameStr,~] = fileparts(p.imagePath);
nameMD = [p.outputDirectory filesep nameStr '.mat'];
infoMD = dir(nameMD);
defaultMD = dir(fullfile(p.outputDirectory,'movieData.mat'));

% if there's not a MovieData object then make one
if isempty(infoMD) && isempty(defaultMD) 
    disp('Making a new MovieData object')
    MD = MovieData(p.imagePath, 'outputDirectory', p.outputDirectory);
else % otherwise load the old movie data
    disp('Loading an existing MovieData object')
    if ~isempty(infoMD)
        load(nameMD);
    else
        load(fullfile(p.outputDirectory,'movieData.mat'))
    end
    
    if p.reset == 1 % reset if wanted
        MD.reset();
        disp('Reseting MovieData')
    else % check the MovieData object
        sanityCheck(MD);
    end
end