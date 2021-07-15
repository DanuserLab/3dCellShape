function watersheds = labelWatersheds(neighbors, measure)

% labelWatersheds - perform a watershed segmentation of measure on the mesh

% find the local minima and the flow direction at all faces
[~, isMin, ~, flowIn] = assignGradientAtNodes(neighbors, measure);

% initialize the watersheds matrix
watersheds = zeros(size(measure, 1), 1);

% find the watershed for each local minima (the flat regions will mess this up
faceIndex = 1:size(isMin,1);
minima = faceIndex(isMin==1);
for m = minima
    
    % label the minima
    watersheds(m) = m;
    
    % make a list of neighboring nodes that flow into this node
    nodesToExplore = flowIn{m};
    
    while ~isempty(nodesToExplore)  
        
        % examine a node
        node = nodesToExplore(1); 
        
        % label the node by the index of the minima node
        watersheds(node) = m;
        
        % update the list of nodes to explore
        nodesToExplore(1) = []; 
        nodesToExplore = [nodesToExplore, flowIn{node}];
    end
    
end