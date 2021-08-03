% This code is for post-processing of regions of interest acquired for the 
% manuscript "In vivo profiling of site-specific human cancer cell states
% in zebrafish, " on BioRxiv. It consists of (1) an image registration module
% to align images within a z-stack to counter movement during acquisition
% and (2) a deconvolution module based on a synthetic PSF optimized for our
% dataset. For different applications- a different PSF will be required
% that fits with the specific dataset. 
%% This section applies drift correction using the StackReg plugin 
%[76] in ImageJ [77] to counter sample movement in Z during acquisition, 
%via MIJ, a java package for running ImageJ within MATLAB. 
%76.	Thevenaz, P., U.E. Ruttimann, and M. Unser, A pyramid approach to 
%subpixel registration based on intensity. IEEE Trans Image Process, 1998. 7(1): p. 27-41.
%77.	Schindelin, J., et al., Fiji: an open-source platform for 
%biological-image analysis. Nat Methods, 2012. 9(7): p. 676-82.


clc; clear;
%currentpath= pwd;

imagePath = '/home2/s177757/exampleCroppedCells' %path to your data here
Cell_name= 'Cell'; % e.g. Cell or Shear_Cell
Cell_index= [14, 15, 40, 81, 89]; % specify the cell index wish to be processed
ChannelstoProcess= [1]; % specify the channels wish to be processed, start from 0, i.e. CH00
timepoint= []; % specify the timepoint wish to be processed, leave it blank if you want to process all time points.

%% Start MIJ
javaaddpath 'ij.jar';
javaaddpath 'mij.jar';
Miji(); % start the MIJ
%% 
%cd (currentpath)
numfolder=size(Cell_index,2);
ch_number= size(ChannelstoProcess,2);

for c=1:numfolder
    
    names2=strcat(Cell_name,num2str(Cell_index(c)));
            
    numImages=size(dir(fullfile(imagePath,names2)),1)-2; % if Cell_name= 'Cell*',   numImages=size(dir(fullfile(imagePath,names2)),1)-3
    if size(timepoint,2)==0
        t_st=1;
        %t_end=(size(names2,1)-2)/ch_number;
        t_end=round(numImages/ch_number);
    else
        t_st=min(timepoint);
        t_end=max(timepoint);
    end
    
dir_driftcorrection=strcat('driftcorrect_',names2);
mkdir(fullfile(imagePath,dir_driftcorrection));
  
    
    for t=t_st:t_end
        for ch=1:size(ChannelstoProcess,2)
        
        tic
       filename=strcat('1_CH',num2str(ChannelstoProcess(ch),'%02.0f'),'_',num2str((t-1),'%06.0f'),'.tif');
       filepath=fullfile(imagePath,names2,filename);
       InfoImage=imfinfo(filepath);
       mImage=InfoImage(1).Height;
       nImage=InfoImage(1).Width;
       NumberImages=length(InfoImage);
       
       FinalImage=zeros(mImage,nImage,NumberImages,'uint16');
      
    TifLink = Tiff(filepath, 'r');
for i=1:NumberImages
   TifLink.setDirectory(i);
   FinalImage(:,:,i)=TifLink.read();
end
TifLink.close();     

[M,I]=max(max(max(FinalImage)));
MIJ.createImage(FinalImage);
MIJ.setSlice(I);
MIJ.run('StackReg', ["transformation=Translation"]);
imgsRegistered = MIJ.getCurrentImage;
final=uint16(imgsRegistered);

finalPath=fullfile(imagePath,dir_driftcorrection,filename);
            
              
    [nx, ny, nz]= size(final);
    imgType= class(final);
    tagstruct.Photometric= Tiff.Photometric.MinIsBlack;
    tagstruct.ImageLength = nx;
    tagstruct.ImageWidth = ny;
    tagstruct.PlanarConfiguration= Tiff.PlanarConfiguration.Chunky;
    tagstruct.Compression = Tiff.Compression.None;
    tagstruct.BitsPerSample= 16;
    
    tiffFile=Tiff(finalPath, 'w');
    
    for iz=1:nz
        tiffFile.setTag(tagstruct);
        tiffFile.write(final(:,:,iz));
        tiffFile.writeDirectory();
        
    end
    tiffFile.close();
MIJ.run('Close');

toc, disp('Done')
        end
    end
end
MIJ.exit
disp('All Done')

%% This section applies deconvolution to all images prior to 
%segmentation, using blind deconvolution with a synthesized PSF with 
%10 iterations.
imagePath = '/home2/s177757/exampleCroppedCells' %path to your data here
Cell_name= 'driftcorrect_Cell'; % e.g. Cell or Shear_Cell
Cell_index= [5, 11, 12, 13, 16, 42, 43, 46, 47, 55]; % specify the cell index wish to be processed
ChannelstoProcess= [1]; % specify the channels wish to be processed, start from 0, i.e. CH00
timepoint= []; % specify the timepoint wish to be processed, leave it blank if you want to process all time points.
psfPath= '/home2/s177757/matlab/3dCellShape-main/PostProcessing_pipeline';
psf {1}= 'Example_PSF.tif'; % This is a synthesized PSF optimized for the example data. Each microscope will require a different psf for deconvolution.
psf {2}= 'Example_PSF.tif';


background= 170; % measure the background in the PSF data

iter=10; %number of iterations
dir_Dec=fullfile(imagePath,strcat('DB_',num2str(iter),'_PSF_chop',num2str(background)));
mkdir(dir_Dec);


%% load PSF
for p=1: size(psf,2)
    filepath=fullfile(psfPath,psf{p});
    InfoImage=imfinfo(filepath);
    mImage=InfoImage(1).Height;
    nImage=InfoImage(1).Width;
    NumberImages=length(InfoImage);
           
    TifLink = Tiff(filepath, 'r');
for i=1:NumberImages
   TifLink.setDirectory(i);
   PSFimage(:,:,i)=TifLink.read();
end
TifLink.close();

PSFimage=double(PSFimage);
PSFimage=PSFimage-background;
PSFimage=abs(PSFimage);
%PSFimage=PSFimage./sum(sum(sum(PSFimage)));
PSF{p}=PSFimage;

end
clear PSFimage

%% Deconvolution

numfolder=size(Cell_index,2);
ch_number= size(ChannelstoProcess,2);

for c=1:numfolder
    
    names2=strcat(Cell_name,num2str(Cell_index(c)));
    
    numImages=size(dir(fullfile(imagePath,names2)),1)-2; % if Cell_name= 'Cell*',   numImages=size(dir(fullfile(imagePath,names2)),1)-3
    if size(timepoint,2)==0
        t_st=1;
        %t_end=(size(names2,1)-2)/ch_number;
        t_end=round(numImages/ch_number);
    else
        t_st=min(timepoint);
        t_end=max(timepoint);
    end
    
    for t=t_st:t_end
    
        for ch=1:ch_number
        
        tic
     
       filename=strcat('1_CH',num2str(ChannelstoProcess(ch),'%02.0f'),'_',num2str((t-1),'%06.0f'),'.tif');
       %filename=strcat('1_CH',num2str((ch-1),'%02.0f'),'_',num2str((t-1),'%06.0f'),'.tif');
       filepath=fullfile(imagePath,names2,filename);
       InfoImage=imfinfo(filepath);
       mImage=InfoImage(1).Height;
       nImage=InfoImage(1).Width;
       NumberImages=length(InfoImage);
       %NumberImages=958;
       
       FinalImage=zeros(mImage,nImage,NumberImages,'uint16');

       TifLink = Tiff(filepath, 'r');
for i=1:NumberImages
   TifLink.setDirectory(i);
   FinalImage(:,:,i)=TifLink.read();
end
TifLink.close();


%% Deconvolution
%padx=ceil(mImage/2);
%pady=ceil(nImage/2);
%padz=ceil(NumberImages/2);
%E1=padarray(single(FinalImage),[20 20],'symmetric') ; 
E1=padarray(single(FinalImage),[20 20 20],'symmetric') ; 
maxE1=max(E1(:));
minE1=min(E1(:));
psfi=single(PSF{ch});
%psfi=psfi./max(psfi(:));
[Dec,psfr]=deconvblind(E1,psfi,iter);
%Dec=Dec(21:20+mImage,21:20+nImage);
Dec=Dec(21:20+mImage,21:20+nImage,21:20+NumberImages);
Dec=(Dec-min(Dec(:)))/(max(Dec(:)-min(Dec(:))));
Dec=Dec.*(maxE1-minE1)+minE1;
%Dec=Dec./max(Dec(:));
Dec=uint16(Dec);

%% save deconvolved image
%finalPath=fullfile(dir_Dec,strcat('FirstBlind_',names2));
%mkdir(finalPath);

%Decname=fullfile(finalPath,strcat('Dec_',filename));
%Decname=fullfile(finalPath,filename);
    
%    [nx, ny, nz]= size(Dec);
%    imgType= class(Dec);
%    tagstruct.Photometric= Tiff.Photometric.MinIsBlack;
%    tagstruct.ImageLength = nx;
%    tagstruct.ImageWidth = ny;
%    tagstruct.PlanarConfiguration= Tiff.PlanarConfiguration.Chunky;
%    tagstruct.Compression = Tiff.Compression.None;
%    tagstruct.BitsPerSample= 16;
    
%    tiffFile=Tiff(Decname, 'w');
    
%    for iz=1:nz
%        tiffFile.setTag(tagstruct);
%        tiffFile.write(Dec(:,:,iz));
%        tiffFile.writeDirectory();
        
%    end
%    tiffFile.close();
    
%% save retrived psf 
psfr=psfr./max(psfr(:));
psfr2=uint16(60000*psfr);

%PSFname=fullfile(dir_Dec,strcat(names2,'psfr',num2str(c),'.tif'));
    
%    [nx, ny, nz]= size(psfr2);
%    imgType= class(psfr2);
%    tagstruct.Photometric= Tiff.Photometric.MinIsBlack;
%    tagstruct.ImageLength = nx;
%    tagstruct.ImageWidth = ny;
%    tagstruct.PlanarConfiguration= Tiff.PlanarConfiguration.Chunky;
%    tagstruct.Compression = Tiff.Compression.None;
%    tagstruct.BitsPerSample= 16;
    
%    tiffFile=Tiff(PSFname, 'w');
    
%    for iz=1:nz
%        tiffFile.setTag(tagstruct);
%        tiffFile.write(psfr2(:,:,iz));
%        tiffFile.writeDirectory();
        
%    end
%    tiffFile.close();


%% DoubleBlindDeconvolution
%[Dec2]=deconvlucy(E1,psfr,iter);
[Dec2,psfr3]=deconvblind(E1,psfr,iter);
%Dec2=Dec2(21:20+mImage,21:20+nImage);
Dec2=Dec2(21:20+mImage,21:20+nImage,21:20+NumberImages);
Dec2=(Dec2-min(Dec2(:)))/(max(Dec2(:)-min(Dec2(:))));
Dec2=Dec2.*(maxE1-minE1)+minE1;
%Dec=Dec./max(Dec(:));
Dec2=uint16(Dec2);
%Dec2=Dec2./max(Dec2(:));
%Dec2=uint16(Dec2*maxE1);

%% save DoubleBlindDeconvolved image
finalPath2=fullfile(dir_Dec,strcat('DoubleBlind_',names2));
mkdir(finalPath2);
Decname2=fullfile(finalPath2,filename);
    
    [nx, ny, nz]= size(Dec2);
    imgType= class(Dec2);
    tagstruct.Photometric= Tiff.Photometric.MinIsBlack;
    tagstruct.ImageLength = nx;
    tagstruct.ImageWidth = ny;
    tagstruct.PlanarConfiguration= Tiff.PlanarConfiguration.Chunky;
    tagstruct.Compression = Tiff.Compression.None;
    tagstruct.BitsPerSample= 16;
    
    tiffFile=Tiff(Decname2, 'w');
    
    for iz=1:nz
        tiffFile.setTag(tagstruct);
        tiffFile.write(Dec2(:,:,iz));
        tiffFile.writeDirectory();
        
    end
    tiffFile.close();
    
%% save retrived psf 
psfr3=psfr3./max(psfr3(:));
psfr4=uint16(60000*psfr3);

PSFname2=fullfile(dir_Dec,strcat(names2,'DBpsfr',num2str(c),'.tif'));
    
    [nx, ny, nz]= size(psfr4);
    imgType= class(psfr4);
    tagstruct.Photometric= Tiff.Photometric.MinIsBlack;
    tagstruct.ImageLength = nx;
    tagstruct.ImageWidth = ny;
    tagstruct.PlanarConfiguration= Tiff.PlanarConfiguration.Chunky;
    tagstruct.Compression = Tiff.Compression.None;
    tagstruct.BitsPerSample= 16;
   
    tiffFile=Tiff(PSFname2, 'w');
    
    for iz=1:nz
        tiffFile.setTag(tagstruct);
        tiffFile.write(psfr2(:,:,iz));
        tiffFile.writeDirectory();
        
    end
    tiffFile.close();
    
    
toc, disp('Done')
        end
    end
end

disp('All Done')