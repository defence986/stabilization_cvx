function [Homo,R1,R2,T1,T2] = preserve_feature(obj,numFrames,Switch)
% close all; clear;

% [obj,numFrames] = get_obj('','');
% Switch = [239,43,44,10];
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
    % Read in new frame
    imgA = imgB;
    imgAp = imgBp;

    fprintf('***************************************\n');
    fprintf('Request feature-centric SRT the %d frame.\n', k);
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
    if ismember(k,Switch)
        Hcumulative = eye(3);
    end
    R1(k) = double(Hcumulative(1,1));
    R2(k) = double(Hcumulative(1,2));
    T1(k) = double(Hcumulative(3,1));
    T2(k) = double(Hcumulative(3,2));
    Homo{k} = Hcumulative;
end