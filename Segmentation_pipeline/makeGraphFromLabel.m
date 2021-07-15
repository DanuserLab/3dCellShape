function [labels, segmentationGraph] = makeGraphFromLabel(neighbors, labeledFaces, includeFlat)

% makeGraphFromLabel - make a graph from a spatial segmentation of faces labeled by label


% initialize a cell array of connections
labels = unique(labeledFaces);
labelIndex = 1:length(labels);
segmentationGraph = cell(length(labels),1);

% iterate therough all the faces to look for edges in the segmentation graph
for node = 1:size(neighbors,1)
    nodeLabel = labeledFaces(node);
    
    % check if the node should be included in the graph
    isGoodNode = 1;
    if nodeLabel == 0, isGoodNode = 0; end
    if ~includeFlat && nodeLabel<0, isGoodNode = 0; end
    
    if isGoodNode
        
        % compare the node label to each of the neighbors
        for i = 1:3
            neighborlabel = labeledFaces(neighbors(node,i)); % the face label
            
            % if the neighbor is labeled differently than the node then there is an edge
            if nodeLabel ~= neighborlabel && neighborlabel 
                
                % find the index of the label in the list of labels (this is awkward)
                arrayIndex = (labelIndex'.*(nodeLabel==labels))>0; 
                
                segmentationGraph{arrayIndex} = [segmentationGraph{arrayIndex}, neighborlabel];
            end
        end                
    end
end
       
% only list edges once in the cell array of edges
for i = 1:length(labels)
    segmentationGraph{i} = unique(segmentationGraph{i});
end