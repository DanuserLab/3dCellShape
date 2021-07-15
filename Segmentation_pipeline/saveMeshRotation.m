function saveMeshRotation(light_handle, rotSavePath, varargin)
% saveMeshRotation - rotate and save the current figure (could be used after plotMeshFigure)
ip = inputParser;
ip.KeepUnmatched = true;
addRequired(ip, 'light_handle', @(x) numel(x) == 3 && isgraphics(x{1}));
addRequired(ip, 'rotSavePath', @ischar);
% addParameter(ip, 'figHandle', [], @isgraphics);
addParameter(ip, 'movieAVISavePath', '', @ischar);
addParameter(ip, 'setView', [0 90], @isnumeric);
ip.parse(light_handle, rotSavePath, varargin{:});
p = ip.Results;

figHandle = ancestor(light_handle{1}, 'figure','toplevel');

% rotate the figure
% set the view
view(p.setView(1), p.setView(2));
for v = 1:360
    camorbit(1,0,'camera')
    light_handle{1} = camlight(light_handle{1}, 0, 0); 
    light_handle{2} = camlight(light_handle{2}, 120, -60); 
    light_handle{3} = camlight(light_handle{3}, 240, 60);
    %light_handle = camlight(light_handle,'headlight'); 
    lighting phong     
    drawnow
    toName = sprintf('rotate%03d',v);
    saveas(figHandle, fullfile(rotSavePath,toName), 'tiffn');
    if ~isempty(p.movieAVISavePath)
        movieFrames(v) = getframe(figHandle);
    end    
end

if ~isempty(p.movieAVISavePath)
    v = VideoWriter([p.movieAVISavePath filesep  'MeshMovie_Rotation.avi']);
    v.FrameRate = 30;
    open(v);
    writeVideo(v, movieFrames);
    close(v);    
end
 