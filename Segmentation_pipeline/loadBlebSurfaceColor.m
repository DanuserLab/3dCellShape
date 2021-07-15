function meshColor = loadBlebSurfaceColor(MD, chan, frame, colorKey)

% loadBlebSurfaceColor - loads the color of a mesh surface colored by bleb segmentation


% load the bleb segmentation
blebPath = MD.findProcessTag('MotifDetection3DProcess',false, false,'tag',false,'last').outFilePaths_{1,chan}; 
% blebPath = [MD.outputDirectory_ filesep 'Morphology' filesep 'Analysis' filesep 'MotifSegment']; 
blebName = ['blebSegment_' num2str(chan) '_' num2str(frame) '.mat'];
blebPath = fullfile(blebPath, blebName);
assert(~isempty(dir(blebPath)), 'No saved blebs found.');
bStruct = load(blebPath);

% load the list of neighbors
neighborsPath = MD.findProcessTag('Mesh3DProcess',false, false,'tag',false,'last').outFilePaths_{1,chan}; 
% neighborsPath = [MD.outputDirectory_ filesep 'Morphology' filesep 'Analysis' filesep 'Mesh']; 

neighborsName = ['neighbors_' num2str(chan) '_' num2str(frame) '.mat'];
neighborsPath = fullfile(neighborsPath, neighborsName);
assert(~isempty(dir(neighborsPath)), 'No saved list of neighbors was found.');
nStruct = load(neighborsPath);

% determine which faces are on the boundary between blebs
onBoundary = findBoundaryFaces(bStruct.blebSegment, nStruct.neighbors, 'double');

% make faces that are on the boundary or outside of a bleb grey
meshColor = mod(bStruct.blebSegment*colorKey,1024)+1;
meshColor(bStruct.blebSegment<1) = 0; % outside of a bleb
meshColor(onBoundary==1) = 0; % on the boundary