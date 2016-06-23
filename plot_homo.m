close all;clear;


load('H.mat', 'Homo');

Dot1 = [1,1,1];
for i = 1:size(Homo,2)
    Dots{i} = Dot1 * Homo{i};
%     Hdots{i} = [Dots{i}(1),Dots{i}(2)];
    Hx(i) = Dots{i}(1);
end

load('H+emd.mat', 'Homo');
for i = 1:size(Homo,2)
    Dots{i} = Dot1 * Homo{i};
%     Hdots{i} = [Dots{i}(1),Dots{i}(2)];
    Hemdx(i) = Dots{i}(1);
end
X = 1:345;
plot(X,Hx,X,Hemdx,'--');