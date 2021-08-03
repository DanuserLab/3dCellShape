function defaultControl = defaultControlParamsMorphology3DPackage()

% defaultControlParamsMorphology3DPackage - set default control parameters for the Morphology3D package

% resetting the package
defaultControl.resetMD = 0;

% running the processes
defaultControl.photobleach = 1;
defaultControl.deconvolution = 1;
defaultControl.mesh = 1;
defaultControl.surfaceSegment = 1;
defaultControl.patchDescribeForMerge = 1;
defaultControl.patchMerge = 1;
defaultControl.patchDescribe = 1;
defaultControl.blebDetect = 1;
defaultControl.blebTrack = 1;
defaultControl.skeletonize = 1;
defaultControl.meshMotion = 1;
defaultControl.collagenDetect = 1;
defaultControl.collagenDescribe = 1;
defaultControl.intensity = 1;
defaultControl.intensityBlebCompare = 1;

% resetting the processes
defaultControl.photobleachReset = 0;
defaultControl.deconvolutionReset = 0;
defaultControl.meshReset = 0;
defaultControl.surfaceSegmentReset = 0;
defaultControl.patchDescribeForMergeReset = 1;
defaultControl.patchMergeReset = 1;
defaultControl.patchDescribeReset = 0;
defaultControl.blebDetectReset = 0;
defaultControl.blebTrackReset = 0;
defaultControl.skeletonizeReset = 1;
defaultControl.meshMotionReset = 0;
defaultControl.collagenDetectReset = 0;
defaultControl.collagenDescribeReset = 0;
defaultControl.intensityReset = 0;
defaultControl.intensityBlebCompareReset = 0;
