function [neighbors, meanCurvatureSmoothed, meanCurvatureUnsmoothed, gaussCurvatureUnsmoothed, faceNorms] = measureCurvature(mesh, medianFilterRadius, smoothOnMeshIterations)

% measureCurvature - measures and smooths curvature on the mesh surface

% calculate the surface normals
[faceNorms,surfaceNorms] = surfaceNormalsFast(mesh);

% calculate the curvature
[gaussCurvatureUnsmoothed, meanCurvatureUnsmoothed] = surfaceCurvatureFast(mesh,surfaceNorms);

% construct a graph of the faces
try % this section is buggy because of irregularities in the mesh
    neighbors = findEdgesFaceGraph(mesh); % construct an edge list for the dual graph where the faces are nodes
catch
    disp('         Warning: The graph could not be constructed!')
    neighbors = [];
    return
end
    
% median filter the curvature in real space
medianFilteredCurvature = medianFilterKD(mesh, meanCurvatureUnsmoothed, medianFilterRadius);

% check for lingering infinities and replace them
if max(medianFilteredCurvature) > 1000  
    maxFiniteMeanCurvature = max(medianFilteredCurvature.*isfinite(medianFilteredCurvature));
    medianFilteredCurvature(medianFilteredCurvature > 1000) = maxFiniteMeanCurvature;    
end

if min(medianFilteredCurvature) < -1000
    minFinite = min(medianFilteredCurvature.*isfinite(medianFilteredCurvature));
    medianFilteredCurvature(medianFilteredCurvature < -1000) = minFinite; 
end

% replace any NaN's
medianFilteredCurvature(~isfinite(medianFilteredCurvature)) = 0;

% diffuse curvature on the mesh geometry
meanCurvatureSmoothed = smoothDataOnMesh(mesh, neighbors, medianFilteredCurvature, smoothOnMeshIterations);
