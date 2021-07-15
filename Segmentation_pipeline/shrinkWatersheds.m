function watersheds = shrinkWatersheds(maxThreshold, measure, neighbors, watersheds, trimBoundaries)

% shrink the watersheds from the outside in until all faces on the edge of the watershed are below the threshold value

% initialize matrices
numFaces = size(neighbors,1);
keepShrinking = 1;

% keep shrinking if any region was shrunk in the last round
while keepShrinking == 1
    
    % stop shrinking if no face is zeroed
    keepShrinking = 0;
    
    % iterate through the faces
    for f = 1:numFaces

        % find the label of the current face
        fLabel = watersheds(f);

        % check if the face is on a boundary and if the measure is greater than the max threshold
        if  (fLabel > 0) && ...
                ((fLabel~=watersheds(neighbors(f,1))) || (fLabel~=watersheds(neighbors(f,2))) || (fLabel~=watersheds(neighbors(f,3)))) && ...
                (measure(f)>maxThreshold)
            
            % remove the face from the watershed
            watersheds(f) = 0;
            
            % shrink another round
            keepShrinking = 1;
            
        end

    end
    
end


% remove triangles in the region that only border one other triangle in the region
if trimBoundaries
    
    keepTriming = 1;  
    while keepTriming == 1
    
        % stop triming if no face is zeroed
        keepTriming = 0;
        
        % iterate through the faces
        for f = 1:numFaces

            % find the label of the current face
            fLabel = watersheds(f);

            % check if the face is on a boundary and has only one neighbor in a watershed
            if  (fLabel > 0) && ...
                ((fLabel~=watersheds(neighbors(f,1))) || (fLabel~=watersheds(neighbors(f,2))) || (fLabel~=watersheds(neighbors(f,3)))) && ...
                ( sum( watersheds(neighbors(f,:))>0 )==1 )

                % remove the face from the watershed
                watersheds(f) = 0;
                %disp('Trimming')
                % trim another round
                keepTriming = 1;
            end
            
        end
    
    end
end

% find a list of non-flat watershed regions
regions = unique(watersheds);
regions = regions(regions>0);

% find the first available watershed label for region relabeling
nextLabel = max(watersheds)+1;

% relabel disconected watersheds as seperate regions
for r = regions'
    
    % make a sparse matrix of the faces in the region
    [sparseRegion, nodeLabels] = graphOfRegion(neighbors,watersheds,r);
     
    % find the number of connected components in the region
    [numComps, region2comp] = graphconncomp(sparseRegion, 'Weak', true);
    
    % if there is more than one component than relabel them (this has not been tested)
    if numComps > 1

        for c=1:numComps
            
            % find the nodes in this component
            nodesInComp = nodeLabels(region2comp==c);
            
            % relabel the watershed for each of the nodes in the component
            for n = 1:length(nodesInComp)
                watersheds(watersheds==nodesInComp(n)) = nextLabel;
            end
            
            % find the next available watershed label
            nextLabel = nextLabel+1;
        end 
    end

end
