close all; clear;

[obj,numFrames] = get_obj('','');
% filename = 'D:\play\movie\Video_Figure_1.mov';
% hVideoSrc = vision.VideoFileReader(filename, 'ImageColorSpace', 'Intensity');
% 
% imgA = step(hVideoSrc); % Read first frame into imgA
% imgB = step(hVideoSrc); % Read second frame into imgB
imgA = read(obj, 1);
imgB = read(obj, 2);

if ndims(imgA) == 3
    imgA = rgb2gray(imgA);
end
if ndims(imgB) == 3
    imgB = rgb2gray(imgB);
end

% figure; imshowpair(imgA, imgB, 'montage');
% title(['Frame A', repmat(' ',[1 200]), 'Frame B']);
% figure; imshowpair(imgA,imgB,'ColorChannels','red-cyan');
% title('Color composite (frame A = red, frame B = cyan)');

ptThresh = 0.1;
pointsA = detectFASTFeatures(imgA, 'MinContrast', ptThresh);
pointsB = detectFASTFeatures(imgB, 'MinContrast', ptThresh);

% % Display corners found in images A and B.
% figure; imshow(imgA); hold on;
% plot(pointsA);
% title('Corners in A');
% 
% figure; imshow(imgB); hold on;
% plot(pointsB);
% title('Corners in B');

% Extract FREAK descriptors for the corners
[featuresA, pointsA] = extractFeatures(imgA, pointsA);
[featuresB, pointsB] = extractFeatures(imgB, pointsB);

indexPairs = matchFeatures(featuresA, featuresB);
pointsA = pointsA(indexPairs(:, 1), :);
pointsB = pointsB(indexPairs(:, 2), :);

% figure; showMatchedFeatures(imgA, imgB, pointsA, pointsB);
% legend('Frame A', 'Frame B');

[tform, pointsBm, pointsAm] = estimateGeometricTransform(...
    pointsB, pointsA, 'affine');
imgBp = imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
pointsBmp = transformPointsForward(tform, pointsBm.Location);

% figure;
% showMatchedFeatures(imgA, imgBp, pointsAm, pointsBmp);
% legend('Frame A', 'Frame Bp');

% Extract scale and rotation part sub-matrix.
H = tform.T;
R = H(1:2,1:2);
% Compute theta from mean of two possible arctangents
theta = mean([atan2(R(2),R(1)) atan2(-R(3),R(4))]);
% Compute scale from mean of two stable mean calculations
scale = mean(R([1 4])/cos(theta));
% Translation remains the same:
translation = H(3, 1:2);
% Reconstitute new s-R-t transform:
HsRt = [[scale*[cos(theta) -sin(theta); sin(theta) cos(theta)]; ...
  translation], [0 0 1]'];
tformsRT = affine2d(HsRt);

imgBold = imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
imgBsRt = imwarp(imgB, tformsRT, 'OutputView', imref2d(size(imgB)));

% figure, clf;
% imshowpair(imgBold,imgBsRt,'ColorChannels','red-cyan'), axis image;
% title('Color composite of affine and s-R-t transform outputs');