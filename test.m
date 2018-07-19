% test upload github
close all;clear all;clc;
load('Homo.mat','Homo');
Homo{5}
% [H,s,ang,t,R] = cvexTformToSRT(Homo{5});
for k = 1:size(Homo,2)
    if ((Homo{k}(1,1) ~= Homo{k}(2,2)) | (Homo{k}(1,2) ~= -Homo{k}(2,1)))
        fprintf('%d unequal\n',k);
        break;
    end
    [H{k},s(k),ang(k),t{k},R{k}] = cvexTformToSRT(Homo{k});
end
