function [smallOTF, newImageSize] = calculateSmallOTF(PSF, imageSize)

% calculateSmallOTF - calculates an OTF of the size specified given a PSF of equal or greater size

% INPUTS:
%
% PSF - a 3D point spread function larger than imageSize
%
% imageSize - the size of the 3D image for which a PSF is needed. Must be
%             the same size or smaller than the PSF.
%
% OUTPUTS:
%
% smallOTF - an optical transfer function sized to the image size
%
% newImageSize - the size images will be cropped to if they are larger than
%                the PSF

% the saved PSF must be the same size or larger than the images
sizePSF = size(PSF);
if (sizePSF(1)<imageSize(1)) || (sizePSF(2)<imageSize(2)) || (sizePSF(3)<imageSize(3))
    warning('The PSF is smaller than the image size in at least one dimension. All images will be cropped.')
    
    % find the size that the image will be cropped to
    newImageSize = [min([sizePSF(1) imageSize(1)]), min([sizePSF(2) imageSize(2)]), min([sizePSF(3) imageSize(3)])];
else
    newImageSize = imageSize;
end

% find the box of size newImageSize about the PSF origin
originPSF = ceil((sizePSF+ones(1,3))/2); % (for even sizes the origin occurs above the center, i.e. the origin of an image with size 4x4 occurs at (3,3) )
PSF = PSF-min(PSF(:));
PSF = PSF./max(PSF(:));
smallPSF = PSF((originPSF(1)-ceil((newImageSize(1)-1)/2)):(originPSF(1)+floor((newImageSize(1)-1)/2)), ...
    (originPSF(2)-ceil((newImageSize(2)-1)/2)):(originPSF(2)+floor((newImageSize(2)-1)/2)), ...
    (originPSF(3)-ceil((newImageSize(3)-1)/2)):(originPSF(3)+floor((newImageSize(3)-1)/2))); clear PSF;

% find the OTF
smallOTF = fftshift(fftn(smallPSF)); clear smallPSF ;
smallOTF = abs(smallOTF);