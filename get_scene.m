function Scene = get_scene(obj)

numFrames = obj.NumberOfFrames;
start = 1;
s = 1;

for k = 1 : numFrames-1
    frame1 = read(obj, k);
    frame2 = read(obj, k+1);
    fprintf('**********************\n');
    fprintf('Match adjacent %d %d frames.\n', k, k+1);
    ratio_kp = match_adjacent(frame1, frame2);
    if (ratio_kp < 0.15)
        if ((k+1-start)<10)
            fprintf('Scene switch too quick. only %d %d %d\n', k+1-start, start, k+1);
            continue;
        end
        Scene(s) = k;
        s = s + 1;
        start = k + 1;
    end
end