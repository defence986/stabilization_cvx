close all;clear;
load('R1.mat','R1');
length(R1)
% for i = 1:size(R1,2)
%     R1(i)
% end
R1(size(R1,2))
p = findpeaks(R1);
% R1(p)
% imfR1 = emd(R1);