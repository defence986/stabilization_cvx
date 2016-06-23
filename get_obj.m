function [obj,numFrames] = get_obj(fileName,ourpath)

fileName = 'Video_Figure_1.mov';
ourpath = 'D:\play\movie\';
obj = VideoReader(strcat(ourpath, fileName));
numFrames = obj.NumberOfFrames;% num of all the frames