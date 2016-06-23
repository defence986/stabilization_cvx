% Set IMF plots.
M = length(imfR2);
% N = length(x);
X = 1:345;
% c = linspace(0,(N-1)*Ts,N);

figure;
for k = 1:M
    subplot(M,1,k);
    plot(X,imfR2{k});
    %        set(gca,'FontSize',8,'XLim',[0 c(end)]);
    title(sprintf('优化前第%d个IMF', k));
    ylabel(sprintf('IMF%d', k));
end
xlabel('Time');

figure;
for k = 1:M
    subplot(M,1,k);
    plot(X,Ratio2(k)*imfR2{k});
    %        set(gca,'FontSize',8,'XLim',[0 c(end)]);
    title(sprintf('优化后第%d个IMF', k));
    ylabel(sprintf('IMF%d', k));
end
xlabel('Time');

Sum = zeros(1,345);
for k = 1:M
    Sum = Sum + Ratio2(k)*imfR2{k};
end
figure;
plot(X,R2,X,Sum,'--');
legend('优化前', '优化后');