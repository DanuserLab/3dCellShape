function [statMat statMat_Norm]=createStatMatrix_cell(imageDirectory,cellList,featType)
%createStatMatrix creates a matrix of all features for cells in various
%experimental conditions for post-processing analysis. 
% 
% INPUT
% imageDirectory   file directory of the cell
% cellList         cell Id 
% cellCond         vector of experimental conditions for each cell
% featType         global geometry feature list
% OUTPUT
% statMat       Matrix of global geomtery features for desired cells- first
%               two columns are cellID and cellLabel
% statMat_Norm    zScore of the StatMat
% 
% Hanieh Mazloom-Farsibaf- Danuser lab 2021

statMat=nan(length(cellList),length(featType)+1);
statMat(:,1)=cellList;
% statMat(:,2)=cellCond;

for n=1:length(cellList)
    fileDir=[imageDirectory filesep 'Cell' num2str(cellList(n)) filesep 'GlobalMorphology'];
    load(fullfile(fileDir,'globalGeoFeature.mat'))
    for f=1:length(featType)
        statMat(n,f+1)=getfield(globalGeoFeature,featType{f}); 
    end 
end 


%normalized the statistical matrix 
statMat_Norm = zscore(statMat(:,2:end)); % exclude the cellList 
