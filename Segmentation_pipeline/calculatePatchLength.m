function [patchLengthSmall, patchLengthBig] = calculatePatchLength(positions, watersheds, faceIndex, firstLabel, secondLabel, meshLength)

% calculatePatchLength - given two patches on a mesh, finds the maximum length in x y or x of the smallest patch (minimum returned patch length is 8)

% calculate the minimum patchLength of the two regions
firstFaces = faceIndex(watersheds == firstLabel);
secondFaces = faceIndex(watersheds == secondLabel);
firstSize = max([max(positions(firstFaces,1))-min(positions(firstFaces,1)), ... 
    max(positions(firstFaces,2))-min(positions(firstFaces,2)), max(positions(firstFaces,3))-min(positions(firstFaces,3))]);
secondSize = max([max(positions(secondFaces,1))-min(positions(secondFaces,1)), ... 
    max(positions(secondFaces,2))-min(positions(secondFaces,2)), max(positions(secondFaces,3))-min(positions(secondFaces,3))]);
patchLengthSmall = min([firstSize, secondSize, 0.2*meshLength]);
patchLengthSmall = max([patchLengthSmall, 8]);
patchLengthBig = max([firstSize, secondSize]);