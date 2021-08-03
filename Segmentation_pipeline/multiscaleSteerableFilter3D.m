function [res, nms, theta, scale] = multiscaleSteerableFilter3D(image3D, type, scales)

% multiscaleSteerableFilter3D - 3D steerable filters across the specified scales
        
% iterate through the scales
%disp(['        steerable filtering'])
for s = 1:length(scales)
    %disp(['          scale: ' num2str(scales(s)) ' pixels'])
    
    % look for linear objects at the specified scale
    [resCur, thetaCur, nmsCur] = steerableDetector3D(image3D, type, scales(s));
    resCur = resCur./(scales(s)*sqrt(2*pi));
    
    % combine scales (this code comes from multiscaleSteerableDetector3D.m)
    if s == 1
        res = resCur; clear resCur
        nms = nmsCur; clear nmsCur
        theta = thetaCur; clear thetaCur
        imageSize = size(res);
        scale = scales(s)*ones(imageSize(1), imageSize(2), imageSize(3));
        
    else
        imBetterMask = resCur > res;
        res(imBetterMask) = resCur(imBetterMask); clear resCur
        nms(imBetterMask) = nmsCur(imBetterMask); clear nmsCur
        theta.x1(imBetterMask) = thetaCur.x1(imBetterMask);
        theta.x2(imBetterMask) = thetaCur.x2(imBetterMask);
        theta.x3(imBetterMask) = thetaCur.x3(imBetterMask); clear thetaCur
        
        scaleCur = scales(s)*ones(imageSize(1), imageSize(2), imageSize(3));
        scale(imBetterMask) = scaleCur(imBetterMask);
        
    end
end
