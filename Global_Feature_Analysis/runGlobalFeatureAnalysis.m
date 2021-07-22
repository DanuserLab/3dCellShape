%% Set directory 
saveDirectory = '/project/bioinformatics/Danuser_lab/zebrafish/analysis/Dagan/scripts/GitHub_3dCellShape/exampleCroppedCells/new_examples/segmentation'; % directory for the analysis input
cellList=[5, 11, 12, 13, 16, 42, 43, 46, 47, 55];

%% Calculate the global geometry feature
fn='threshold1.tif';
for n=1:length(cellList)
    %load the segmented image
    image3D=load3DImage([saveDirectory '/Cell' num2str(cellList(n)) '/thresholded'],fn);
    %set directory for each cell
    saveCellPath=[saveDirectory '/Cell' num2str(cellList(n)) '/GlobalMorphology'];
    if ~isfolder(saveCellPath)
        mkdir(saveCellPath) 
    end
    
    %caculate the global feature for 3D image
    [globalGeoFeature convexImage Image] = calGlobalGeometricFeature(image3D); 
    %save the global feature for each cell
    save(fullfile(saveCellPath,'globalGeoFeature.mat'),'globalGeoFeature');
    save(fullfile(saveCellPath,'convexImage.mat'),'convexImage');
    save(fullfile(saveCellPath,'Image.mat'),'Image');  
end 

%% Statistical analysis for evaluation
% create a matrix of a list of cells and desired features
%read the expertimental codition from xlsx file
xlsxPath='/project/bioinformatics/Danuser_lab/zebrafish/analysis/Hanieh/Voodoo_analysis/morphology_croppedcells/200123_organized/smoothImageScale3/Scripts/Paper';
sheet='Sheet1';
[NumData, StrData]=xlsread(fullfile(xlsxPath, 'CellTable.xlsx'),sheet);

cellList=NumData(2:end,1); % check the StrData for confirmation
cellCond=[StrData(2:end,2) StrData(2:end,3)];

%set the desired feature for the post-processing analysis 
featType=[ {'Volume'} {'SurfaceArea'} ... 
      {'Sphericity'} {'Solidity'} {'LongLength'} {'AspectRatio'}...
      {'Roughness'} {'Extend'} {'CirmuscribedSurfaceRatio'} ...
      {'VolumeSphericity'} {'RadiusSphericity'} {'RatioSphericity'}];

%create a matrix of desired features (column) for a list of cells (row)
[statMat statMat_Norm]=createStatMatrix_cell(saveDirectory,cellList,cellCond(:,2),featType);

% PCA
plotFlag=0;
[~, score]=calPCA_globalGeometry(statMat_Norm,statMat,plotFlag);

% Permutation Pvalue (boostrapping) for a pair of experimental conditions
% in PC space
ExpCond={'c-shRNA' , 'EF1-shRNA'};
totalDist=score(:,1:2); % distribution from the fisrt two components of PCA
[dist1 dist2]=createSubDists(totalDist,cellCond(:,2),ExpCond);

%boosttrapping - find Pvalue for selected distributions
Ntrials=1500;  % number of permutation test
metric='TukeyMedian';  
genSample='randomLabel'; 
[pValue compDist comp2Dists] = bootstrapping2DistComp(dist1,dist2,Ntrials,metric,genSample);

%% Statistical analysis for visualization
% Kmeans clustering in PCA
for k=3:10
clear S Sil_score
KGroup=zeros(size(totalDist,1),N_trial);
[KGroup(:,k),Sout]=kmeans(totalDist,k,'Replicates',1000);
s(1,k) = silhouette(score_partially,KGroup(:,k)) % check in PCA space
end 
