function vertexColorRGB = faceColorsToVertexColorsRGB(faceColor, mesh, cmap, climits)

% faceColorsToVertexColorsRGB - converts a per-face color to a per-vertex color after conversion to an RGB colormap

% truncate the colormap
faceColor(faceColor < climits(1)) = climits(1);
faceColor(faceColor > climits(2)) = climits(2);

% make a vertex colormap for scaler faceColors
if numel(faceColor) == 1
    vertexColorRGB = repmat(cmap,length(mesh.vertices),1);
else
    
    % generate the per-face RGB surface colors
    minColor = min(faceColor); maxColor = max(faceColor);
    faceColorRGB = cmap(floor((length(cmap)-1)*((faceColor-minColor)/(maxColor-minColor)))+1,:);

    % generate the per-vertex RGB surface colors (this is slow)
    vertexColorRGB = nan(length(mesh.vertices),3);
    for v = 1:length(vertexColorRGB) % I tried vectorizing this, but it was slower
        
        % this line takes a very, very long time to run ...
        vertexColorRGB(v,:) = mean([faceColorRGB(v == mesh.faces(:,1),:); faceColorRGB(v == mesh.faces(:,2),:); faceColorRGB(v == mesh.faces(:,3),:)],1);
    
    end
 
end

