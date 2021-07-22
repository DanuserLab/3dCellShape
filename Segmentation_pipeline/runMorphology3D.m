%% Set directories
imageDirectory = '/project/bioinformatics/Danuser_lab/zebrafish/analysis/Dagan/scripts/GitHub_3dCellShape/exampleCroppedCells/new_examples'; % directory the image is in. The images to be analyzed should be the only thing in the directory.
saveDirectory = '/project/bioinformatics/Danuser_lab/zebrafish/analysis/Dagan/scripts/GitHub_3dCellShape/exampleCroppedCells/new_examples/segmentation'; % directory for the analysis output


%% Set movie parameters
pixelSizeXY = 104; 
pixelSizeZ = 300;
timeInterval = 60; 


%% Turn processes on and off
p.control.resetMD = 0; 
p.control.deconvolution = 0;         p.control.deconvolutionReset = 0;
p.control.computeMIP = 1;            p.control.computeMIPReset = 0;
p.control.mesh = 1;                  p.control.meshReset = 0;
p.control.meshThres = 1;             p.control.meshThresReset = 0;
p.control.surfaceSegment = 0;        p.control.surfaceSegmentReset = 0;
p.control.patchDescribeForMerge = 0; p.control.patchDescribeForMergeReset = 0;
p.control.patchMerge = 0;            p.control.patchMergeReset = 0;
p.control.patchDescribe = 0;         p.control.patchDescribeReset = 0;
p.control.motifDetect = 0;           p.control.motifDetectReset = 0;
p.control.meshMotion = 0;            p.control.meshMotionReset = 0;
p.control.intensity = 0;             p.control.intensityReset = 0;
p.control.intensityBlebCompare = 0; p.control.intensityBlebCompareReset = 0;

cellSegChannel = 1; collagenChannel = 1; p = setChannels(p, cellSegChannel, collagenChannel);

%% Override Default Parameters
p.meshMode='otsu';  % or 'twoLevelSurface'
p.mesh.imageGamma = 0.7;
p.mesh.scaleOtsu=1;
p.mesh.useUndeconvolved = 1; %addition for no deconvolution
p.deconvolution.deconMode = 'richLucy';
p.deconvolution.richLucyIter = 10;

p.deconvolution.apoHeight = 0.05; %0.06, 0.0175
p.mesh.smoothMeshMode = 'none';
p.mesh.smoothImageSize = 3; %3 is very high value for smoothing

p.control.meshThres=0;
p.control.surfaceSegment=0;
p.control.patchDescribe=0;
p.control.patchDescribeForMerge=0;
p.control.patchMerge=0;
p.control.motifDetect=0;
p.control.meshMotion=0;
p.control.intensity=0;
p.control.intensityBlebCompare=0;
 
%% Analyze kras cells
imageList = [5, 11, 12, 13, 16, 42, 43, 46, 47, 55]; %change these numbers to the relevant cell number
parfor c = 1:length(imageList) % can be made a parfor loop if sufficient RAM is available.
    disp(['--------- Analysing Cell ' num2str(imageList(c))])
    
    % load the movie
    if ~isfolder(saveDirectory), mkdir(saveDirectory); end
    imagePathCell = fullfile(imageDirectory,['Cell' num2str(imageList(c))]);
    savePathCell = fullfile(saveDirectory, ['Cell' num2str(imageList(c))]);
    MD = makeMovieDataOneChannel(imagePathCell, savePathCell, pixelSizeXY, pixelSizeZ, timeInterval);

    % analyze the cell
    morphology3D(MD, p)
    plotMeshMD(savePathCell, 'surfaceMode', 'curvature', 'makeColladaDae', 1);
    %plotMeshMD(savePathCell, 'surfaceMode', 'curvature', 1);
    %plotMeshMD(savePath, 'surfaceMode', 'intensity', 'makeColladaDae', 1);
    %plotMeshMD(savePath, 'surfaceMode', 'curvature', 'makeMovie', 1);

    % save the image and imageSurface mask
    saveRawImageReshapedAsTif(MD, 1, fullfile(savePathCell, 'rawReshaped'));
   saveThresholdedImageAsTif(MD, 1, fullfile(savePathCell, 'thresholded')); 

end

