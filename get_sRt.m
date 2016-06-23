close all; clear;
filename = 'D:\play\movie\Video_Figure_1.mov';
hVideoSrc = vision.VideoFileReader(filename, 'ImageColorSpace', 'Intensity');

% Reset the video source to the beginning of the file.
reset(hVideoSrc);

hVPlayer = vision.VideoPlayer; % Create video viewer

% Process all frames in the video
movMean = step(hVideoSrc);
imgB = movMean;
imgBp = imgB;
correctedMean = imgBp;
ii = 2;
Hcumulative = eye(3);
frames = {};
Homo = {};
frames{1} = imgB;
Homo{1} = eye(3);
%while ~isDone(hVideoSrc) && ii < 10
while ~isDone(hVideoSrc)
    % Read in new frame
    imgA = imgB; % z^-1
    imgAp = imgBp; % z^-1
    imgB = step(hVideoSrc);
    movMean = movMean + imgB;

    % Estimate transform from frame A to frame B, and fit as an s-R-t
    H = cvexEstStabilizationTform(imgA,imgB);
    HsRt = cvexTformToSRT(H);
    Hcumulative = HsRt * Hcumulative;
    Homo{ii} = Hcumulative;
%     if (mod(ii,30) == 1)
%         Hcumulative = Homo{1};
%     end
    imgBp = imwarp(imgB,affine2d(Hcumulative),'OutputView',imref2d(size(imgB)));

    frames{ii} = imgBp;

    % Display as color composite with last corrected frame
    step(hVPlayer, imfuse(imgAp,imgBp,'ColorChannels','red-cyan'));
    correctedMean = correctedMean + imgBp;

    ii = ii+1;
end
correctedMean = correctedMean/(ii-2);
movMean = movMean/(ii-2);

% Here you call the release method on the objects to close any open files
% and release memory.
release(hVideoSrc);
release(hVPlayer);

myObj = VideoWriter('..\video\newfile.avi');
writerObj.FrameRate = 30;
open(myObj);
%for i=1:numFrames
for i=1:size(frames,2)
    writeVideo(myObj,frames{i});
end
close(myObj);