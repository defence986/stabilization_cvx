function [ratio_kp, num, Adja] = match_adjacent(image1, image2)

% Find SIFT keypoints for each image
[Num1, im1, des1, loc1] = sift_single(image1);
[Num2, im2, des2, loc2] = sift_single(image2);

% For efficiency in Matlab, it is cheaper to compute dot products between
%  unit vectors rather than Euclidean distances.  Note that the ratio of 
%  angles (acos of dot products of unit vectors) is a close approximation
%  to the ratio of Euclidean distances for small angles.
%
% distRatio: Only keep matches in which the ratio of vector angles from the
%   nearest to second nearest neighbor is less than distRatio.

distRatio = 0.5;
%distRatio = 0.05;

% For each descriptor in the first image, select its match to second image.
des2t = des2';                          % Precompute matrix transpose
for i = 1 : size(des1,1)
   dotprods = des1(i,:) * des2t;        % Computes vector of dot products
   [vals,indx] = sort(acos(dotprods));  % Take inverse cosine and sort results

   % Check if nearest neighbor has angle less than distRatio times 2nd.
   if (vals(1) < distRatio * vals(2))
      match(i) = indx(1);
   else
      match(i) = 0;
   end
end

num = sum(match > 0);
fprintf('Found %d matches.\n', num);
ratio_kp = num / min(Num1, Num2);

%coords = double(zeros(num,4));
% j = 0;
% for i = 1: size(des1,1)
%     if (match(i) > 0)
%         j = j + 1;
%         Adja(j,1) = {[loc1(i,1) loc1(i,2)]}; 
%         Adja(j,2) = {[loc2(match(i),1) loc2(match(i),2)]};
%     end
% end

j = 0;
for i = 1: size(des1,1)
    if (match(i) > 0)
        j = j + 1;
        Adja(j).coords1 = [loc1(i,1) loc1(i,2)]; 
        Adja(j).coords2 = [loc2(match(i),1) loc2(match(i),2)];
    end
end


if 0
% Create a new image showing the two images side by side.
im3 = appendimages(im1,im2);

% Show a figure with lines joining the accepted matches.
figure('Position', [100 100 size(im3,2) size(im3,1)]);
colormap('gray');
imagesc(im3);
hold on;
cols1 = size(im1,2);
%size(Adja,2)
for i = 1: size(Adja,2)
     line([Adja(i).coords1(2) Adja(i).coords2(2)+cols1], ...
         [Adja(i).coords1(1) Adja(i).coords2(1)], 'Color', 'c');
end
hold off;
end