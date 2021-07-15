function image3D = leftRightCorrectIntensity(image3D, imageMasked)

% leftRightCorrectIntensity - for 3D images, removes the left-right microscope asymmetry


% !!!!!!!!!!!!!!!!!!!!!!! Not done !!!!!!!!!!!!!!!!!!!!!!!!!!!

% tic
% % just iterate through the pixels (needlessly slow, maybe just iterate through the bounding box)
imageSize = size(image3D);
% distFromRight = zeros(imageSize);
% %[~,iMin] = find(sum(imageMasked,1); [~,iMax] = find(imageMasked,1, 'last');
% for i = 1:imageSize(1)
%     for j = 1:imageSize(2)
%         for k = 1:imageSize(3)
%             
%             % calculate the distance from the right
%             if imageMasked(i,j,k) == 1
%                 distFromRight(i,j,k) = sum(imageMasked(i, j:end, k));
%             end
%             
%         end
%     end
% end
% toc

% find pixels within some specific distance from the edge of imageMask
% this has not been tested)
maxDist = 6;
imageMasked = imfill(imageMasked, 'holes');
distMasked = bwdist(~imageMasked);
distMasked(distMasked > maxDist) = 0;
distMasked(distMasked>0) = 1;
distMasked(distMasked == 0) = NaN;
distMasked = double(distMasked);
pixelCount = nansum(nansum(distMasked,1),3);
intensitySum = nansum(nansum(distMasked.*image3D,1),3);
intensityProfile = intensitySum./pixelCount;
intensityProfileS = smooth(intensityProfile, 11);
figure
plot(intensityProfile, 'Color', 'k')

[pks,locs] = findpeaks(intensityProfileS);%, 'MinPeakProminence',1);
hold on
plot(locs(1), pks(1), 'Marker', 'x', 'Color', 'r');
plot(locs(end), pks(end), 'Marker', 'x', 'Color', 'r');
hold off

% fit a line through the two points 
slope = (pks(end) - pks(1))/(locs(end)-locs(1));
offset = pks(end) - slope*locs(end);

% make a 3D mask corresponding to that line 
x = 1:imageSize(2);
line = slope*x+offset;
mask = repmat(line, [imageSize(1), 1, imageSize(3)]);
image3D = image3D./mask;
imageSD(~isfinite(image3D)) = 0;
% figure
% plot(smooth(intensityProfile,5))
% 
% % % debug code
% figure
% imagesc(imageMasked(:,:,80))
% figure
% imagesc(distFromRight(:,:,80))
% figure
% imagesc(image3D(:,:,80))


