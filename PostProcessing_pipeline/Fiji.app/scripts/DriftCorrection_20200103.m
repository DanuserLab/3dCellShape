clc; clear;
currentpath= pwd;

imagePath = '/project/bioinformatics/Danuser_lab/zebrafish/analysis/Dagan/Voodoo_analysis/20200207_autocrop';
Cell_name= '210122hbCell'; % e.g. Cell or Shear_Cell
Cell_index= [1]; % specify the cell index wish to be processed
ChannelstoProcess = [0]; % specify the channels wish to be processed, start from 0, i.e. CH00
timepoint= []; % specify the timepoint wish to be processed, leave it blank if you want to process all time points.

%% Start MIJ
javaaddpath '/project/bioinformatics/Danuser_lab/zebrafish/matlab/Fiji.app/scripts/ij.jar';
javaaddpath '/project/bioinformatics/Danuser_lab/zebrafish/matlab/Fiji.app/scripts/mij.jar';
Miji(); % start the MIJ
%% 

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
       filename=strcat('cell_cropped_',num2str((t-1),'%06.0f'),'.tif')
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
cd (currentpath)
disp('All Done')