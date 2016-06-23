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

R1(1) = 1;
R2(1) = 0;
T1(1) = 0;
T2(1) = 0;
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
    HsRt = cvexTformToSRT(H);
%     HsRt = H;
    Hcumulative = HsRt * Hcumulative;
    R1(k) = double(Hcumulative(1,1));
    R2(k) = double(Hcumulative(1,2));
    T1(k) = double(Hcumulative(3,1));
    T2(k) = double(Hcumulative(3,2));
    Homo{k} = Hcumulative;
    
%     if (mod(ii,30) == 1)
%         Hcumulative = Homo{1};
%     end
%     imgBp = imwarp(imgB,affine2d(Hcumulative),'OutputView',imref2d(size(imgB)));
%     imgBp = imwarp(imgB,affine2d(Hcumulative));

%     frames{k} = imgBp;
end

save('Homo.mat','Homo');
for k = 1:length(Homo)
    [H,Scale(k)] = cvexTformToSRT(Homo{k});
end
Dist(1) = 0;
for k = 2:length(Homo)
    Dist(k) = (T1(k)-T1(k-1)).^2 + (T2(k)-T2(k-1)).^2;
end
[New_dist, indx] = sort(Dist,'descend');
% [R1,R2,T1,T2] = set_initial(R1,R2,T1,T2,indx(1));
% [R1,R2,T1,T2] = set_initial(R1,R2,T1,T2,indx(2));
% [R1,R2,T1,T2] = set_initial(R1,R2,T1,T2,indx(3));
% [R1,R2,T1,T2] = set_initial(R1,R2,T1,T2,indx(4));
% [R1,R2,T1,T2] = set_initial(R1,R2,T1,T2,indx(5));
% indx(1)
% indx(2)
% indx(3)
% indx(4)


% [Homo,R1,R2,T1,T2] = preserve_feature(obj,numFrames,indx(1:2));


% imfR1 = emd(R1);
% imfR2 = emd(R2);
% imfT1 = emd(T1);
% imfT2 = emd(T2);
% % save('imfT1.mat','imfT1');
% % save('T1.mat','T1');
% 
% if (~length(imfR1) | ~length(imfR2) | ~length(imfT1) | ~length(imfT2))
%     fprintf('imf failure.\n');
%     return;
% end

if 1
% Fs = 30;
% emdR1 = get_emdtrace(imfR1,1/Fs);
% emdR2 = get_emdtrace(imfR2,1/Fs);
% emdT1 = get_emdtrace(imfT1,1/Fs);
% emdT2 = get_emdtrace(imfT2,1/Fs);
% Ratio1 = cvx_ratio(imfR1,R1,1);
% emdR1 = ratio_emd(Ratio1,imfR1);
% 
% Ratio2 = cvx_ratio(imfR2,R2,1);
% emdR2 = ratio_emd(Ratio2,imfR2);
% 
% Ratio3 = cvx_ratio(imfT1,T1,100);
% emdT1 = ratio_emd(Ratio3,imfT1);
% 
% Ratio4 = cvx_ratio(imfT2,T2,100);
% emdT2 = ratio_emd(Ratio4,imfT2);


imfS = emd(Scale);
if (~length(imfS))
    fprintf('imf failure.\n');
    return;
end
Ratio = cvx_ratio(imfS,Scale,0.005);
emdS = ratio_emd(Ratio,imfS);

for m = 1:size(emdS,2)
    Homo{k} = cvexTformToRT(Homo{k},emdS(k));
end
% for m = 1:size(emdR1,2)
%     Homo{m}(1,1) = emdR1(m);
%     Homo{m}(1,2) = emdR2(m);
%     Homo{m}(2,1) = -emdR2(m);
%     Homo{m}(2,2) = emdR1(m);
%     Homo{m}(3,1) = emdT1(m);
%     Homo{m}(3,2) = emdT2(m);
%     
%     frame = read(obj, m);
%     frames{m} = imwarp(frame,affine2d(Homo{m}),'OutputView',imref2d(size(frame)));
% end
% save('H+emd.mat','Homo');

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
end