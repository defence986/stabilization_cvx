function new_trace = get_emdtrace(imf,Ts)

% Get HHT.
%imf = emd(x);
new_trace = 0;
M = length(imf);

for k = 1:M
%    fprintf('*********************\n');
%    imf{k}
   %fprintf('*********************\n');
   b(k) = sum(imf{k}.*imf{k});
   th   = angle(hilbert(imf{k})); % 相位
   d{k} = diff(th)/Ts/(2*pi); % 瞬时频率
   %b(k)
   %th
   %d{k}
end

for k = 1:M
    fre(k) = sum(d{k}.*d{k});
end
% for k = 1:M
%     D(k) = std(d{k}, 0, 2);
% end
% [vars,indx] = sort(-D);

[u,v] = sort(fre,'descend');
% round(M/2)
% indx(1)
% for k = v(1:min(1,M))
for k = v(1:max(1,round(M/2)))
    imf{k} = imf{k}* 0.95;
end

for k = min(1,M):M
    new_trace = imf{k} + new_trace;
end