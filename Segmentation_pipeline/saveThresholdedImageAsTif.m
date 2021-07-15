function saveThresholdedImageAsTif(processOrMovieData, channel, savePath, varargin)

% saveSurfaceImageAsTif - just what it sounds like
ip = inputParser;
ip.CaseSensitive = false;
ip.addRequired('processOrMovieData', @(x) isa(x,'Process') && isa(x.getOwner(),'MovieData') || isa(x,'MovieData') || ischar(x));
ip.addRequired('channel', @isnumeric);
ip.addRequired('savePath', @ischar);
ip.parse(processOrMovieData, channel, savePath, varargin{:});
p = ip.Results;

% try to load the MovieData object
if isa(processOrMovieData, 'MovieData') || isa(x,'Process') 
    [MD, meshProc] = getOwnerAndProcess(processOrMovieData,'Mesh3DProcess',true);
else
    try 
        files = dir(fullfile(processOrMovieData, '*.mat'));
        if length(files) == 1
            load(fullfile(processOrMovieData, files(1).name));
            [MD, meshProc] = getOwnerAndProcess(processOrMovieData,'Mesh3DProcess',true);
        else
            disp(['The following directory contains multiple Matlab variables: ' processOrMovieData]);
        end
    catch
        disp(['The following directory does not contain a Matlab variable: ' processOrMovieData]);
    end
end

% check that provided channel is a valid channel index 
assert(channel>0 & channel<=(length(MD.channels_)), 'channel must be an index of one a MovieData channel')

% find the directory where the surface images are stored
surfacePathIntensity = meshProc.outFilePaths_{4,1};
surfacePath = meshProc.outFilePaths_{1,channel};

% load the Otsu thresholds
levels = load(fullfile(surfacePathIntensity, 'intensityLevels.mat'));

% make a directory to save images in
if ~isdir(savePath), system(['mkdir -p ' savePath]); end

% iterate through the frames
for t = 1:MD.nFrames_   
        
        % load the surface image
        si = load(fullfile(surfacePath, ['imageSurface_' num2str(channel) '_' num2str(t) '.mat']));
        surfaceImage = si.imageSurface;
        
        % make the thresholded image
        thresholdedImage = surfaceImage > levels.intensityLevels(channel,t);
        thresholdedImage = uint16((2^16-1)*thresholdedImage);
        
        % save the surface image
        imagePath = fullfile(savePath, ['threshold' num2str(t) '.tif']);
        save3DImage(thresholdedImage, imagePath);
    
end
