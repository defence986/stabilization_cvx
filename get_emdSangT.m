close all; clear;

[obj,numFrames] = get_obj('','');

imgB = read(obj, 1);
% imgBp = imgB;

k = 2;
Hcumulative = eye(3);
frames = {};
Homo = {};
frames{1} = imgB;
Homo{1} = eye(3);

R1(1) = 1;
R2(1) = 0;
T1(1) = 0;
T2(1) = 0;
for k = 2:numFrames
% for k = 2:30
    % Read in new frame
    imgA = imgB;
%     imgAp = imgBp;

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
    HsRt = cvexTformToSRT(H);
%     HsRt = H;
    Hcumulative = HsRt * Hcumulative;
%     R1(k) = double(Hcumulative(1,1));
%     R2(k) = double(Hcumulative(1,2));
    T1(k) = double(Hcumulative(3,1));
    T2(k) = double(Hcumulative(3,2));
    Homo{k} = Hcumulative;
    
%     imgBp = imwarp(imgB,affine2d(Hcumulative),'OutputView',imref2d(size(imgB)));

%     frames{k} = imgBp;
end

save('Homo.mat','Homo');
for k = 1:length(Homo)
    [H,Scale(k),ang(k),tran{k}] = cvexTformToSRT(Homo{k});
end
% Dist(1) = 0;

imfS = emd(Scale);
imfang = emd(ang);
if (~length(imfS) | ~length(imfang))
    fprintf('imf failure.\n');
    return;
end

balance_S = 0.003;
balance_ang = 10;

Ratio_Scale = cvx_ratio(imfS,Scale,balance_S);
emdS = ratio_emd(Ratio_Scale,imfS);

Ratio_ang = cvx_ratio(imfang,ang,balance_ang);
emdang = ratio_emd(Ratio_ang,imfang);

imfT1 = emd(T1);
imfT2 = emd(T2);
if ( ~length(imfT1) | ~length(imfT2))
    fprintf('T imf failure.\n');
    return;
end
balance_T1 = 1.801;
balance_T2 = 2.146;
RatioT1 = cvx_ratio(imfT1,T1,balance_T1);
emdT1 = ratio_emd(RatioT1,imfT1);

RatioT2 = cvx_ratio(imfT2,T2,balance_T2);
emdT2 = ratio_emd(RatioT2,imfT2);

T11 = sort(emdT1,'descend');
T22 = sort(emdT2,'descend');
MV1 = mean(T11(1:10)) - mean(emdT1);
MV2 = mean(T22(1:10)) - mean(emdT2);

for k = 1:size(Homo,2)
%     Homo{k} = cvexTformToRT(Homo{k},emdS(k)+1-min(emdS),emdang(k)-mean(emdang));
%     Homo{k} = cvexTformToS(Homo{k},emdS(k)+(1-mean(emdS)));
%     Homo{k} = cvexTformToS(Homo{k},emdS(k)+1-max(emdS));
    Homo{k} = cvexTformToang(Homo{k},emdang(k)-mean(emdang));
    Homo{k} = cvexTformToT(Homo{k},emdT1(k)-MV1,emdT2(k)+MV2);
end

for m = 1:size(Homo,2)
    frame = read(obj, m);
    frames{m} = imwarp(frame,affine2d(Homo{m}),'OutputView',imref2d(size(frame)));
end


myObj = VideoWriter('..\video\newfile.avi');
writerObj.FrameRate = 30;

open(myObj);
for i=1:size(frames,2)
    writeVideo(myObj,frames{i});
end
close(myObj);