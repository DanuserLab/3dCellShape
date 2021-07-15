function saveRawImageReshapedAsTif(MD, channel, savePath, varargin)

% saveRawImageReshapedAsTif - just what it sounds like
ip = inputParser;
ip.CaseSensitive = false;
ip.addRequired('MD', @(x) isa(x,'MovieData') || @(x) ischar(x));
ip.addRequired('channel', @isnumeric);
ip.addRequired('savePath', @ischar);
ip.parse(MD, channel, savePath, varargin{:});
p = ip.Results;

% try to load the MovieData object
if isa(MD, 'MovieData')
    MD = MD;
else
    try 
        files = dir(fullfile(MD, '*.mat'));
        if length(files) == 1
            load(fullfile(MD, files(1).name));
        else
            disp(['The following directory contains multiple Matlab variables: ' MD]);
        end
    catch
        disp(['The following directory does not contain a Matlab variable: ' MD]);
    end
end

% check that provided channel is a valid channel index 
assert(channel>0 & channel<=(length(MD.channels_)), 'channel must be an index of one a MovieData channel')

% make a directory to save images is
if ~isdir(savePath), system(['mkdir -p ' savePath]); end

% iterate through the frames
for t = 1:MD.nFrames_   
    
        % load the image
        image3D = im2double(MD.getChannel(channel).loadStack(t));
        
        % reshape the image
        image3D = make3DImageVoxelsSymmetric(image3D, MD.pixelSize_, MD.pixelSizeZ_);
        
        % prepare to save the image
        image3D = addBlackBorder(image3D,1);
        image3D = uint16((2^16-1)*image3D);
        
        % save the image
        imagePath = fullfile(savePath, ['rawReshaped' num2str(t, '%05d') '.tif']);
        save3DImage(image3D, imagePath);
    
end
