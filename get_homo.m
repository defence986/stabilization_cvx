close all; clear;

[obj,numFrames] = get_obj('','');

imgB = read(obj, 1);
imgBp = imgB;

k = 2;
Hcumulative = eye(3);
frames = {};
Homo = {};
frames{1} = imgB;
Homo{1} = eye(3);

for k = 2:numFrames
% for k = 2:30
    % Read in new frame
    imgA = imgB;
    imgAp = imgBp;

    fprintf('***************************************\n');
    fprintf('Handle the %d frame.\n', k);
    imgB = read(obj,k);

    grayA = imgA;
    grayB = imgB;
    if ndims(imgA) == 3
        grayA = rgb2gray(imgA);
    end
    if ndims(imgB) == 3
        grayB = rgb2gray(imgB);
    end
    % Estimate transform from frame A to frame B, and fit as an s-R-t
    H = cvexEstStabilizationTform(grayA,grayB);
    HsRt = cvexTformToSRT(H);
    Hcumulative = HsRt * Hcumulative;
    Homo{k} = Hcumulative;
%     if (mod(ii,30) == 1)
%         Hcumulative = Homo{1};
%     end
    imgBp = imwarp(imgB,affine2d(Hcumulative),'OutputView',imref2d(size(imgB)));
%     imgBp = imwarp(imgB,affine2d(Hcumulative));

    frames{k} = imgBp;
end

myObj = VideoWriter('..\video\newfile.avi');
writerObj.FrameRate = 30;

open(myObj);
for i=1:size(frames,2)
    writeVideo(myObj,frames{i});
end
close(myObj);