function RGB = gray2rgb(I)

[X, map] = gray2ind(I, 65536);
RGB = ind2rgb(X,map);