function p = setChannels(p, cellSegChannel, collagenChannel)

% setChannels - a helper function to more quickly set channels for Morphology3D

p.photobleach.channels = cellSegChannel;
p.deconvolution.channels = cellSegChannel;
p.mesh.channels = cellSegChannel;
p.surfaceSegment.channels = cellSegChannel;
p.patchDescribeForMerge.channels = cellSegChannel;
p.patchMerge.channels = cellSegChannel;
p.patchDescribe.channels = cellSegChannel;
p.blebDetect.channels = cellSegChannel;
p.blebTrack.channels = cellSegChannel;
p.motifDetect.channels = cellSegChannel;
p.meshMotion.channels = cellSegChannel;
p.collagenDetect.channels = collagenChannel;
p.collagenDescribe.channels = collagenChannel;
p.collagenDescribe.cellChannel = cellSegChannel;
p.intensity.channels = cellSegChannel;
p.intensity.otherChannel = collagenChannel;
p.intensityBlebCompare.channels = cellSegChannel;