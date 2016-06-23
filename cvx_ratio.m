function x = cvx_ratio(imfT1,T1,W)
% close all;clear;
% 
% load('imfT1.mat','imfT1');
% load('T1.mat','T1');
m = size(T1,2);
n = length(imfT1);
Sum = zeros(1,m);
cvx_begin
    variable x(n)
    for k = 1:n
        Sum = Sum + x(k) * imfT1{k};
    end
    for k = 1:m-1
        D1(k) = Sum(k+1) - Sum(k);
    end
    for k = 1:m-2
        D2(k) = D1(k+1) - D1(k);
    end
    for k = 1:m-3
        D3(k) = D2(k+1) - D2(k);
    end
%     D1 = diff(Sum,1);
%     D2 = diff(Sum,2);
%     D3 = diff(Sum,3);
    minimize(norm(D1,1)+norm(D2,1)+norm(D3,1)+norm(W*(Sum-T1),1))
%     minimize(norm(Sum-T1,1))
    subject to
          for k = 1:n
              x(k)>=0
              x(k)<=1
          end
cvx_end