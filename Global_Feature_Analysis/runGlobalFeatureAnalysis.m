%% Set directory 
saveDirectory = '/project/bioinformatics/Danuser_lab/zebrafish/analysis/Dagan/scripts/GitHub_3dCellShape/exampleCroppedCells/new_examples/segmentation'; % directory for the analysis output
cellList=[5, 11, 12, 13,14,15 16, 40,42, 43, 46, 47, 81, 91];

%% Calculate the global geometry feature
fn='threshold1.tif';
for n=1:length(cellList)
    %load the segmented image
    image3D=load3DImage([saveDirectory filesep 'Cell' num2str(cellList(n)) filesep 'thresholded'],fn);
    %set directory for each cell
    saveCellPath=[saveDirectory filesep 'Cell' num2str(cellList(n)) filesep 'GlobalMorphology'];
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
xlsxPath='/project/bioinformatics/Danuser_lab/zebrafish/analysis/Dagan/scripts/GitHub_3dCellShape/exampleCroppedCells/new_examples'; % directory for the analysis output
sheet='Sheet1';
[NumData, StrData]=xlsread(fullfile(xlsxPath, 'index.xlsx'),sheet);

cellList=NumData(:,1); % check the StrData for confirmation
cellCond=[StrData(2:end,2) StrData(2:end,3)];

%set the desired feature for the post-processing analysis 
featType=[ {'Volume'} {'SurfaceArea'} ... 
      {'Sphericity'} {'Solidity'} {'LongLength'} {'AspectRatio'}...
      {'Roughness'} {'Extent'} {'CirmuscribedSurfaceRatio'} ...
      {'VolumeSphericity'} {'RadiusSphericity'} {'RatioSphericity'}];

%create a matrix of desired features (column) for a list of cells (row)
[statMat statMat_Norm]=createStatMatrix_cell(saveDirectory,cellList,featType);

% PCA
plotFlag=1;
[~, score]=calPCA_globalGeometry(statMat_Norm,statMat,plotFlag,featType);

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
clear s 
KGroup=nan(size(totalDist,1));
[KGroup(:,k),Sout]=kmeans(totalDist,k,'Replicates',1000);
s = silhouette(totalDist,KGroup(:,k)); % check in PCA space
S(1,k)=median(s); % maximum of S is the number of cluster
end 
