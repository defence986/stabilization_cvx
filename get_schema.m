function Core = get_schema(obj,Start,End)

% close all; clear;
% [obj,numFrames] = get_obj('','');
% Start = 25;
% End = 48;

Adjas = match_adjacents(obj, Start, End);
%load('Adjas.mat', 'Adjas');
Coords = get_coords(Adjas);
[Rows,Cols] = size(Coords);
for i = 1:Rows
    for j = 1:Cols
        coordR(i,j) = Coords{i,j}(1);
        coordC(i,j) = Coords{i,j}(2);
    end
end
Fs = 30;
i = 1;
for m = 1:size(Coords,1)
    fprintf('get emdR emdC %d\n', m);
    imf1 = emd(coordR(m,:));
    imf2 = emd(coordC(m,:));
    if ~length(imf1) | ~length(imf2)
        continue;
    end
    emdR(i,:) = get_emdtrace(imf1,1/Fs);
    emdC(i,:) = get_emdtrace(imf2,1/Fs);
    oldR(i,:) = coordR(m,:);
    oldC(i,:) = coordC(m,:);
    i = i + 1;
end

k = 1;
for i = 1:size(emdR,2)
    temp_coord(1,:) = emdR(:,i)';
    temp_coord(2,:) = emdC(:,i)';
    [y, energy, model] = kmeans(temp_coord,k);
    new_core{i} = model.means;
    
    temp_coord(1,:) = oldR(:,i)';
    temp_coord(2,:) = oldC(:,i)';
    [y, energy, model] = kmeans(temp_coord,k);
    old_core{i} = model.means;
    
    Core{i} = new_core{i} - old_core{i};
end

k = 3;
for i = 1:size(emdR,2)
    temp_coord(1,:) = emdR(:,i)';
    temp_coord(2,:) = emdC(:,i)';
    [y, energy, model] = kmeans(temp_coord,k);
    new_triangle{i} = model.means;
    
    temp_coord(1,:) = oldR(:,i)';
    temp_coord(2,:) = oldC(:,i)';
    [y, energy, model] = kmeans(temp_coord,k);
    old_triangle{i} = model.means;
    
    %Core{i} = new_core{i} - old_core{i};
end

% for m = 1:size(Coords,1)
%     fprintf('get emdC %d\n', m);
%     imf = emd(coordC(m,:));
%     if ~length(imf)
%         continue;
%     end
%     emdC(j,:) = get_emdtrace(imf,1/Fs);
%     j = j + 1;
% end
% save('emd_tras.mat','emd_tras');

% for i = 1:size(emd_tras, 2)
%     [label, energy, model] = kmeans((emd_tras(:,i))',1);
%     mean_tra(i) = model.means(1);
% end
% for i = 1:size(Dist,2)
%     [label, energy, model] = kmeans((Dist(:,i))',1);
%     old_tra(i) = model.means(1);
% end
% for i = 1:size(Dists,2)
%     temp_coord(1,:) = Dists{:,1}(1);
%     temp_coord(2,:) = Dists{:,1}(2);
% end

% start = k+1;
% 
% if k == numFrames-1
%     Adjas = match_adjacents(obj, Start, k+1);
%     Scene(l) = Adjas;
% end