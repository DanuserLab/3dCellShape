function [light_handle, meshHandle] = plotMeshFigure(image3D, meshToPlot, meshColor, cmap, climits, alpha, varargin)

% plotMeshFigure - generates a figure with a 3D rendering of a colored mesh

% INPUTS:
%
% image3D    - the image from which the mesh was found (used to calculate
%            better normal vectors for realistic mesh shine)
%
% meshToPlot - the mesh (in standard matlab format)
% 
% meshColor  - a list of intensities corresponding to each triangular face
%            (used to color the mesh and in the same order as the list of 
%            faces in the meshToPlot structure)
% 
% cmap       - the colormap used for the surface
%
% climits    - the minimum and maximum intensities displayed (these will be
%            mapped to the ends of the colormap)
ip = inputParser;
ip.addRequired('image3D');
ip.addRequired('meshToPlot');
ip.addRequired('meshColor');
ip.addRequired('cmap');
ip.addRequired('climits');
ip.addRequired('alpha');
ip.addParameter('figHandle',[], @isgraphics);
ip.parse(image3D, meshToPlot, meshColor, cmap, climits, alpha, varargin{:});
p = ip.Results;

% plot the mesh
if isempty(p.figHandle)
    meshHandle = patch(meshToPlot,'FaceColor','flat','EdgeColor','none','FaceAlpha',alpha);
elseif isgraphics(p.figHandle)
    delete(p.figHandle.Children)
    try
        meshHandle = patch(p.figHandle.Children(1),meshToPlot,'FaceColor','flat','EdgeColor','none','FaceAlpha',alpha);
    catch
        axes('Parent',p.figHandle,'Visible','off')
        meshHandle = patch(p.figHandle.Children(1),meshToPlot,'FaceColor','flat','EdgeColor','none','FaceAlpha',alpha);
    end
end
% meshHandle = patch(meshToPlot,'FaceColor','flat','EdgeColor',[0.85 0.85 0.85],'FaceAlpha','flat', 'LineWidth', 0.1);

% color the mesh
meshHandle.FaceVertexCData = meshColor; 
colormap(meshHandle.Parent, cmap);
caxis(meshHandle.Parent,climits);

% % only make some faces visible
% meshHandle.FaceVertexAlphaData = double(~logical(floor(20*rand(size(meshColor)))));

% improve the mesh shine
isonormals(image3D, meshHandle)

% properly set the axis
%axis([130 330 0 400 0 200]);
daspect(meshHandle.Parent, [1 1 1]); axis(meshHandle.Parent, 'off'); 

% % change the material properties
% material([0.45 0.45 0.9])

% light the scene
%light_handle = camlight('headlight'); 
camlookat(meshHandle); 
light_handle{1} = camlight(meshHandle.Parent,0,0); 
light_handle{2} = camlight(meshHandle.Parent,120,-60); 
light_handle{3} = camlight(meshHandle.Parent,240,60);
lighting(meshHandle.Parent, 'phong');

