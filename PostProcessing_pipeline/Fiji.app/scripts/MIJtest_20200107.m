[M,I]=max(max(max(FinalImage)));
imgs=FinalImage;

Miji();
%javaaddpath ij.jar;
%javaaddpath mij.jar;
MIJ.createImage(imgs);
MIJ.setSlice(I);
MIJ.run('StackReg', ("transformation=Translation"));
MIJ.run('Close');
	
% exit FIJI
MIJ.exit