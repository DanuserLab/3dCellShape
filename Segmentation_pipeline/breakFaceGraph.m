function [face1, face2, face3] = breakFaceGraph(surface, f, face1, face2, face3)

% breakFaceGraph - breaks badly connected fgraphs so that a more reasonable graph can be constructed (see findEdgesFaceGraph)

% find the vertices of the current face
cVertices = surface.faces(f,:);

% find a face from the list of multiply connected faces with the correct normal direction
% (i.e. break the edges between the faces in some random way while disallowing a self-intersecting surface)
if length(face1) > 1 % if the first edge is the multiple one
    
    badFace = 1; index = 1;
    while badFace == 1
        currentFaceEdgeOrder = intersect(cVertices,surface.faces(face1(index),:),'stable');
        neighFaceEdgeOrder = intersect(surface.faces(face1(index),:),cVertices,'stable');
        
        % swap the order if the edge appears at the first and third spots in either list
        if currentFaceEdgeOrder(1,1) == cVertices(1,1) && currentFaceEdgeOrder(1,2) == cVertices(1,3)
           currentFaceEdgeOrder = fliplr(currentFaceEdgeOrder);
        end
        if neighFaceEdgeOrder(1,1) == surface.faces(face1(index),1) && neighFaceEdgeOrder(1,2) == surface.faces(face1(index),3)
           neighFaceEdgeOrder = fliplr(neighFaceEdgeOrder);
        end
        
        if sum(currentFaceEdgeOrder == neighFaceEdgeOrder) 
            index = index+1;
        else
            face1 = face1(index);
            badFace = 0;
        end
    end
    
elseif length(face2) > 1 % if the second edge is the multiple one
    
    badFace = 1; index = 1;
    while badFace == 1
        currentFaceEdgeOrder = intersect(cVertices,surface.faces(face2(index),:),'stable');
        neighFaceEdgeOrder = intersect(surface.faces(face2(index),:),cVertices,'stable');
        
        % swap the order if the edge appears at the first and third spots in either list
        if currentFaceEdgeOrder(1,1) == cVertices(1,1) && currentFaceEdgeOrder(1,2) == cVertices(1,3)
           currentFaceEdgeOrder = fliplr(currentFaceEdgeOrder);
        end
        if neighFaceEdgeOrder(1,1) == surface.faces(face2(index),1) && neighFaceEdgeOrder(1,2) == surface.faces(face2(index),3)
           neighFaceEdgeOrder = fliplr(neighFaceEdgeOrder);
        end
        
        if sum(currentFaceEdgeOrder == neighFaceEdgeOrder) 
            index = index+1;
        else
            face2 = face2(index);
            badFace = 0;
        end
    end
    
elseif length(face3) > 1 % if the third edge is the multiple one
    
    badFace = 1; index = 1;
    while badFace == 1
        currentFaceEdgeOrder = intersect(cVertices,surface.faces(face3(index),:),'stable');
        neighFaceEdgeOrder = intersect(surface.faces(face3(index),:),cVertices,'stable');
        
        % swap the order if the edge appears at the first and third spots in either list
        if currentFaceEdgeOrder(1,1) == cVertices(1,1) && currentFaceEdgeOrder(1,2) == cVertices(1,3)
           currentFaceEdgeOrder = fliplr(currentFaceEdgeOrder);
        end
        if neighFaceEdgeOrder(1,1) == surface.faces(face3(index),1) && neighFaceEdgeOrder(1,2) == surface.faces(face3(index),3)
           neighFaceEdgeOrder = fliplr(neighFaceEdgeOrder);
        end
        
        if sum(currentFaceEdgeOrder == neighFaceEdgeOrder) 
            index = index+1;
        else
            face3 = face3(index);
            badFace = 0;
        end
    end
     
end
