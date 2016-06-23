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
    fprintf('Request SRT the %d frame.\n', k);
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
%     HsRt = cvexTformToSRT(H);
    HsRt = H;
    Hcumulative = HsRt * Hcumulative;
    R1(k-1) = double(Hcumulative(1,1));
    R2(k-1) = double(Hcumulative(1,2));
    T1(k-1) = double(Hcumulative(3,1));
    T2(k-1) = double(Hcumulative(3,2));
    Homo{k} = Hcumulative;
    
%     if (mod(ii,30) == 1)
%         Hcumulative = Homo{1};
%     end
%     imgBp = imwarp(imgB,affine2d(Hcumulative),'OutputView',imref2d(size(imgB)));
%     imgBp = imwarp(imgB,affine2d(Hcumulative));

%     frames{k} = imgBp;
end

save('H.mat','Homo');

imfR1 = emd(R1);
imfR2 = emd(R2);
imfT1 = emd(T1);
imfT2 = emd(T2);

if (~length(imfR1) | ~length(imfR2) | ~length(imfT1) | ~length(imfT2))
    fprintf('imf failure.\n');
    return;
end

Fs = 30;
emdR1 = get_emdtrace(imfR1,1/Fs);
emdR2 = get_emdtrace(imfR2,1/Fs);
emdT1 = get_emdtrace(imfT1,1/Fs);
emdT2 = get_emdtrace(imfT2,1/Fs);

for m = 1:size(emdR1,2)
    Homo{m+1}(1,1) = emdR1(m);
    Homo{m+1}(1,2) = emdR2(m);
    Homo{m+1}(2,1) = -emdR2(m);
    Homo{m+1}(2,2) = emdR1(m);
    Homo{m+1}(3,1) = emdT1(m);
    Homo{m+1}(3,2) = emdT2(m);
    
    frame = read(obj, m+1);
    frames{m+1} = imwarp(frame,affine2d(Homo{m+1}),'OutputView',imref2d(size(frame)));
end
save('H+emd.mat','Homo');

myObj = VideoWriter('..\video\newfile.avi');
writerObj.FrameRate = 30;

open(myObj);
for i=1:size(frames,2)
    writeVideo(myObj,frames{i});
end
close(myObj);